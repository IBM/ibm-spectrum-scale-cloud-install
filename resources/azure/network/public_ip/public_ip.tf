/*
    Creates an Public ip.
*/

variable "turn_on" {}
variable "public_ip_name" {}
variable "resource_group_name" {}
variable "location" {}

resource "azurerm_public_ip" "itself" {
  count               = var.turn_on ? 1 : 0
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

output "id" {
  value = try(azurerm_public_ip.itself[0].id, null)
}

output "public_ip" {
  value = try(azurerm_public_ip.itself[0].ip_address, null)
}
