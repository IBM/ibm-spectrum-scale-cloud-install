source "azure-arm" "itself" {
  client_id                              = var.client_id
  client_secret                          = var.client_secret
  subscription_id                        = var.subscription_id
  tenant_id                              = var.tenant_id
  managed_image_resource_group_name      = var.resource_group_name
  managed_image_name                     = "${var.resource_prefix}-{{timestamp}}"
  ssh_username                           = var.ssh_username
  os_type                                = "Linux"
  os_disk_size_gb                        = var.volume_size
  image_publisher                        = var.image_publisher
  image_offer                            = var.image_offer
  image_sku                              = var.image_sku
  image_version                          = var.image_version
  location                               = var.vpc_region
  vm_size                                = var.instance_type
  virtual_network_name                   = var.vpc_ref
  virtual_network_subnet_name            = var.vpc_subnet_id
  virtual_network_resource_group_name    = var.resource_group_name
  private_virtual_network_with_public_ip = "true"

  azure_tags = {
    created_by = "IBM Spectrum Scale packer template"
  }
}
