/*
  Creates compute and storage Google Cloud Platform(GCP) VM clusters.
*/

locals {
  cluster_type = (
    (length(var.vpc_storage_cluster_private_subnets) > 0 && length(var.vpc_compute_cluster_private_subnets) == 0) ? "storage" :
    (length(var.vpc_storage_cluster_private_subnets) == 0 && length(var.vpc_compute_cluster_private_subnets) > 0) ? "compute" :
    (length(var.vpc_storage_cluster_private_subnets) > 0 && length(var.vpc_compute_cluster_private_subnets) > 0) ? "combined" : "none"
  )

  cluster_comp_stg_vm_tags = concat(var.compute_instance_tags, var.storage_instance_tags)

  security_rule_description_bastion = ["Allow ICMP traffic from bastion to scale instances",
  "Allow SSH traffic from bastion to scale instances","Allow SSH traffic from bastion to scale instances"]

  traffic_protocol_bastion = ["icmp", "TCP", "TCP"]
  traffic_port_bastion     = [-1, 22, 65535]

  security_rule_description_cluster_ingress = [
    "Allow ICMP traffic within scale instances",
    "Allow SSH traffic within scale instances",
    "Allow GPFS intra cluster traffic within scale instances",
    "Allow GPFS ephemeral port range within scale instances",
    "Allow management GUI (http/localhost) TCP traffic within scale instances",
    "Allow management GUI (http/localhost) UDP traffic within scale instances",
    "Allow management GUI (https/localhost) TCP traffic within scale instances",
    "Allow management GUI (https/localhost) UDP traffic within scale instances",
    "Allow management GUI (localhost) TCP traffic within scale instances",
    "Allow management GUI (localhost) UDP traffic within scale instances",
    "Allow performance monitoring collector traffic within scale instances",
    "Allow performance monitoring collector traffic within scale instances",
    "Allow performance monitoring collector traffic within scale instances",
    "Allow http traffic within scale instances",
  "Allow https traffic within scale instances"]

  traffic_protocol_cluster_ingress = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_port_cluster_ingress     = [-1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]

  security_rule_description_egress = ["Outgoing traffic from compute and storage cluster"]
  traffic_protocol_egress          = ["TCP"]
  traffic_port_egress              = [6335]


  gpfs_base_rpm_path = var.spectrumscale_rpms_path != null ? fileset(var.spectrumscale_rpms_path, "gpfs.base-*") : null
  scale_version      = local.gpfs_base_rpm_path != null ? regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0] : null

  total_local_ssd_disks  = var.data_disk_type == "local-ssd" ? var.block_devices_per_storage_instance : 0
  total_persistent_disks = var.data_disk_type != "local-ssd" ? var.block_devices_per_storage_instance : 0
}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances != null ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances != null ? true : false
}

module "allow_traffic_bastion_to_scale_cluster" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  count                = length(local.traffic_protocol_bastion)
  turn_on_ingress      = local.cluster_type != "none" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-bastion-${count.index}"
  vpc_name             = var.vpc_name
  source_vm_tags       = var.bastion_instance_tags
  destination_vm_tags  = local.cluster_comp_stg_vm_tags
  protocol             = local.traffic_protocol_bastion[count.index]
  ports                = [local.traffic_port_bastion[count.index]]
  firewall_description = local.security_rule_description_bastion[count.index]
}

module "allow_traffic_compute_instances_internal" {
  source               = "../../../resources/gcp/security/allow_internal"
  turn_on              = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
  firewall_name_prefix = "${var.vpc_name}-compute-ingress"
  vpc_name             = var.vpc_name
  subnet_cidr_range    = var.compute_subnet_cidrs
  vm_tags              = local.cluster_comp_stg_vm_tags
}

module "allow_traffic_storage_instances_internal" {
  source               = "../../../resources/gcp/security/allow_internal"
  turn_on              = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
  firewall_name_prefix = "${var.vpc_name}-storage-ingress"
  vpc_name             = var.vpc_name
  subnet_cidr_range    = var.storage_subnet_cidrs
  vm_tags              = local.cluster_comp_stg_vm_tags
}


module "allow_traffic_scale_cluster" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  count                = length(local.traffic_protocol_cluster_ingress)
  turn_on_ingress      = local.cluster_type != "none" ? true : false
  firewall_name_prefix = "${var.vpc_name}-scale-cluster-ingress-${count.index}"
  vpc_name             = var.vpc_name
  source_vm_tags       = local.cluster_comp_stg_vm_tags
  destination_vm_tags  = local.cluster_comp_stg_vm_tags
  protocol             = local.traffic_protocol_cluster_ingress[count.index]
  ports                = [local.traffic_port_cluster_ingress[count.index]]
  firewall_description = local.security_rule_description_cluster_ingress[count.index]
}

module "allow_traffic_scale_cluster_egress" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  count                = length(local.traffic_protocol_egress)
  turn_on_egress       = local.cluster_type != "none" ? true : false
  firewall_name_prefix = "${var.vpc_name}-cluster-egress-${count.index}"
  vpc_name             = var.vpc_name
  source_vm_tags       = local.cluster_comp_stg_vm_tags
  destination_vm_tags  = local.cluster_comp_stg_vm_tags
  protocol             = local.traffic_protocol_egress[count.index]
  ports                = [local.traffic_port_egress[count.index]]
  firewall_description = local.security_rule_description_egress[count.index]
}

#Creates compute instances
module "compute_cluster_instances" {
  source                        = "../../../resources/gcp/compute/vm_instance"
  vpc_availability_zones        = var.vpc_availability_zones
  ssh_key_path                  = var.compute_cluster_public_key_path
  ssh_user_name                 = var.instances_ssh_user_name
  total_cluster_instances       = local.cluster_type == "compute" || local.cluster_type == "combined" ? var.total_compute_cluster_instances : 0
  total_persistent_disks        = 0
  total_local_ssd_disks         = 0
  instance_name                 = format("%s-compute", var.resource_prefix)
  machine_type                  = var.compute_machine_type
  vpc_subnets                   = var.vpc_compute_cluster_private_subnets
  private_key_content           = module.generate_compute_cluster_keys.private_key_content
  public_key_content            = module.generate_compute_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.compute_instance_tags
  boot_disk_size                = var.compute_boot_disk_size
  boot_disk_type                = var.compute_boot_disk_type
  boot_image                    = var.compute_boot_image
}

module "storage_cluster_tie_breaker_instance" {
  source                        = "../../../resources/gcp/compute/vm_instance"
  vpc_availability_zones        = var.vpc_availability_zones
  ssh_key_path                  = var.storage_cluster_public_key_path
  ssh_user_name                 = var.instances_ssh_user_name
  total_cluster_instances       = var.vpc_storage_cluster_private_subnets != null ? ((length(var.vpc_storage_cluster_private_subnets) > 1 && (local.cluster_type == "storage" || local.cluster_type == "combined")) ? 1 : 0) : 0
  total_persistent_disks        = 5
  total_local_ssd_disks         = 0
  instance_name                 = format("%s-storage-tie", var.resource_prefix)
  machine_type                  = var.storage_cluster_instance_type
  vpc_subnets                   = var.vpc_storage_cluster_private_subnets
  private_key_content           = module.generate_storage_cluster_keys.private_key_content
  public_key_content            = module.generate_storage_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.storage_instance_tags
  boot_disk_size                = var.storage_boot_disk_size
  boot_disk_type                = var.storage_boot_disk_type
  boot_image                    = var.storage_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.block_device_volume_size
}

#Creates storage instances
module "storage_cluster_instances" {
  source                        = "../../../resources/gcp/compute/vm_instance"
  vpc_availability_zones        = var.vpc_availability_zones
  ssh_key_path                  = var.storage_cluster_public_key_path
  ssh_user_name                 = var.instances_ssh_user_name
  total_cluster_instances       = local.cluster_type == "storage" || local.cluster_type == "combined" ? var.total_storage_cluster_instances : 0
  total_persistent_disks        = local.total_persistent_disks
  total_local_ssd_disks         = local.total_local_ssd_disks
  instance_name                 = format("%s-storage", var.resource_prefix)
  machine_type                  = var.storage_cluster_instance_type
  vpc_subnets                   = var.vpc_storage_cluster_private_subnets
  private_key_content           = module.generate_storage_cluster_keys.private_key_content
  public_key_content            = module.generate_storage_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.storage_instance_tags
  boot_disk_size                = var.storage_boot_disk_size
  boot_disk_type                = var.storage_boot_disk_type
  boot_image                    = var.storage_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.block_device_volume_size
}

module "prepare_ansible_configuration" {
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

# Write the compute cluster related inventory.
module "write_compute_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == true && local.cluster_type == "compute") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode("None")
  compute_cluster_filesystem_mountpoint            = jsonencode(var.compute_cluster_filesystem_mountpoint)
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(flatten(module.compute_cluster_instances[*].instance_ids))
  compute_cluster_instance_private_ips             = jsonencode(flatten(module.compute_cluster_instances[*].instance_ips))
  compute_cluster_instance_private_dns_ip_map      = length(module.compute_cluster_instances) > 0 ? jsonencode(module.compute_cluster_instances[*].dns_hostname) : jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode("None")
  storage_cluster_instance_ids                     = jsonencode([])
  storage_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_with_data_volume_mapping         = jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([])
  storage_cluster_desc_instance_private_ips        = jsonencode([])
  storage_cluster_desc_data_volume_mapping         = jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode({})
}

# Write the storage cluster related inventory.
module "write_storage_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == true && local.cluster_type == "storage") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode([])
  compute_cluster_instance_private_ips             = jsonencode([])
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode(flatten(module.storage_cluster_instances[*].instance_ids))
  storage_cluster_instance_private_ips             = jsonencode(flatten(module.storage_cluster_instances[*].instance_ips))
  storage_cluster_with_data_volume_mapping         = length(module.storage_cluster_instances) > 0 ? jsonencode(module.storage_cluster_instances[*].disk_device_mapping) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = length(module.storage_cluster_instances) > 0 ? jsonencode(module.storage_cluster_instances[*].dns_hostname) : jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode(flatten(module.storage_cluster_tie_breaker_instance[*].instance_ids))
  storage_cluster_desc_instance_private_ips        = jsonencode(module.storage_cluster_tie_breaker_instance[*].instance_ips)
  storage_cluster_desc_data_volume_mapping         = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode(flatten(module.storage_cluster_tie_breaker_instance[*].disk_device_mapping)) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode(flatten(module.storage_cluster_tie_breaker_instance[*].dns_hostname)) : jsonencode({})
}

# Write combined cluster related inventory.
module "write_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == false && local.cluster_type == "combined") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(flatten(module.compute_cluster_instances[*].instance_ids))
  compute_cluster_instance_private_ips             = jsonencode(flatten(module.compute_cluster_instances[*].instance_ips))
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode(flatten(module.storage_cluster_instances[*].instance_ids))
  storage_cluster_instance_private_ips             = jsonencode(flatten(module.storage_cluster_instances[*].instance_ips))
  storage_cluster_with_data_volume_mapping         = length(module.storage_cluster_instances) > 0 ? jsonencode(module.storage_cluster_instances[*].disk_device_mapping) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = length(module.storage_cluster_instances) > 0 ? jsonencode(module.storage_cluster_instances[*].dns_hostname) : jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode(flatten(module.storage_cluster_tie_breaker_instance[*].instance_ids))
  storage_cluster_desc_instance_private_ips        = jsonencode(module.storage_cluster_tie_breaker_instance[*].instance_ips)
  storage_cluster_desc_data_volume_mapping         = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode(module.storage_cluster_tie_breaker_instance[*].disk_device_mapping) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode(module.storage_cluster_tie_breaker_instance[*].dns_hostname) : jsonencode({})
}


# Configure the storage cluster using ansible based on the create_scale_cluster input.
module "storage_cluster_configuration" {
  source                       = "../../../resources/common/storage_configuration"
  turn_on                      = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_storage_cluster_inventory.write_inventory_complete
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  using_rest_initialization    = true
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = 5
  max_pagepool_gb              = 16
  vcpu_count                   = 2
  bastion_user                 = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip   = var.bastion_instance_public_ip
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
  depends_on                   = [module.storage_cluster_instances]
}