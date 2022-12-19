/*
    Create private endpoint for storage service.
*/

variable "name" {}
variable "resource_group_name" {}
variable "resource_prefix" {}
variable "location" {}
variable "subnet_id" {}
variable "private_connection_resource_id" {}

resource "azurerm_private_endpoint" "itself" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = format("%s-priv-conn", var.resource_prefix)
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

output "endpoint_dns_name" {
  value = azurerm_private_endpoint.itself.custom_dns_configs
}
