/*
  Creates compute and storage Google Cloud Platform(GCP) VM clusters.
*/

# Generate compute cluster ssh keys
module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances != null ? true : false
}

# Generate storage cluster ssh keys
module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances != null ? true : false
}

# Allow scale/gpfs traffic within the scale vm(s)
module "allow_traffic_within_scale_vms" {
  source               = "../../../resources/gcp/security/security_group_tag"
  turn_on              = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  firewall_name_prefix = format("%s-cluster-tag", var.resource_prefix)
  firewall_description = "Allow traffic within scale instances"
  vpc_ref              = var.vpc_ref
  source_tags          = [local.scale_cluster_network_tag]
  target_tags          = [local.scale_cluster_network_tag]
  tcp_ports            = local.tcp_port_scale_cluster
  udp_ports            = local.udp_port_scale_cluster
}

# Create security rules to enable scale communication between bastion and scale instances
module "cluster_ingress_security_rule_using_jumphost_connection" {
  source               = "../../../resources/gcp/security/security_group_tag"
  turn_on              = var.using_jumphost_connection ? true : false
  firewall_name_prefix = format("%s-bastion-to-cluster", var.resource_prefix)
  firewall_description = "Allow traffic betwen bastion instances and scale instances"
  vpc_ref              = var.vpc_ref
  source_tags          = [var.bastion_security_group_ref]
  target_tags          = [local.scale_cluster_network_tag]
  tcp_ports            = ["22", "443"]
  udp_ports            = []
}

# Create security rules to enable scale communication between cloud-vm and scale instances
module "cluster_ingress_security_rule_using_cloud_connection" {
  source               = "../../../resources/gcp/security/security_group_tag"
  turn_on              = var.using_cloud_connection ? true : false
  firewall_name_prefix = format("%s-cloudvm-to-cluster", var.resource_prefix)
  firewall_description = "Allow traffic betwen cloudvm instances and scale instances"
  vpc_ref              = var.vpc_ref
  source_tags          = [var.client_security_group_ref]
  target_tags          = [local.scale_cluster_network_tag]
  tcp_ports            = ["22", "443"]
  udp_ports            = []
}

module "compute_dns_zone" {
  source      = "../../../resources/gcp/network/cloud_dns"
  turn_on     = (var.cluster_type == "Compute-only" && var.use_clouddns && var.create_clouddns) ? true : false
  zone_name   = var.resource_prefix
  dns_name    = format("%s.", var.vpc_compute_cluster_dns_domain) # Trailing dot is required.
  vpc_network = var.vpc_ref
  description = "Private DNS Zone for IBM Storage Scale compute instances DNS communication."
}

module "reverse_dns_zone" {
  source    = "../../../resources/gcp/network/cloud_dns"
  turn_on   = (var.use_clouddns && var.create_clouddns) ? true : false
  zone_name = format("%s-reverse", var.resource_prefix)
  # Prepare the reverse DNS zone name using first oclet of vpc.
  # Ex: vpc cidr = 10.0.0.0/24, then dns_name = 10.in-addr.arpa.
  # Trailing dot is required
  dns_name    = format("%s.%s", try(split(".", cidrsubnet(var.cluster_type == "Compute-only" ? var.vpc_compute_cluster_private_subnets_cidr_block : var.vpc_storage_cluster_private_subnets_cidr_block, 8, 0))[0], ""), "in-addr.arpa.")
  vpc_network = var.vpc_ref
  description = "Reverse Private DNS Zone for IBM Storage Scale instances DNS communication."
}

# Creates compute instances
module "compute_cluster_instances" {
  for_each                     = local.compute_vm_subnet_map
  source                       = "../../../resources/gcp/compute/vm_instance_0_disk"
  instance_name                = each.key
  zone                         = each.value["zone"]
  subnet_name                  = each.value["subnet"]
  vpc_region                   = var.vpc_region
  is_multizone                 = length(var.vpc_availability_zones) > 1 ? true : false
  machine_type                 = var.compute_cluster_instance_type
  boot_disk_size               = var.compute_cluster_boot_disk_size
  boot_disk_type               = var.compute_cluster_boot_disk_type
  boot_image                   = var.compute_cluster_image_ref
  root_device_kms_key_ring_ref = var.root_device_kms_key_ring_ref # Root volume custom encryption
  root_device_kms_key_ref      = var.root_device_kms_key_ref      # Root volume custom encryption
  ssh_user_name                = var.instances_ssh_user_name
  ssh_public_key_path          = var.compute_cluster_public_key_path
  private_key_content          = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  public_key_content           = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  use_clouddns                 = var.use_clouddns
  vpc_forward_dns_zone         = var.vpc_forward_dns_zone
  vpc_dns_domain               = var.vpc_compute_cluster_dns_domain
  vpc_reverse_dns_zone         = var.vpc_reverse_dns_zone
  vpc_reverse_dns_domain       = format("%s.%s", try(split(".", cidrsubnet(var.vpc_compute_cluster_private_subnets_cidr_block, 8, 0))[0], ""), "in-addr.arpa.")
  service_email                = var.service_email
  scopes                       = var.scopes
  network_tags                 = var.using_direct_connection ? null : [local.scale_cluster_network_tag]
  depends_on                   = [module.allow_traffic_within_scale_vms, module.cluster_ingress_security_rule_using_jumphost_connection, module.cluster_ingress_security_rule_using_cloud_connection, module.compute_dns_zone, module.reverse_dns_zone]
}

module "storage_dns_zone" {
  source      = "../../../resources/gcp/network/cloud_dns"
  turn_on     = var.use_clouddns && var.create_clouddns && local.storage_or_combined ? true : false
  zone_name   = var.resource_prefix
  dns_name    = format("%s.", var.vpc_storage_cluster_dns_domain) # Trailing dot is required.
  vpc_network = var.vpc_ref
  description = "Private DNS Zone for IBM Storage Scale storage instances DNS communication."
}

# Creates storage instances
module "storage_cluster_instances" {
  for_each                     = local.storage_vm_zone_map
  source                       = "../../../resources/gcp/compute/vm_instance_multiple_disk"
  instance_name                = each.key
  zone                         = each.value["zone"]
  subnet_name                  = each.value["subnet"]
  disk                         = each.value["disks"]
  total_local_ssd_disks        = var.scratch_devices_per_storage_instance
  vpc_region                   = var.vpc_region
  is_multizone                 = length(var.vpc_availability_zones) > 1 ? true : false
  machine_type                 = var.storage_cluster_instance_type
  ssh_public_key_path          = var.storage_cluster_public_key_path
  ssh_user_name                = var.instances_ssh_user_name
  physical_block_size_bytes    = var.physical_block_size_bytes
  data_disk_description        = format("This data disk is created by IBM Storage Scale and is used by %s.", var.resource_prefix)
  private_key_content          = module.generate_storage_cluster_keys.private_key_content
  public_key_content           = module.generate_storage_cluster_keys.public_key_content
  boot_disk_size               = var.storage_cluster_boot_disk_size
  boot_disk_type               = var.storage_cluster_boot_disk_type
  boot_image                   = var.storage_cluster_image_ref
  root_device_kms_key_ring_ref = var.root_device_kms_key_ring_ref
  root_device_kms_key_ref      = var.root_device_kms_key_ref
  use_clouddns                 = var.use_clouddns
  vpc_forward_dns_zone         = var.vpc_forward_dns_zone
  vpc_dns_domain               = var.vpc_storage_cluster_dns_domain
  vpc_reverse_dns_zone         = var.vpc_reverse_dns_zone
  vpc_reverse_dns_domain       = format("%s.%s", try(split(".", cidrsubnet(var.vpc_storage_cluster_private_subnets_cidr_block, 8, 0))[0], ""), "in-addr.arpa.")
  service_email                = var.service_email
  scopes                       = var.scopes
  network_tags                 = var.using_direct_connection ? null : [local.scale_cluster_network_tag]
  depends_on                   = [module.allow_traffic_within_scale_vms, module.cluster_ingress_security_rule_using_jumphost_connection, module.cluster_ingress_security_rule_using_cloud_connection, module.storage_dns_zone, module.reverse_dns_zone]
}

# Creates storage tie breaker instance
module "storage_cluster_tie_breaker_instance" {
  for_each                     = local.storage_tie_vm_zone_map
  source                       = "../../../resources/gcp/compute/vm_instance_multiple_disk"
  instance_name                = each.key
  zone                         = each.value["zone"]
  subnet_name                  = each.value["subnet"]
  disk                         = each.value["disks"]
  total_local_ssd_disks        = 0
  vpc_region                   = var.vpc_region
  is_multizone                 = length(var.vpc_availability_zones) > 1 ? true : false
  machine_type                 = var.storage_cluster_instance_type
  ssh_public_key_path          = var.storage_cluster_public_key_path
  ssh_user_name                = var.instances_ssh_user_name
  physical_block_size_bytes    = var.physical_block_size_bytes
  data_disk_description        = format("This data disk is created by IBM Storage Scale and is used by %s.", var.resource_prefix)
  private_key_content          = module.generate_storage_cluster_keys.private_key_content
  public_key_content           = module.generate_storage_cluster_keys.public_key_content
  boot_disk_size               = var.storage_cluster_boot_disk_size
  boot_disk_type               = var.storage_cluster_boot_disk_type
  boot_image                   = var.storage_cluster_image_ref
  root_device_kms_key_ring_ref = var.root_device_kms_key_ring_ref
  root_device_kms_key_ref      = var.root_device_kms_key_ref
  use_clouddns                 = var.use_clouddns
  vpc_forward_dns_zone         = var.vpc_forward_dns_zone
  vpc_dns_domain               = var.vpc_storage_cluster_dns_domain
  vpc_reverse_dns_zone         = var.vpc_reverse_dns_zone
  vpc_reverse_dns_domain       = format("%s.%s", try(split(".", cidrsubnet(var.vpc_storage_cluster_private_subnets_cidr_block, 8, 0))[0], ""), "in-addr.arpa.")
  service_email                = var.service_email
  scopes                       = var.scopes
  network_tags                 = var.using_direct_connection ? null : [local.scale_cluster_network_tag]
  depends_on                   = [module.allow_traffic_within_scale_vms, module.cluster_ingress_security_rule_using_jumphost_connection, module.cluster_ingress_security_rule_using_cloud_connection, module.storage_dns_zone, module.reverse_dns_zone]
}

module "gateway_instances" {
  for_each                     = local.gateway_vm_subnet_map
  source                       = "../../../resources/gcp/compute/vm_instance_0_disk"
  instance_name                = each.key
  zone                         = each.value["zone"]
  subnet_name                  = each.value["subnet"]
  vpc_region                   = var.vpc_region
  is_multizone                 = length(var.vpc_availability_zones) > 1 ? true : false
  machine_type                 = var.gateway_instance_type
  boot_disk_size               = var.storage_cluster_boot_disk_size
  boot_disk_type               = var.storage_cluster_boot_disk_type
  boot_image                   = var.storage_cluster_image_ref
  root_device_kms_key_ring_ref = var.root_device_kms_key_ring_ref # Root volume custom encryption
  root_device_kms_key_ref      = var.root_device_kms_key_ref      # Root volume custom encryption
  ssh_user_name                = var.instances_ssh_user_name
  ssh_public_key_path          = var.storage_cluster_public_key_path
  private_key_content          = module.generate_storage_cluster_keys.private_key_content
  public_key_content           = module.generate_storage_cluster_keys.public_key_content
  use_clouddns                 = var.use_clouddns
  vpc_forward_dns_zone         = var.vpc_forward_dns_zone
  vpc_dns_domain               = var.vpc_storage_cluster_dns_domain
  vpc_reverse_dns_zone         = var.vpc_reverse_dns_zone
  vpc_reverse_dns_domain       = format("%s.%s", try(split(".", cidrsubnet(var.vpc_storage_cluster_private_subnets_cidr_block, 8, 0))[0], ""), "in-addr.arpa.")
  service_email                = var.service_email
  scopes                       = var.scopes
  network_tags                 = var.using_direct_connection ? null : [local.scale_cluster_network_tag]
  depends_on                   = [module.allow_traffic_within_scale_vms, module.cluster_ingress_security_rule_using_jumphost_connection, module.cluster_ingress_security_rule_using_cloud_connection, module.storage_dns_zone, module.reverse_dns_zone]
}

module "protocol_instances" {
  for_each                     = local.protocol_vm_subnet_map
  source                       = "../../../resources/gcp/compute/vm_instance_0_disk"
  instance_name                = each.key
  zone                         = each.value["zone"]
  subnet_name                  = each.value["subnet"]
  vpc_region                   = var.vpc_region
  is_multizone                 = length(var.vpc_availability_zones) > 1 ? true : false
  machine_type                 = var.protocol_instance_type
  boot_disk_size               = var.storage_cluster_boot_disk_size
  boot_disk_type               = var.storage_cluster_boot_disk_type
  boot_image                   = var.storage_cluster_image_ref
  root_device_kms_key_ring_ref = var.root_device_kms_key_ring_ref
  root_device_kms_key_ref      = var.root_device_kms_key_ref
  ssh_user_name                = var.instances_ssh_user_name
  ssh_public_key_path          = var.storage_cluster_public_key_path
  private_key_content          = module.generate_storage_cluster_keys.private_key_content
  public_key_content           = module.generate_storage_cluster_keys.public_key_content
  use_clouddns                 = var.use_clouddns
  vpc_forward_dns_zone         = var.vpc_forward_dns_zone
  vpc_dns_domain               = var.vpc_storage_cluster_dns_domain
  vpc_reverse_dns_zone         = var.vpc_reverse_dns_zone
  vpc_reverse_dns_domain       = format("%s.%s", try(split(".", cidrsubnet(var.vpc_storage_cluster_private_subnets_cidr_block, 8, 0))[0], ""), "in-addr.arpa.")
  service_email                = var.service_email
  scopes                       = var.scopes
  network_tags                 = var.using_direct_connection ? null : [local.scale_cluster_network_tag]
  depends_on                   = [module.allow_traffic_within_scale_vms, module.cluster_ingress_security_rule_using_jumphost_connection, module.cluster_ingress_security_rule_using_cloud_connection, module.storage_dns_zone, module.reverse_dns_zone]
}

# Prepare ansible config
module "prepare_ansible_configuration" {
  turn_on    = true
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

locals {
  storage_cluster_private_ips      = local.storage_or_combined ? [for instance in module.storage_cluster_instances : instance.instance_private_ips] : []
  storage_cluster_desc_private_ips = local.storage_or_combined && length(var.vpc_availability_zones) > 1 ? [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips] : []
}

# Write the compute cluster related inventory.
resource "local_sensitive_file" "write_compute_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster && var.cluster_type == "Compute-only" ? 1 : 0
  filename = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "GCP"
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
    compute_cluster_instance_zone_mapping     = local.compute_instance_ip_with_zone_mapping
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
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == true && var.cluster_type == "Storage-only" ? 1 : 0
  filename = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "GCP"
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
    compute_cluster_instance_zone_mapping     = local.compute_instance_ip_with_zone_mapping
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
    cloud_platform                            = "GCP"
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
    compute_cluster_instance_zone_mapping     = local.compute_instance_ip_with_zone_mapping
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
