/*
    Nested module to invoke/create;
    1. New Azure VNet
    2. Bastion Access (Login via azure portal)
    3. VM's (storage, compute, Managed disk attachments)
*/

module "vnet_module" {
  source              = "../sub_modules/vnet_template"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_address_space  = var.vnet_address_space
}

module "bastion_module" {
  source                   = "../sub_modules/bastion_template"
  location                 = var.location
  resource_group_name      = module.vnet_module.resource_group_name
  vnet_address_space       = var.vnet_address_space
  template_body            = "../sub_modules/bastion_template/AzureRmBastion_template.json"
  bastion_public_subnet_id = module.vnet_module.bastion_public_subnet_id
}

module "create_compute_vm_nics" {
  source              = "../../resources/azure/network/nic"
  location            = var.location
  nic_config_prefix   = "spectrumscale-compute-config-nic"
  nic_name_prefix     = "spectrumscale-compute-nic"
  resource_group_name = module.vnet_module.resource_group_name
  subnet_id           = module.vnet_module.private_subnet_id
  total_nics          = var.total_compute_vms
}

module "create_storage_vm_nics" {
  source              = "../../resources/azure/network/nic"
  location            = var.location
  nic_config_prefix   = "spectrumscale-storage-config-nic"
  nic_name_prefix     = "spectrumscale-storage-nic"
  resource_group_name = module.vnet_module.resource_group_name
  subnet_id           = module.vnet_module.private_subnet_id
  total_nics          = var.total_storage_vms
}

module "vms_module" {
  source              = "../sub_modules/vm_template"
  availability_zones  = var.availability_zones
  location            = var.location
  resource_group_name = module.vnet_module.resource_group_name

  total_compute_vms       = var.total_compute_vms
  all_compute_nic_ids     = module.create_compute_vm_nics.nic_ids
  compute_vm_os_offer     = var.compute_vm_os_offer
  compute_vm_os_publisher = var.compute_vm_os_publisher
  compute_vm_os_sku       = var.compute_vm_os_sku
  compute_vm_size         = var.compute_vm_size

  vm_osdisk_caching       = var.vm_osdisk_caching
  vm_osdisk_create_option = var.vm_osdisk_create_option
  vm_osdisk_type          = var.vm_osdisk_type

  data_disk_create_option = var.data_disk_create_option
  data_disk_size          = var.data_disk_size
  data_disk_type          = var.data_disk_type
  data_disk_caching       = var.data_disk_caching

  total_storage_vms       = var.total_storage_vms
  all_storage_nic_ids     = module.create_storage_vm_nics.nic_ids
  storage_vm_os_offer     = var.storage_vm_os_offer
  storage_vm_os_publisher = var.storage_vm_os_publisher
  storage_vm_os_sku       = var.storage_vm_os_sku
  storage_vm_size         = var.storage_vm_size
  total_disks_per_vm      = var.total_disks_per_vm

  vm_admin_username       = var.vm_admin_username
  vm_sshlogin_pubkey_path = var.vm_sshlogin_pubkey_path

  private_zone_vnet_link_name = module.vnet_module.private_zone_vnet_link_name
}
