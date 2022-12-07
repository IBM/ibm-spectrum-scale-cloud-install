/*
    Creates a new Azure vpc.
*/

variable "vpc_name" {}
variable "vpc_location" {}
variable "resource_group_name" {}
variable "vpc_address_space" {}
variable "vpc_tags" {}

resource "azurerm_virtual_network" "itself" {
  name                = var.vpc_name
  location            = var.vpc_location
  resource_group_name = var.resource_group_name
  address_space       = var.vpc_address_space
  tags                = var.vpc_tags
}

output "vpc_name" {
  value      = var.vpc_name
  depends_on = [azurerm_virtual_network.itself]
}

output "vpc_id" {
  value = azurerm_virtual_network.itself.id
}
