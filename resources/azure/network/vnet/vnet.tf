/*
    Creates a new Azure VNet.
*/

variable "vnet_name" {}
variable "vnet_location" {}
variable "resource_group_name" {}
variable "vnet_address_space" {}
variable "vnet_tags" {}

resource "azurerm_virtual_network" "itself" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.vnet_tags
}

output "vnet_name" {
  value      = var.vnet_name
  depends_on = [azurerm_virtual_network.itself]
}

output "vnet_id" {
  value = azurerm_virtual_network.itself.id
}
