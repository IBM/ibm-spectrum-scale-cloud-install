/*
    Manages a network security group.
*/

variable "security_group_name" {}
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_network_security_group" "itself" {
  name                = var.security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "sec_group_name" {
  value      = var.security_group_name
  depends_on = [azurerm_network_security_group.itself]
}

output "sec_group_id" {
  value = azurerm_network_security_group.itself.id
}
