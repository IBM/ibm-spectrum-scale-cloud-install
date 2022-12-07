/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

locals {
  data_disk_device_names = ["/dev/sdc", "/dev/sdd", "/dev/sde", "/dev/sdf", "/dev/sdg",
  "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk"]
  gpfs_base_rpm_path = fileset(var.spectrumscale_rpms_path, "gpfs.base-*")
  scale_version      = regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0]
}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances > 0 ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances > 0 ? true : false
}

module "compute_cluster_instances" {
  source                       = "../../../resources/azure/compute/vm_0_disk"
  vm_count                     = var.total_compute_cluster_instances
  vm_name_prefix               = format("%s-compute", var.resource_prefix)
  image_publisher              = var.compute_cluster_image_publisher
  image_offer                  = var.compute_cluster_image_offer
  image_sku                    = var.compute_cluster_image_sku
  image_version                = var.compute_cluster_image_version
  subnet_ids                   = var.vnet_compute_cluster_private_subnets
  resource_group_name          = var.resource_group_name
  location                     = var.vnet_location
  vm_size                      = var.compute_cluster_vm_size
  login_username               = var.compute_cluster_login_username
  proximity_placement_group_id = null
  os_disk_caching              = var.compute_cluster_os_disk_caching
  os_storage_account_type      = var.compute_cluster_os_storage_account_type
  user_public_key              = var.create_separate_namespaces == true ? var.compute_cluster_ssh_public_key : var.storage_cluster_ssh_public_key
  meta_private_key             = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key              = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  dns_zone                     = var.compute_cluster_dns_zone
}

module "storage_cluster_instances" {
  source                          = "../../../resources/azure/compute/vm_multiple_disk"
  vm_count                        = var.total_storage_cluster_instances
  vm_name_prefix                  = format("%s-storage", var.resource_prefix)
  image_publisher                 = var.storage_cluster_image_publisher
  image_offer                     = var.storage_cluster_image_offer
  image_sku                       = var.storage_cluster_image_sku
  image_version                   = var.storage_cluster_image_version
  subnet_ids                      = length(var.vnet_availability_zones) > 1 ? slice(var.vnet_storage_cluster_private_subnets, 0, 2) : var.vnet_storage_cluster_private_subnets
  resource_group_name             = var.resource_group_name
  location                        = var.vnet_location
  vm_size                         = var.storage_cluster_vm_size
  login_username                  = var.storage_cluster_login_username
  proximity_placement_group_id    = null
  os_disk_caching                 = var.storage_cluster_os_disk_caching
  os_storage_account_type         = var.storage_cluster_os_storage_account_type
  data_disks_per_storage_instance = var.data_disks_per_storage_instance
  data_disk_device_names          = local.data_disk_device_names
  data_disk_size                  = var.data_disk_size
  data_disk_storage_account_type  = var.data_disk_storage_account_type
  user_public_key                 = var.storage_cluster_ssh_public_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                 = module.generate_storage_cluster_keys.public_key_content
  dns_zone                        = var.storage_cluster_dns_zone
}

module "storage_cluster_tie_breaker_instance" {
  source                          = "../../../resources/azure/compute/vm_multiple_disk"
  vm_count                        = (length(var.vnet_storage_cluster_private_subnets) > 1 && var.total_storage_cluster_instances > 0) ? 1 : 0
  vm_name_prefix                  = format("%s-storage-tie", var.resource_prefix)
  image_publisher                 = var.storage_cluster_image_publisher
  image_offer                     = var.storage_cluster_image_offer
  image_sku                       = var.storage_cluster_image_sku
  image_version                   = var.storage_cluster_image_version
  subnet_ids                      = length(var.vnet_availability_zones) > 1 ? [var.vnet_storage_cluster_private_subnets[2]] : var.vnet_storage_cluster_private_subnets
  resource_group_name             = var.resource_group_name
  location                        = var.vnet_location
  vm_size                         = var.storage_cluster_vm_size
  login_username                  = var.storage_cluster_login_username
  proximity_placement_group_id    = null
  os_disk_caching                 = var.storage_cluster_os_disk_caching
  os_storage_account_type         = var.storage_cluster_os_storage_account_type
  data_disks_per_storage_instance = 1
  data_disk_device_names          = local.data_disk_device_names
  data_disk_size                  = 5
  data_disk_storage_account_type  = var.data_disk_storage_account_type
  user_public_key                 = var.storage_cluster_ssh_public_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                 = module.generate_storage_cluster_keys.public_key_content
  dns_zone                        = var.storage_cluster_dns_zone
}

module "prepare_ansible_configuration" {
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

module "write_compute_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("Azure")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vnet_location)
  vpc_availability_zones                           = jsonencode(var.vnet_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode("None")
  compute_cluster_filesystem_mountpoint            = jsonencode(var.compute_cluster_filesystem_mountpoint)
  bastion_instance_id                              = var.ansible_jump_host_id == null ? jsonencode("None") : jsonencode(var.ansible_jump_host_id)
  bastion_instance_public_ip                       = var.ansible_jump_host_public_ip == null ? jsonencode("None") : jsonencode(var.ansible_jump_host_public_ip)
  compute_cluster_instance_ids                     = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips             = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint            = jsonencode("None")
  storage_cluster_instance_ids                     = jsonencode([])
  storage_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_with_data_volume_mapping         = jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([])
  storage_cluster_desc_instance_private_ips        = jsonencode([])
  storage_cluster_desc_data_volume_mapping         = jsonencode({})
  compute_cluster_instance_private_dns_ip_map      = jsonencode([])
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode([])
  storage_cluster_instance_private_dns_ip_map      = jsonencode([])
}

module "write_storage_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("Azure")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vnet_location)
  vpc_availability_zones                           = jsonencode(var.vnet_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.ansible_jump_host_id == null ? jsonencode("None") : jsonencode(var.ansible_jump_host_id)
  bastion_instance_public_ip                       = var.ansible_jump_host_public_ip == null ? jsonencode("None") : jsonencode(var.ansible_jump_host_public_ip)
  compute_cluster_instance_ids                     = jsonencode([])
  compute_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode(module.storage_cluster_instances.instance_ids)
  storage_cluster_instance_private_ips             = jsonencode(module.storage_cluster_instances.instance_private_ips)
  storage_cluster_with_data_volume_mapping         = jsonencode(module.storage_cluster_instances.instance_ips_with_data_mapping)
  storage_cluster_desc_instance_ids                = jsonencode(module.storage_cluster_tie_breaker_instance.instance_ids)
  storage_cluster_desc_instance_private_ips        = jsonencode(module.storage_cluster_tie_breaker_instance.instance_private_ips)
  storage_cluster_desc_data_volume_mapping         = jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_data_mapping)
  compute_cluster_instance_private_dns_ip_map      = jsonencode([])
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode([])
  storage_cluster_instance_private_dns_ip_map      = jsonencode([])
}

module "write_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = var.create_separate_namespaces == false ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("Azure")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vnet_location)
  vpc_availability_zones                           = jsonencode(var.vnet_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.ansible_jump_host_id == null ? jsonencode("None") : jsonencode(var.ansible_jump_host_id)
  bastion_instance_public_ip                       = var.ansible_jump_host_public_ip == null ? jsonencode("None") : jsonencode(var.ansible_jump_host_public_ip)
  compute_cluster_instance_ids                     = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips             = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode(module.storage_cluster_instances.instance_ids)
  storage_cluster_instance_private_ips             = jsonencode(module.storage_cluster_instances.instance_private_ips)
  storage_cluster_with_data_volume_mapping         = jsonencode(module.storage_cluster_instances.instance_ips_with_data_mapping)
  storage_cluster_desc_instance_ids                = length(var.vnet_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_ids) : jsonencode([])
  storage_cluster_desc_instance_private_ips        = length(var.vnet_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_private_ips) : jsonencode([])
  storage_cluster_desc_data_volume_mapping         = length(var.vnet_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_data_mapping) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = jsonencode([])
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode([])
  compute_cluster_instance_private_dns_ip_map      = jsonencode([])
}

module "compute_cluster_configuration" {
  source                       = "../../../resources/common/compute_configuration"
  turn_on                      = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_compute_cluster_inventory.write_inventory_complete
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  using_rest_initialization    = var.using_rest_api_remote_mount
  compute_cluster_gui_username = var.compute_cluster_gui_username
  compute_cluster_gui_password = var.compute_cluster_gui_password
  memory_size                  = "953"
  bastion_instance_public_ip   = var.ansible_jump_host_public_ip
  bastion_ssh_private_key      = var.ansible_jump_host_ssh_private_key
  meta_private_key             = module.generate_compute_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  max_pagepool_gb              = 4
}

module "storage_cluster_configuration" {
  source                       = "../../../resources/common/storage_configuration"
  turn_on                      = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_storage_cluster_inventory.write_inventory_complete
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  using_rest_initialization    = true
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = "953"
  bastion_instance_public_ip   = var.ansible_jump_host_public_ip
  bastion_ssh_private_key      = var.ansible_jump_host_ssh_private_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
  inventory_format             = var.inventory_format
  max_pagepool_gb              = 16
  vcpu_count                   = 2
  create_scale_cluster         = var.create_scale_cluster
}

module "combined_cluster_configuration" {
  source                       = "../../../resources/common/scale_configuration"
  turn_on                      = var.create_separate_namespaces == false ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_cluster_inventory.write_inventory_complete
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = "953"
  bastion_instance_public_ip   = var.ansible_jump_host_public_ip
  bastion_ssh_private_key      = var.ansible_jump_host_ssh_private_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
}

module "remote_mount_configuration" {
  source                          = "../../../resources/common/remote_mount_configuration"
  turn_on                         = (var.total_compute_cluster_instances > 0 && var.total_storage_cluster_instances > 0 && var.create_separate_namespaces == true) ? true : false
  clone_path                      = var.scale_ansible_repo_clone_path
  compute_inventory_path          = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  compute_gui_inventory_path      = format("%s/compute_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  storage_inventory_path          = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  storage_gui_inventory_path      = format("%s/storage_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  using_direct_connection         = var.using_direct_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  bastion_instance_public_ip      = var.ansible_jump_host_public_ip
  bastion_ssh_private_key         = var.ansible_jump_host_ssh_private_key
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
  create_scale_cluster            = var.create_scale_cluster
}
