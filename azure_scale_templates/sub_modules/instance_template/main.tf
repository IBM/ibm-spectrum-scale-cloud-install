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
  subnet_ids                   = ["/subscriptions/e652d8de-aea2-4177-a0f1-7117adc604ee/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vnet/subnets/spectrum-scale-comp-snet"]
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
