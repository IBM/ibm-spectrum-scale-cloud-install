/*
    This module creates an ansible jump host.
    Note: Azure bastion cannot be treated as Jump Host, since one cannot do SSH
          via local machine. It can only accessed via Azure portal, hence we
          needed an ansible jump host.
*/

module "ansible_jump_host" {
  source                       = "../../../resources/azure/compute/jump_host_vm"
  vm_count                     = var.using_direct_connection == true ? 0 : 1
  vm_name_prefix               = var.vm_name_prefix
  image_publisher              = var.image_publisher
  image_offer                  = var.image_offer
  image_sku                    = var.image_sku
  image_version                = var.image_version
  subnet_ids                   = var.subnet_ids
  resource_group_name          = var.resource_group_name
  location                     = var.vnet_location
  vm_size                      = var.vm_size
  login_username               = "azureuser"
  proximity_placement_group_id = null
  os_disk_caching              = var.os_disk_caching
  os_storage_account_type      = var.os_storage_account_type
  user_public_key              = var.vm_public_key
}
