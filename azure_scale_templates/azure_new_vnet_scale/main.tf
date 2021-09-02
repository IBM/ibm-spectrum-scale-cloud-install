/*
    This nested module creates;
    1. New Azure VNET
    2. Bastion service (for Azure portal login)
    3. Jump host (for Ansible configuration)
    3. (Compute, Storage) Instances along with data disks/Instance store attachments to storage instances
*/

module "vnet" {
  source                                             = "../sub_modules/vnet_template"
  client_id                                          = var.client_id
  client_secret                                      = var.client_secret
  tenant_id                                          = var.tenant_id
  subscription_id                                    = var.subscription_id
  vnet_location                                      = var.vnet_location
  resource_group_name                                = var.resource_group_name
  resource_prefix                                    = var.resource_prefix
  vnet_address_space                                 = var.vnet_address_space
  vnet_public_subnets_address_space                  = var.vnet_public_subnets_address_space
  vnet_storage_cluster_private_subnets_address_space = var.vnet_storage_cluster_private_subnets_address_space
  vnet_compute_cluster_dns_domain                    = var.vnet_compute_cluster_dns_domain
  vnet_storage_cluster_dns_domain                    = var.vnet_storage_cluster_dns_domain
  vnet_create_separate_subnets                       = var.vnet_create_separate_subnets
  vnet_compute_cluster_private_subnets_address_space = var.vnet_compute_cluster_private_subnets_address_space
  vnet_tags                                          = var.vnet_tags
}

module "bastion" {
  source                = "../sub_modules/bastion_template"
  client_id             = var.client_id
  client_secret         = var.client_secret
  tenant_id             = var.tenant_id
  subscription_id       = var.subscription_id
  vnet_location         = var.vnet_location
  resource_group_name   = module.vnet.resource_group_name
  resource_prefix       = var.resource_prefix
  vnet_public_subnet_id = module.vnet.vnet_public_subnets
}

module "ansible_jump_host" {
  source                  = "../sub_modules/ansible_jump_host"
  client_id               = var.client_id
  client_secret           = var.client_secret
  tenant_id               = var.tenant_id
  subscription_id         = var.subscription_id
  using_direct_connection = var.using_direct_connection
  vm_name_prefix          = format("%s-jumphost", var.resource_prefix)
  image_publisher         = var.total_storage_cluster_instances == 0 ? var.compute_cluster_image_publisher : var.storage_cluster_image_publisher
  image_offer             = var.total_storage_cluster_instances == 0 ? var.compute_cluster_image_offer : var.storage_cluster_image_offer
  image_sku               = var.total_storage_cluster_instances == 0 ? var.compute_cluster_image_sku : var.storage_cluster_image_sku
  image_version           = var.total_storage_cluster_instances == 0 ? var.compute_cluster_image_version : var.storage_cluster_image_version
  subnet_ids              = var.total_storage_cluster_instances == 0 ? module.vnet.vnet_compute_cluster_private_subnets : module.vnet.vnet_storage_cluster_private_subnets
  resource_group_name     = module.vnet.resource_group_name
  vnet_location           = var.vnet_location
  vm_size                 = var.total_storage_cluster_instances == 0 ? var.compute_cluster_vm_size : var.storage_cluster_vm_size
  os_disk_caching         = var.total_storage_cluster_instances == 0 ? var.compute_cluster_os_disk_caching : var.storage_cluster_os_disk_caching
  os_storage_account_type = var.total_storage_cluster_instances == 0 ? var.compute_cluster_os_storage_account_type : var.storage_cluster_os_storage_account_type
  vm_public_key           = var.create_separate_namespaces == true ? var.compute_cluster_ssh_public_key : var.storage_cluster_ssh_public_key
}

module "scale_instances" {
  source                                  = "../sub_modules/instance_template"
  client_id                               = var.client_id
  client_secret                           = var.client_secret
  tenant_id                               = var.tenant_id
  subscription_id                         = var.subscription_id
  vnet_location                           = var.vnet_location
  vnet_availability_zones                 = var.vnet_availability_zones
  resource_group_name                     = module.vnet.resource_group_name
  resource_prefix                         = var.resource_prefix
  create_separate_namespaces              = var.create_separate_namespaces
  total_compute_cluster_instances         = var.total_compute_cluster_instances
  compute_cluster_ssh_public_key          = var.compute_cluster_ssh_public_key
  total_storage_cluster_instances         = var.total_storage_cluster_instances
  storage_cluster_ssh_public_key          = var.storage_cluster_ssh_public_key
  vnet_compute_cluster_private_subnets    = module.vnet.vnet_compute_cluster_private_subnets
  vnet_storage_cluster_private_subnets    = module.vnet.vnet_storage_cluster_private_subnets
  compute_cluster_vm_size                 = var.compute_cluster_vm_size
  storage_cluster_vm_size                 = var.storage_cluster_vm_size
  compute_cluster_image_publisher         = var.compute_cluster_image_publisher
  compute_cluster_image_offer             = var.compute_cluster_image_offer
  compute_cluster_image_sku               = var.compute_cluster_image_sku
  compute_cluster_image_version           = var.compute_cluster_image_version
  compute_cluster_os_disk_caching         = var.compute_cluster_os_disk_caching
  compute_cluster_os_storage_account_type = var.compute_cluster_os_storage_account_type
  compute_cluster_login_username          = var.compute_cluster_login_username
  compute_cluster_gui_username            = var.compute_cluster_gui_username
  compute_cluster_gui_password            = var.compute_cluster_gui_password
  compute_cluster_dns_zone                = module.vnet.vnet_compute_private_dns_zone_name
  storage_cluster_image_publisher         = var.storage_cluster_image_publisher
  storage_cluster_image_offer             = var.storage_cluster_image_offer
  storage_cluster_image_sku               = var.storage_cluster_image_sku
  storage_cluster_image_version           = var.storage_cluster_image_version
  storage_cluster_os_disk_caching         = var.storage_cluster_os_disk_caching
  storage_cluster_os_storage_account_type = var.storage_cluster_os_storage_account_type
  storage_cluster_login_username          = var.storage_cluster_login_username
  storage_cluster_gui_username            = var.storage_cluster_gui_username
  storage_cluster_gui_password            = var.storage_cluster_gui_password
  storage_cluster_filesystem_mountpoint   = var.storage_cluster_filesystem_mountpoint
  storage_cluster_dns_zone                = module.vnet.vnet_storage_private_dns_zone_name
  filesystem_block_size                   = var.filesystem_block_size
  data_disks_per_storage_instance         = var.data_disks_per_storage_instance
  data_disk_size                          = var.data_disk_size
  data_disk_storage_account_type          = var.data_disk_storage_account_type
  scale_ansible_repo_clone_path           = var.scale_ansible_repo_clone_path
  compute_cluster_filesystem_mountpoint   = var.compute_cluster_filesystem_mountpoint
  using_direct_connection                 = var.using_direct_connection
  using_packer_image                      = var.using_packer_image
  spectrumscale_rpms_path                 = var.spectrumscale_rpms_path
  ansible_jump_host_public_ip             = module.ansible_jump_host.ansible_jump_host_public_ip
  ansible_jump_host_ssh_private_key       = var.ansible_jump_host_ssh_private_key
}
