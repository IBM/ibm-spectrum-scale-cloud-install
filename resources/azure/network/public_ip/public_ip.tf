/*
    Creates an Public ip.
*/

variable "public_ip_name" {}
variable "resource_group_name" {}
variable "location" {}

resource "azurerm_public_ip" "itself" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1"]
}

output "id" {
  value = azurerm_public_ip.itself.id
}

output "public_ip" {
  value = azurerm_public_ip.itself.ip_address
}

output "public_ip_zone" {
  value = azurerm_public_ip.itself.zones
}
