/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances > 0 ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances > 0 ? true : false
}

data "azurerm_ssh_public_key" "compute_cluster_key" {
  name                = var.compute_cluster_key_pair
  resource_group_name = var.resource_group_name
}

data "azurerm_ssh_public_key" "storage_cluster_key" {
  name                = var.storage_cluster_key_pair
  resource_group_name = var.resource_group_name
}

module "get_azure_public_key" {
  source = "../../../resources/azure/"
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
  user_public_key              = var.create_separate_namespaces == true ? data.azurerm_ssh_public_key.compute_cluster_key.public_key : data.azurerm_ssh_public_key.storage_cluster_key.public_key
  meta_private_key             = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key              = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
}

module "storage_cluster_instances" {
  source                       = "../../../resources/azure/compute/vm_multiple_disk"
  vm_count                     = var.total_storage_cluster_instances
  vm_name_prefix               = format("%s-storage", var.resource_prefix)
  image_publisher              = var.storage_cluster_image_publisher
  image_offer                  = var.storage_cluster_image_offer
  image_sku                    = var.storage_cluster_image_sku
  image_version                = var.storage_cluster_image_version
  subnet_ids                   = length(var.vnet_availability_zones) > 1 ? slice(var.vnet_storage_cluster_private_subnets, 0, 2) : var.vnet_storage_cluster_private_subnets
  resource_group_name          = var.resource_group_name
  location                     = var.vnet_location
  vm_size                      = var.storage_cluster_vm_size
  login_username               = var.storage_cluster_login_username
  proximity_placement_group_id = null
  os_disk_caching              = var.storage_cluster_os_disk_caching
  os_storage_account_type      = var.storage_cluster_os_storage_account_type
  user_public_key              = data.azurerm_ssh_public_key.storage_cluster_key.public_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  meta_public_key              = module.generate_storage_cluster_keys.public_key_content
}

module "prepare_ansible_configuration" {
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

module "write_compute_cluster_inventory" {
  source                                    = "../../../resources/common/write_inventory"
  write_inventory                           = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? 1 : 0
  clone_complete                            = module.prepare_ansible_configuration.clone_complete
  inventory_path                            = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("Azure")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vnet_location)
  vpc_availability_zones                    = jsonencode(var.vnet_availability_zones)
  scale_version                             = jsonencode(var.scale_version)
  filesystem_block_size                     = jsonencode("None")
  compute_cluster_filesystem_mountpoint     = jsonencode(var.compute_cluster_filesystem_mountpoint)
  compute_cluster_instance_ids              = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips      = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint     = jsonencode("None")
  storage_cluster_instance_ids              = jsonencode([])
  storage_cluster_instance_private_ips      = jsonencode([])
  storage_cluster_with_data_volume_mapping  = jsonencode({})
  storage_cluster_desc_instance_ids         = jsonencode([])
  storage_cluster_desc_instance_private_ips = jsonencode([])
  storage_cluster_desc_data_volume_mapping  = jsonencode({})
}
