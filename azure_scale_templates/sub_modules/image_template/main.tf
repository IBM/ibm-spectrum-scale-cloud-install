/*
    Creates Azure Linux Virtual Machine Image for Spectrum scale.
    - Creates Linux Virtual Machine
    - Uses cloud-init script to provision spectrum scale rpms
    - Wait till cloud-init script completes
    - Create image
 */

# Create scale image vm
module "create_image_vm" {
  source                  = "../../../resources/azure/compute/image_vm"
  vm_name                 = var.resource_prefix
  image_publisher         = var.image_publisher
  image_offer             = var.image_offer
  image_sku               = var.image_sku
  image_version           = var.image_version
  resource_group_name     = var.resource_group_name
  location                = var.vpc_region
  vm_size                 = var.vm_size
  subnet_id               = var.subnet_id
  login_username          = var.login_username
  os_disk_caching         = var.os_disk_caching
  os_storage_account_type = var.os_storage_account_type
  user_public_key         = var.user_public_key
  user_private_key        = var.user_private_key
  dns_zone                = var.dns_zone
  availability_zone       = var.availability_zone
  createimage             = var.createimage
  storage_account         = var.storage_account
  blob_container          = var.blob_container
  client_secret           = var.client_secret
  tenant_id               = var.tenant_id
  client_id               = var.client_id
  subscription_id         = var.subscription_id
  gpfs_version            = var.gpfs_version
  zimon_os_dir            = var.zimon_os_dir
}

resource "null_resource" "vm_deallocate" {
  count = var.skip_cli_generalize_vm == false ? var.createimage ? 1 : 0 : 0
  provisioner "local-exec" {
    command = "az vm deallocate --resource-group ${var.resource_group_name} --name ${module.create_image_vm.instance_name}"
  }
  depends_on = [module.create_image_vm]
}

resource "null_resource" "vm_generalize" {
  count = var.skip_cli_generalize_vm == false ? var.createimage ? 1 : 0 : 0
  provisioner "local-exec" {
    command = "az vm generalize --resource-group ${var.resource_group_name} --name ${module.create_image_vm.instance_name}"
  }
  depends_on = [null_resource.vm_deallocate]
}

# Create Image
resource "azurerm_image" "scale_image" {
  count                     = var.createimage ? 1 : 0
  name                      = "scale-image-${module.create_image_vm.instance_random_suffix}"
  location                  = var.vpc_region
  resource_group_name       = var.resource_group_name
  source_virtual_machine_id = module.create_image_vm.instance_id
  depends_on                = [null_resource.vm_generalize]
}
