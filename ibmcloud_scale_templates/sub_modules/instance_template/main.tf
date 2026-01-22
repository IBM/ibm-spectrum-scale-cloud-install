/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

data "ibm_resource_group" "itself" {
  name = var.resource_group_name
}

data "ibm_is_vpc" "itself" {
  name = var.vpc_ref
}

# Get all zones in a DNS Services instance
data "ibm_dns_zones" "all" {
  instance_id = var.service_instance_ref
}

data "ibm_is_instance_profile" "storage_profile" {
  count = local.storage_or_combined ? 1 : 0
  name  = var.storage_cluster_instance_type
}

data "ibm_is_instance_profile" "compute_profile" {
  count = local.compute_or_combined ? 1 : 0
  name  = var.compute_cluster_instance_type
}

locals {
  # Disk list associated with the instance
  disks = local.storage_or_combined ? try(data.ibm_is_instance_profile.storage_profile[0].disks, []) : []

  # Get the disk quantity or value
  disk_quantities = [
    for d in local.disks :
    tonumber(coalesce(try(d.quantity[0].value, null), try(d.quantity[0].default, null), 0))
  ]

  # Count the total disk count
  local_block_device_count = length(local.disks) > 0 ? sum(local.disk_quantities) : 0
}

# Extract the zone_id for a specific zone name
locals {
  forward_zone = one([
    for z in data.ibm_dns_zones.all.dns_zones : z
    if z.name == var.vpc_storage_cluster_dns_domain
  ])

  forward_compute_zone = one([
    for z in data.ibm_dns_zones.all.dns_zones : z
    if z.name == var.vpc_compute_cluster_dns_domain
  ])

  /*
  reverse_zone = one([
    for z in data.ibm_dns_zones.all.dns_zones : z
    if z.name == var.vpc_reverse_dns_domain
  ])
*/
}

locals {
  storage_pub_path            = var.storage_cluster_public_key_path
  storage_priv_path           = trimsuffix(local.storage_pub_path, ".pub")
  storage_private_key_content = can(file(local.storage_priv_path)) ? file(local.storage_priv_path) : null

  compute_pub_path            = var.compute_cluster_public_key_path
  compute_priv_path           = trimsuffix(local.compute_pub_path, ".pub")
  compute_private_key_content = can(file(local.compute_priv_path)) ? file(local.compute_priv_path) : null
}

# Create cluster security group
module "cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = "${var.resource_prefix}-scale-sec-group"
  vpc_id            = var.vpc_ref
  resource_group_id = data.ibm_resource_group.itself.id
}

# Create protocol/ces nodes specific security group
module "protocol_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.total_protocol_instances > 0 ? true : false
  sec_group_name    = "${var.resource_prefix}-protocol-sec-group"
  vpc_id            = var.vpc_ref
  resource_group_id = data.ibm_resource_group.itself.id
}

# Create security rules to enable scale/gpfs traffic within compute/storage instances.
module "scale_cluster_ingress_tcp_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  port              = local.tcp_port_scale_cluster
  remote_ip_addr    = module.cluster_security_group.sec_group_id
}

module "scale_cluster_ingress_udp_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_udp_rule"
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  port              = local.udp_port_scale_cluster
  remote_ip_addr    = module.cluster_security_group.sec_group_id
}

module "scale_cluster_ingress_icmp_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_icmp_rule"
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = module.cluster_security_group.sec_group_id
}

# Create security rules to enable jumphost communication to scale cluster
module "scale_cluster_ingress_security_rule_using_jumphost" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = var.using_jumphost_connection ? 1 : 0
  security_group_id        = [module.cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_ref]
}

# Create security rule to enable scale cluster egress communication
module "scale_cluster_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  security_group_ids = module.cluster_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = ["0.0.0.0/0"]
}

# Create ssh key to access the scale storage instance
resource "ibm_is_ssh_key" "storage_ssh_key" {
  count = local.storage_or_combined ? 1 : 0
  name  = "${var.resource_prefix}-storage-cluster-ssh-key"
  #public_key = module.generate_storage_cluster_keys.public_key_content
  public_key = file(var.storage_cluster_public_key_path)
}

# Create ssh key to access the scale compute instance
resource "ibm_is_ssh_key" "compute_ssh_key" {
  count = local.compute_or_combined ? 1 : 0
  name  = "${var.resource_prefix}-compute-cluster-ssh-key"
  #public_key = module.generate_storage_cluster_keys.public_key_content
  public_key = file(var.compute_cluster_public_key_path)
}

module "compute_cluster_instances" {
  for_each                 = local.compute_vm_subnet_map
  source                   = "../../../resources/ibmcloud/compute/vsi_0_vol"
  ami_id                   = var.compute_cluster_image_ref
  dns_domain               = var.vpc_compute_cluster_dns_domain
  dns_services_instance_id = var.service_instance_ref
  forward_dns_zone         = var.vpc_compute_cluster_dns_domain
  forward_dns_zone_id      = local.forward_compute_zone.zone_id
  instance_type            = var.compute_cluster_instance_type
  meta_private_key         = var.create_remote_mount_cluster == true ? local.compute_private_key_content : local.storage_private_key_content
  meta_public_key          = var.create_remote_mount_cluster == true ? local.compute_private_key_content : local.storage_private_key_content
  name_prefix              = each.key
  placement_group          = null
  #reverse_dns_domain    = var.vpc_reverse_dns_domain
  #reverse_dns_zone       = var.vpc_reverse_dns_domain
  #reverse_dns_zone_id    = local.reverse_zone.zone_id
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.compute_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.compute_cluster_tags
  user_public_key                   = ibm_is_ssh_key.compute_ssh_key[0].id
  volume_tags                       = var.compute_cluster_volume_tags
  vpc_id                            = data.ibm_is_vpc.itself.id
  zone                              = var.vpc_availability_zones
}

module "storage_cluster_instances" {
  for_each                 = local.storage_vm_zone_map
  source                   = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  ami_id                   = var.storage_cluster_image_ref
  disks                    = each.value["disks"]
  dns_domain               = var.vpc_storage_cluster_dns_domain
  dns_services_instance_id = var.service_instance_ref
  forward_dns_zone         = var.vpc_storage_cluster_dns_domain
  forward_dns_zone_id      = local.forward_zone.zone_id
  instance_type            = var.storage_cluster_instance_type
  #meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  #meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  meta_private_key = local.storage_private_key_content
  meta_public_key  = var.storage_cluster_public_key_path
  name_prefix      = each.key
  placement_group  = null
  #reverse_dns_domain     = var.vpc_reverse_dns_domain
  #reverse_dns_zone       = var.vpc_reverse_dns_domain
  #reverse_dns_zone_id    = local.reverse_zone.zone_id
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.storage_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.storage_cluster_tags
  user_public_key                   = ibm_is_ssh_key.storage_ssh_key[0].id
  volume_tags                       = var.storage_cluster_volume_tags
  vpc_id                            = data.ibm_is_vpc.itself.id
  zone                              = each.value["zone"]
}

module "storage_cluster_tie_breaker_instance" {
  for_each                 = local.storage_tie_vm_zone_map
  source                   = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  ami_id                   = var.storage_cluster_image_ref
  disks                    = each.value["disks"]
  dns_domain               = var.vpc_storage_cluster_dns_domain
  dns_services_instance_id = var.service_instance_ref
  forward_dns_zone         = var.vpc_storage_cluster_dns_domain
  forward_dns_zone_id      = local.forward_zone.zone_id
  instance_type            = var.storage_cluster_tiebreaker_instance_type
  #meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  #meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  meta_private_key = local.storage_private_key_content
  meta_public_key  = var.storage_cluster_public_key_path
  name_prefix      = each.key
  placement_group  = null
  #reverse_dns_domain     = var.vpc_reverse_dns_domain
  #reverse_dns_zone       = var.vpc_reverse_dns_domain
  #reverse_dns_zone_id    = local.reverse_zone.zone_id
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.storage_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.storage_cluster_tags
  user_public_key                   = ibm_is_ssh_key.storage_ssh_key[0].id
  volume_tags                       = var.storage_cluster_volume_tags
  vpc_id                            = data.ibm_is_vpc.itself.id
  zone                              = each.value["zone"]
}

module "prepare_ansible_configuration" {
  source       = "../../../resources/common/dir_utils"
  ansible_path = var.scale_ansible_repo_clone_path
}

# Write the compute cluster related inventory.
resource "local_sensitive_file" "write_compute_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == true && var.cluster_type == "Compute-only" ? 1 : 0
  filename = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "IBMCloud"
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
    cloud_platform                           = "IBMCloud"
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
    #storage_cluster_desc_details             = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
    storage_cluster_desc_details = [for instance in module.storage_cluster_instances : instance.instance_details]
    #storage_cluster_desc_data_volume_mapping = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
    storage_cluster_desc_data_volume_mapping = length(module.storage_cluster_instances) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
  })
}

# Write combined cluster related inventory.
resource "local_sensitive_file" "write_combined_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? 1 : 0
  filename = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "AWS"
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
  source                       = "../../../resources/common/compute_configuration"
  turn_on                      = module.prepare_ansible_configuration.clone_complete && local.compute_or_combined && var.create_remote_mount_cluster ? true : false
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_jumphost_connection    = var.using_jumphost_connection
  using_rest_initialization    = var.using_rest_api_remote_mount
  compute_cluster_gui_username = var.compute_cluster_gui_username
  compute_cluster_gui_password = var.compute_cluster_gui_password
  memory_size                  = try(tonumber(data.ibm_is_instance_profile.compute_profile[0].memory[0].value), null)
  max_pagepool_gb              = 4
  bastion_user                 = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip   = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key      = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  #meta_private_key                = module.generate_compute_cluster_keys.private_key_content
  meta_private_key                = local.compute_private_key_content
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
  source                       = "../../../resources/common/storage_configuration"
  turn_on                      = module.prepare_ansible_configuration.clone_complete && local.storage_or_combined && var.create_remote_mount_cluster ? true : false
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_jumphost_connection    = var.using_jumphost_connection
  using_rest_initialization    = true
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = try(tonumber(data.ibm_is_instance_profile.storage_profile[0].memory[0].value), null)
  max_pagepool_gb              = 16
  vcpu_count                   = try(tonumber(data.ibm_is_instance_profile.storage_profile[0].vcpu_count[0].value), null)
  bastion_user                 = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip   = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key      = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  #meta_private_key               = module.generate_storage_cluster_keys.private_key_content
  meta_private_key = local.storage_private_key_content
  #meta_public_key                = var.storage_cluster_public_key_path
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  max_mbps                        = local.storage_or_combined ? tonumber(data.ibm_is_instance_profile.storage_profile[0].total_volume_bandwidth[0].value) * 0.25 : 0
  disk_type                       = jsonencode("None")
  depends_on                      = [resource.local_sensitive_file.write_storage_cluster_inventory]
}

# Configure the combined cluster using ansible based on the create_scale_cluster input.
module "combined_cluster_configuration" {
  source                       = "../../../resources/common/scale_configuration"
  turn_on                      = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? true : false
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_jumphost_connection    = var.using_jumphost_connection
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = try(tonumber(data.ibm_is_instance_profile.storage_profile[0].memory[0].value), null)
  bastion_user                 = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip   = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key      = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  #meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  meta_private_key                = local.storage_private_key_content
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
