/*
    This nested module creates;
    - Create Application security group for scale cluster
    - Create NSG and associated rules
    - Spin storage cluster instances
    - Spin compute cluster instances
    - Generates ansible inventory file for scale cluster deployment
*/

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = local.compute_or_combined ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = local.storage_or_combined ? true : false
}

# Create scale cluster application security group
module "cluster_security_group" {
  source              = "../../../resources/azure/security/application_security_group"
  resource_prefix     = "${var.resource_prefix}-cls-sec-group"
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Allow scale/gpfs tcp traffic the scale vm(s)
module "allow_traffic_within_scale_vms" {
  source                                     = "../../../resources/azure/security/nsg_source_destination_app_sec_grp"
  total_rules                                = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? length(local.tcp_port_scale_cluster) : 0
  rule_names_prefix                          = "${var.resource_prefix}-cls-allow"
  direction                                  = ["Inbound"]
  access                                     = ["Allow"]
  protocol                                   = concat([for i in range(length(local.tcp_port_scale_cluster)) : "Tcp"], [for i in range(length(local.udp_port_scale_cluster)) : "Udp"])
  source_port_range                          = ["*"]
  destination_port_range                     = concat(local.tcp_port_scale_cluster, local.udp_port_scale_cluster)
  priority                                   = [for i in range(length(local.tcp_port_scale_cluster) + length(local.udp_port_scale_cluster)) : format("%s", i + var.nsg_rule_start_index)]
  network_security_group_name                = var.vpc_network_security_group_ref
  resource_group_name                        = var.resource_group_name
  source_application_security_group_ids      = [module.cluster_security_group.asg_id]
  destination_application_security_group_ids = [module.cluster_security_group.asg_id]
  description                                = "Allow traffic within scale instances"
}

# Create security rules to enable scale communication between bastion and scale instances
module "cluster_ingress_security_rule_using_jumphost_connection" {
  source                                     = "../../../resources/azure/security/nsg_source_destination_app_sec_grp"
  total_rules                                = var.using_jumphost_connection ? length(local.tcp_port_bastion_scale_cluster) : 0
  rule_names_prefix                          = "${var.resource_prefix}-bastion-to-cluster"
  direction                                  = ["Inbound"]
  access                                     = ["Allow"]
  protocol                                   = [for i in range(length(local.tcp_port_bastion_scale_cluster)) : "Tcp"]
  source_port_range                          = ["*"]
  destination_port_range                     = local.tcp_port_bastion_scale_cluster
  priority                                   = [for i in range(length(local.tcp_port_bastion_scale_cluster)) : format("%s", i + 110 + var.nsg_rule_start_index)]
  source_application_security_group_ids      = [var.bastion_security_group_ref]
  destination_application_security_group_ids = [module.cluster_security_group.asg_id]
  network_security_group_name                = var.vpc_network_security_group_ref
  resource_group_name                        = var.resource_group_name
  description                                = "Allow traffic betwen bastion instances and scale instances"
}

module "proximity_group" {
  count                   = local.create_placement_group == true ? 1 : 0
  source                  = "../../../resources/azure/compute/proximity_placement_group"
  proximity_group_name    = var.resource_prefix
  resource_group_name     = var.resource_group_name
  location                = var.vpc_region
  vnet_availability_zones = var.vpc_availability_zones
}

resource "time_sleep" "wait_30_seconds" {
  depends_on       = [module.proximity_group]
  destroy_duration = "30s"
}

# Create compute scale cluster instances.
module "compute_cluster_instances" {
  for_each                      = local.compute_vm_zone_map
  source                        = "../../../resources/azure/compute/vm_0_disk"
  name_prefix                   = each.key
  source_image_id               = var.compute_cluster_image_ref
  dns_domain                    = var.vpc_compute_cluster_dns_domain
  forward_dns_zone              = var.vpc_forward_dns_zone
  subnet_id                     = each.value["subnet"]
  resource_group_name           = var.resource_group_name
  location                      = var.vpc_region
  vm_size                       = var.compute_cluster_instance_type
  login_username                = var.instances_ssh_user_name
  proximity_placement_group_id  = null
  reverse_dns_zone              = var.vpc_reverse_dns_zone
  os_disk_caching               = var.compute_cluster_os_disk_caching
  os_storage_account_type       = var.compute_cluster_boot_disk_type
  ssh_public_key_path           = var.compute_cluster_public_key_path
  meta_private_key              = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key               = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  availability_zone             = each.value["zone"]
  application_security_group_id = module.cluster_security_group.asg_id
}

# 1 disk encryption set will be created per encrypted filesystem
module "disk_encryption_set" {
  source                       = "../../../resources/azure/disks/encryption_set"
  for_each                     = { for idx, fs in var.filesystem_parameters : idx => fs }
  turn_on                      = local.storage_or_combined && each.value.filesystem_encrypted ? true : false
  encryption_type              = "EncryptionAtRestWithCustomerKey"
  filesystem_key_vault_key_ref = each.value.filesystem_key_vault_key_ref
  location                     = var.vpc_region
  name_prefix                  = format("%s-enc-set-%s", var.resource_prefix, each.key)
  resource_group_name          = var.resource_group_name
  filesystem_key_vault_ref     = each.value.filesystem_key_vault_ref
}

# Create storage scale cluster instances.
module "storage_cluster_instances" {
  for_each                      = local.storage_vm_zone_map
  source                        = "../../../resources/azure/compute/vm_multiple_disk"
  name_prefix                   = each.key
  source_image_id               = var.storage_cluster_image_ref
  dns_domain                    = var.vpc_storage_cluster_dns_domain
  forward_dns_zone              = var.vpc_forward_dns_zone
  subnet_id                     = each.value["subnet"]
  resource_group_name           = var.resource_group_name
  location                      = var.vpc_region
  use_temporary_disks           = var.scratch_devices_per_storage_instance > 0 ? true : false
  vm_size                       = var.storage_cluster_instance_type
  login_username                = var.instances_ssh_user_name
  proximity_placement_group_id  = local.create_placement_group == true ? module.proximity_group.proximity_group_storage_id : null
  reverse_dns_zone              = var.vpc_reverse_dns_zone
  os_disk_caching               = var.storage_cluster_os_disk_caching
  os_storage_account_type       = var.storage_cluster_boot_disk_type
  ssh_public_key_path           = var.storage_cluster_public_key_path
  meta_private_key              = module.generate_storage_cluster_keys.private_key_content
  meta_public_key               = module.generate_storage_cluster_keys.public_key_content
  availability_zone             = each.value["zone"]
  disks                         = each.value["disks"]
  application_security_group_id = module.cluster_security_group.asg_id
}

module "storage_cluster_tie_breaker_instance" {
  for_each                      = local.storage_tie_vm_zone_map
  source                        = "../../../resources/azure/compute/vm_multiple_disk"
  name_prefix                   = format("%s-storage-tie", var.resource_prefix)
  source_image_id               = var.storage_cluster_image_ref
  dns_domain                    = var.vpc_storage_cluster_dns_domain
  forward_dns_zone              = var.vpc_forward_dns_zone
  subnet_id                     = each.value["subnet"]
  resource_group_name           = var.resource_group_name
  location                      = var.vpc_region
  vm_size                       = var.storage_cluster_instance_type
  login_username                = var.instances_ssh_user_name
  proximity_placement_group_id  = null
  use_temporary_disks           = false
  reverse_dns_zone              = var.vpc_reverse_dns_zone
  os_disk_caching               = var.storage_cluster_os_disk_caching
  os_storage_account_type       = var.storage_cluster_boot_disk_type
  ssh_public_key_path           = var.storage_cluster_public_key_path
  meta_private_key              = module.generate_storage_cluster_keys.private_key_content
  meta_public_key               = module.generate_storage_cluster_keys.public_key_content
  availability_zone             = each.value["zone"]
  disks                         = each.value["disks"]
  application_security_group_id = module.cluster_security_group.asg_id
}

module "gateway_instances" {
  for_each                      = local.gateway_vm_subnet_map
  source                        = "../../../resources/azure/compute/vm_0_disk"
  name_prefix                   = each.key
  source_image_id               = var.storage_cluster_image_ref
  dns_domain                    = var.vpc_compute_cluster_dns_domain
  forward_dns_zone              = var.vpc_forward_dns_zone
  subnet_id                     = each.value["subnet"]
  resource_group_name           = var.resource_group_name
  location                      = var.vpc_region
  vm_size                       = var.gateway_instance_type
  login_username                = var.instances_ssh_user_name
  proximity_placement_group_id  = null
  reverse_dns_zone              = var.vpc_reverse_dns_zone
  os_disk_caching               = var.storage_cluster_os_disk_caching
  os_storage_account_type       = var.storage_cluster_boot_disk_type
  ssh_public_key_path           = var.storage_cluster_public_key_path
  meta_private_key              = module.generate_storage_cluster_keys.private_key_content
  meta_public_key               = module.generate_storage_cluster_keys.public_key_content
  availability_zone             = each.value["zone"]
  application_security_group_id = module.cluster_security_group.asg_id
}

module "prepare_ansible_configuration" {
  turn_on    = true
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

# Write the compute cluster related inventory.
resource "local_sensitive_file" "write_compute_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == true && var.cluster_type == "Compute-only" ? 1 : 0
  filename = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "Azure"
    resource_prefix                          = var.resource_prefix
    vpc_region                               = var.vpc_region
    vpc_availability_zones                   = var.vpc_availability_zones
    scale_version                            = local.scale_version
    filesystem_details                       = local.filesystem_details
    compute_cluster_filesystem_mountpoint    = var.compute_cluster_filesystem_mountpoint
    bastion_instance_id                      = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                             = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip               = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                  = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_details                  = [for instance in module.compute_cluster_instances : instance.instance_details]
    storage_cluster_details                  = []
    storage_cluster_with_data_volume_mapping = {}
    storage_cluster_desc_details             = []
    storage_cluster_desc_data_volume_mapping = {}
  })
}

# Write the storage cluster related inventory.
resource "local_sensitive_file" "write_storage_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.cluster_type == "Storage-only" ? 1 : 0
  filename = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "Azure"
    resource_prefix                          = var.resource_prefix
    vpc_region                               = var.vpc_region
    vpc_availability_zones                   = var.vpc_availability_zones
    scale_version                            = local.scale_version
    filesystem_details                       = local.filesystem_details
    bastion_instance_id                      = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                             = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip               = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                  = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_details                  = []
    storage_cluster_details                  = [for instance in module.storage_cluster_instances : instance.instance_details]
    storage_cluster_with_data_volume_mapping = local.storage_instance_ips_with_disk_mapping
    storage_cluster_desc_details             = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
    storage_cluster_desc_data_volume_mapping = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
  })
}

# Write combined cluster related inventory.
resource "local_sensitive_file" "write_combined_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? 1 : 0
  filename = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "Azure"
    resource_prefix                          = var.resource_prefix
    vpc_region                               = var.vpc_region
    vpc_availability_zones                   = var.vpc_availability_zones
    scale_version                            = local.scale_version
    filesystem_details                       = local.filesystem_details
    bastion_instance_id                      = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                             = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip               = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                  = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_details                  = [for instance in module.compute_cluster_instances : instance.instance_details]
    storage_cluster_details                  = [for instance in module.storage_cluster_instances : instance.instance_details]
    storage_cluster_with_data_volume_mapping = local.storage_instance_ips_with_disk_mapping
    storage_cluster_desc_details             = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
    storage_cluster_desc_data_volume_mapping = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
  })
}

# Configure the compute cluster using ansible based on the create_scale_cluster input.
module "compute_cluster_configuration" {
  source                          = "../../../resources/common/compute_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && local.compute_or_combined && var.create_remote_mount_cluster ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  memory_size                     = 8 # TODO: Use vm profile
  max_pagepool_gb                 = 4
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_compute_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  depends_on                      = [resource.local_sensitive_file.write_compute_cluster_inventory]
}

# Configure the storage cluster using ansible based on the create_scale_cluster input.
module "storage_cluster_configuration" {
  source                          = "../../../resources/common/storage_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && local.storage_or_combined && var.create_remote_mount_cluster ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = true
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = 16
  max_pagepool_gb                 = 16
  vcpu_count                      = 2
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  max_mbps                        = 50000 * 0.25 # TODO: maximum egress bandwidth limit ranges from 50-200 Gbps
  disk_type                       = jsonencode("None")
  depends_on                      = [resource.local_sensitive_file.write_storage_cluster_inventory]
}

# Configure the combined cluster using ansible based on the create_scale_cluster input.
module "combined_cluster_configuration" {
  source                          = "../../../resources/common/scale_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = 8
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  depends_on                      = [resource.local_sensitive_file.write_combined_inventory]
}

# Configure the remote mount relationship between the created compute & storage cluster.
module "remote_mount_configuration" {
  source                          = "../../../resources/common/remote_mount_configuration"
  turn_on                         = var.cluster_type == "Combined-compute-storage" && var.create_remote_mount_cluster ? true : false
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  compute_inventory_path          = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  compute_gui_inventory_path      = format("%s/compute_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  storage_inventory_path          = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  storage_gui_inventory_path      = format("%s/storage_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
}
