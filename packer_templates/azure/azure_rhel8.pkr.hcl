source "azure-arm" "itself" {
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  managed_image_resource_group_name = var.managed_image_resource_group_name
  managed_image_name                = "${var.managed_image_name}-{{timestamp}}"
  ssh_username                      = var.ssh_username
  os_type                           = "Linux"
  os_disk_size_gb                   = var.os_disk_size_gb
  image_publisher                   = var.image_publisher
  image_offer                       = var.image_offer
  image_sku                         = var.image_sku
  image_version                     = var.image_version
  location                          = var.location
  vm_size                           = var.vm_size
  user_assigned_managed_identities  = var.user_assigned_managed_identities

  azure_tags = {
    created_by = "IBM Spectrum Scale packer template"
  }
}
