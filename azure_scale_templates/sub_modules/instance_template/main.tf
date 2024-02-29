/*
  Creates compute and storage cluster VM for Azure
    - Create Application security group for scale cluster
    - Create NSG and associated rules
    - Creates DNS private zones
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

# Create scale cluster ASG
module "scale_cluster_asg" {
  source              = "../../../resources/azure/security/network_application_security_group"
  resource_prefix     = "${var.resource_prefix}-scale-cluster"
  location            = var.vpc_region
  resource_group_name = var.resource_group_ref
}

# Create scale cluster nsg
module "scale_cluster_nsg" {
  source              = "../../../resources/azure/security/network_security_group"
  security_group_name = format("%s-scale-cluster", var.resource_prefix)
  location            = var.vpc_region
  resource_group_name = var.resource_group_ref
}

# Allow scale/gpfs tcp traffic the scale vm(s)
module "scale_cluster_tcp_inbound_security_rule" {
  source                                     = "../../../resources/azure/security/network_security_group_asg_rule"
  total_rules                                = length(local.tcp_port_scale_cluster)
  rule_names_prefix                          = var.resource_prefix
  direction                                  = ["Inbound"]
  access                                     = ["Allow"]
  protocol                                   = [for i in range(length(local.tcp_port_scale_cluster)) : "Tcp"]
  source_port_range                          = local.tcp_port_scale_cluster
  destination_port_range                     = local.tcp_port_scale_cluster
  priority                                   = [for i in range(length(local.tcp_port_scale_cluster)) : "${i + 100}"]
  source_application_security_group_ids      = [module.scale_cluster_asg.asg_id]
  destination_application_security_group_ids = [module.scale_cluster_asg.asg_id]
  network_security_group_name                = module.scale_cluster_nsg.sec_group_name
  resource_group_name                        = var.resource_group_ref
}

# Allow scale/gpfs udp traffic the scale vm(s)
module "scale_cluster_udp_inbound_security_rule" {
  source                                     = "../../../resources/azure/security/network_security_group_asg_rule"
  total_rules                                = length(local.udp_port_scale_cluster)
  rule_names_prefix                          = var.resource_prefix
  direction                                  = ["Inbound"]
  access                                     = ["Allow"]
  protocol                                   = [for i in range(length(local.udp_port_scale_cluster)) : "Udp"]
  source_port_range                          = local.udp_port_scale_cluster
  destination_port_range                     = local.udp_port_scale_cluster
  priority                                   = [for i in range(length(local.udp_port_scale_cluster)) : "${i + 130}"]
  source_application_security_group_ids      = [module.scale_cluster_asg.asg_id]
  destination_application_security_group_ids = [module.scale_cluster_asg.asg_id]
  network_security_group_name                = module.scale_cluster_nsg.sec_group_name
  resource_group_name                        = var.resource_group_ref
}

locals {
  bastion_public_subnet = var.vpc_storage_cluster_public_subnet[0] != null ? var.vpc_storage_cluster_public_subnet[0] : (var.vpc_compute_cluster_public_subnet[0] != null ? var.vpc_compute_cluster_public_subnet[0] : null)
}


# Get bastion subnet cidr
data "azurerm_subnet" "bastion" {
  name                 = basename(local.bastion_public_subnet)
  virtual_network_name = basename(var.vpc_ref)
  resource_group_name  = var.resource_group_ref
}

# Allow bastion to scale cluster
module "bastion_scale_cluster_tcp_inbound_security_rule" {
  count                                 = try(var.using_jumphost_connection ? 1 : 0, 0)
  source                                = "../../../resources/azure/security/network_security_group_asg_with_address_rule"
  rule_names_prefix                     = "${var.resource_prefix}-bastion"
  direction                             = ["Inbound"]
  access                                = ["Allow"]
  protocol                              = [for i in range(length(local.tcp_port_bastion_scale_cluster)) : "Tcp"]
  source_port_range                     = local.tcp_port_bastion_scale_cluster
  destination_port_range                = local.tcp_port_bastion_scale_cluster
  priority                              = [for i in range(length(local.tcp_port_bastion_scale_cluster)) : "${i + 110}"]
  source_application_security_group_ids = [module.scale_cluster_asg.asg_id]
  destination_address_prefix            = data.azurerm_subnet.bastion.address_prefix
  network_security_group_name           = module.scale_cluster_nsg.sec_group_name
  resource_group_name                   = var.resource_group_ref
}

module "storage_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = local.storage_or_combined == true ? true : false
  dns_domain_name     = format("%s.%s", var.vpc_region, var.vpc_storage_cluster_dns_domain)
  resource_group_name = var.resource_group_ref
}

module "compute_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = local.compute_or_combined == true ? true : false
  dns_domain_name     = format("%s.%s", var.vpc_region, var.vpc_compute_cluster_dns_domain)
  resource_group_name = var.resource_group_ref
}

module "link_storage_dns_zone_vpc" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = local.storage_or_combined == true ? true : false
  private_dns_zone_name = module.storage_private_dns_zone.private_dns_zone_name
  resource_group_name   = var.resource_group_ref
  vnet_id               = var.vpc_ref
  vnet_zone_link_name   = format("%s-strg-link", var.resource_prefix)
}

module "link_compute_dns_zone_vpc" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = local.compute_or_combined == true ? true : false
  private_dns_zone_name = module.compute_private_dns_zone.private_dns_zone_name
  resource_group_name   = var.resource_group_ref
  vnet_id               = var.vpc_ref
  vnet_zone_link_name   = format("%s-comp-link", var.resource_prefix)
}

module "proximity_group" {
  count                   = local.create_placement_group == true ? 1 : 0
  source                  = "../../../resources/azure/compute/proximity_placement_group"
  proximity_group_name    = var.resource_prefix
  resource_group_name     = var.resource_group_ref
  location                = var.vpc_region
  vnet_availability_zones = var.vpc_availability_zones
}

resource "time_sleep" "wait_30_seconds" {
  depends_on       = [module.proximity_group]
  destroy_duration = "30s"
}

module "associate_compute_nsg_wth_subnet" {
  count                     = var.vpc_compute_cluster_private_subnets != null ? length(var.vpc_compute_cluster_private_subnets) - 1 : 0 #fix me length is show wrong hence creating two times
  source                    = "../../../resources/azure/security/network_security_group_association"
  subnet_id                 = var.vpc_compute_cluster_private_subnets[count.index]
  network_security_group_id = module.scale_cluster_nsg.sec_group_id
}

# Create compute scale cluster instances.
module "compute_cluster_instances" {
  for_each                      = local.compute_vm_zone_map
  source                        = "../../../resources/azure/compute/vm_0_disk"
  vm_name                       = each.key
  source_image_id               = var.compute_cluster_image_ref
  subnet_id                     = each.value["subnet"]
  resource_group_name           = var.resource_group_ref
  location                      = var.vpc_region
  vm_size                       = var.compute_cluster_instance_type
  login_username                = var.compute_cluster_login_username
  proximity_placement_group_id  = null
  os_disk_caching               = var.compute_cluster_os_disk_caching
  os_storage_account_type       = var.compute_boot_disk_type
  user_key_pair                 = var.create_remote_mount_cluster == true ? var.compute_cluster_key_pair : var.storage_cluster_key_pair
  meta_private_key              = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key               = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  dns_zone                      = module.compute_private_dns_zone.private_dns_zone_name
  availability_zone             = each.value["zone"]
  application_security_group_id = module.scale_cluster_asg.asg_id
  depends_on                    = [module.compute_private_dns_zone]
}

module "associate_storage_nsg_wth_subnet" {
  count                     = var.vpc_storage_cluster_private_subnets != null ? length(var.vpc_storage_cluster_private_subnets) : 0
  source                    = "../../../resources/azure/security/network_security_group_association"
  subnet_id                 = var.vpc_storage_cluster_private_subnets[count.index]
  network_security_group_id = module.scale_cluster_nsg.sec_group_id
}

# Create storage scale cluster instances.
module "storage_cluster_instances" {
  for_each                       = local.storage_vm_zone_map
  source                         = "../../../resources/azure/compute/vm_multiple_disk"
  vm_name                        = each.key
  source_image_id                = var.storage_cluster_image_ref
  subnet_id                      = each.value["subnet"]
  resource_group_name            = var.resource_group_ref
  location                       = var.vpc_region
  vm_size                        = var.storage_cluster_instance_type
  login_username                 = var.storage_cluster_login_username
  proximity_placement_group_id   = local.create_placement_group == true ? module.proximity_group.proximity_group_storage_id : null
  os_disk_caching                = var.storage_cluster_os_disk_caching
  os_storage_account_type        = var.storage_cluster_boot_disk_type
  data_disk_device_names         = local.block_device_names
  data_disk_storage_account_type = var.block_device_volume_type
  user_key_pair                  = var.storage_cluster_key_pair
  meta_private_key               = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                = module.generate_storage_cluster_keys.public_key_content
  dns_zone                       = module.storage_private_dns_zone.private_dns_zone_name
  availability_zone              = each.value["zone"]
  disks                          = each.value["disks"]
  application_security_group_id  = module.scale_cluster_asg.asg_id
  depends_on                     = [module.storage_private_dns_zone]
}

module "storage_cluster_tie_breaker_instance" {
  for_each                       = local.storage_tie_vm_zone_map
  source                         = "../../../resources/azure/compute/vm_multiple_disk"
  vm_name                        = format("%s-storage-tie", var.resource_prefix)
  source_image_id                = var.storage_cluster_image_ref
  subnet_id                      = each.value["subnet"]
  resource_group_name            = var.resource_group_ref
  location                       = var.vpc_region
  vm_size                        = var.storage_cluster_instance_type
  login_username                 = var.storage_cluster_login_username
  proximity_placement_group_id   = null
  os_disk_caching                = var.storage_cluster_os_disk_caching
  os_storage_account_type        = var.storage_cluster_boot_disk_type
  data_disk_device_names         = local.block_device_names
  data_disk_storage_account_type = var.block_device_volume_type
  user_key_pair                  = var.storage_cluster_key_pair
  meta_private_key               = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                = module.generate_storage_cluster_keys.public_key_content
  dns_zone                       = var.vpc_storage_cluster_dns_domain
  availability_zone              = each.value["zone"]
  disks                          = each.value["disks"]
  application_security_group_id  = module.scale_cluster_asg.asg_id
  depends_on                     = [module.storage_private_dns_zone]
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
    cloud_platform                            = "Azure"
    resource_prefix                           = var.resource_prefix
    vpc_region                                = var.vpc_region
    vpc_availability_zones                    = var.vpc_availability_zones
    scale_version                             = local.scale_version
    filesystem_details                        = local.filesystem_details
    compute_cluster_filesystem_mountpoint     = var.compute_cluster_filesystem_mountpoint
    bastion_instance_id                       = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                              = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                   = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_instance_ids              = [for instance in module.compute_cluster_instances : instance.instance_ids]
    compute_cluster_instance_private_ips      = [for instance in module.compute_cluster_instances : instance.instance_private_ips]
    compute_cluster_instance_private_dns      = [for instance in module.compute_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_instance_ids              = []
    storage_cluster_instance_private_ips      = []
    storage_cluster_with_data_volume_mapping  = {}
    storage_cluster_instance_private_dns      = []
    storage_cluster_desc_instance_ids         = []
    storage_cluster_desc_instance_private_ips = []
    storage_cluster_desc_data_volume_mapping  = {}
    storage_cluster_desc_instance_private_dns = []
  })
}

# Write the storage cluster related inventory.
resource "local_sensitive_file" "write_storage_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.cluster_type == "Storage-only" ? 1 : 0
  filename = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "Azure"
    resource_prefix                           = var.resource_prefix
    vpc_region                                = var.vpc_region
    vpc_availability_zones                    = var.vpc_availability_zones
    scale_version                             = local.scale_version
    filesystem_details                        = local.filesystem_details
    bastion_instance_id                       = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                              = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                   = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_instance_ids              = []
    compute_cluster_instance_private_ips      = []
    compute_cluster_instance_private_dns      = []
    storage_cluster_instance_ids              = [for instance in module.storage_cluster_instances : instance.instance_ids]
    storage_cluster_instance_private_ips      = [for instance in module.storage_cluster_instances : instance.instance_private_ips]
    storage_cluster_with_data_volume_mapping  = local.storage_instance_ips_with_disk_mapping
    storage_cluster_instance_private_dns      = [for instance in module.storage_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_desc_instance_ids         = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids]
    storage_cluster_desc_instance_private_ips = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips]
    storage_cluster_desc_data_volume_mapping  = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
    storage_cluster_desc_instance_private_dns = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_dns_name]
  })
}

# Write combined cluster related inventory.
resource "local_sensitive_file" "write_combined_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? 1 : 0
  filename = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "Azure"
    resource_prefix                           = var.resource_prefix
    vpc_region                                = var.vpc_region
    vpc_availability_zones                    = var.vpc_availability_zones
    scale_version                             = local.scale_version
    filesystem_details                        = local.filesystem_details
    bastion_instance_id                       = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                              = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                   = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_instance_ids              = [for instance in module.compute_cluster_instances : instance.instance_ids]
    compute_cluster_instance_private_ips      = [for instance in module.compute_cluster_instances : instance.instance_private_ips]
    compute_cluster_instance_private_dns      = [for instance in module.compute_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_instance_ids              = [for instance in module.storage_cluster_instances : instance.instance_ids]
    storage_cluster_instance_private_ips      = [for instance in module.storage_cluster_instances : instance.instance_private_ips]
    storage_cluster_with_data_volume_mapping  = local.storage_instance_ips_with_disk_mapping
    storage_cluster_instance_private_dns      = [for instance in module.storage_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_desc_instance_ids         = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids]
    storage_cluster_desc_instance_private_ips = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips]
    storage_cluster_desc_data_volume_mapping  = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
    storage_cluster_desc_instance_private_dns = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_dns_name]
  })
}

# Configure the compute cluster using ansible based on the create_scale_cluster input.
module "compute_cluster_configuration" {
  source                          = "../../../resources/common/compute_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && local.compute_or_combined && var.create_remote_mount_cluster == true ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  memory_size                     = 8
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
  memory_size                     = 5
  max_pagepool_gb                 = 16
  vcpu_count                      = 2
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  max_mbps                        = 50000 * 0.25 # TODO: maximum egress bandwidth limit ranges from 50-200 Gbps
  disk_type                       = jsonencode("None")
  depends_on                      = [module.storage_cluster_instances, resource.local_sensitive_file.write_storage_cluster_inventory]
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
  memory_size                     = 4
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
