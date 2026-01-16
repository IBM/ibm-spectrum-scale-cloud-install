source "azure-arm" "itself" {
  azure_tags = {
    Name = var.image_description
  }
  build_resource_group_name              = var.resource_group_name
  client_id                              = var.client_id
  client_secret                          = var.client_secret
  communicator                           = "ssh"
  image_offer                            = var.image_offer
  image_publisher                        = var.image_publisher
  image_sku                              = var.image_sku
  image_version                          = var.image_version
  managed_image_name                     = "${var.resource_prefix}-{{timestamp}}"
  managed_image_resource_group_name      = var.resource_group_name
  managed_image_storage_account_type     = var.volume_type
  os_disk_size_gb                        = var.volume_size
  os_type                                = "Linux"
  private_virtual_network_with_public_ip = false
  ssh_bastion_host                       = var.ssh_bastion_host
  ssh_bastion_port                       = var.ssh_bastion_port
  ssh_bastion_private_key_file           = var.ssh_bastion_private_key_file
  ssh_bastion_username                   = var.ssh_bastion_username
  ssh_clear_authorized_keys              = true
  ssh_port                               = var.ssh_port
  ssh_timeout                            = "2m"
  ssh_username                           = var.ssh_username
  subscription_id                        = var.subscription_id
  tenant_id                              = var.tenant_id
  virtual_network_name                   = var.vpc_ref
  virtual_network_resource_group_name    = var.resource_group_name
  virtual_network_subnet_name            = var.vpc_subnet_id
  vm_size                                = var.instance_type
}
