/*
    Creates specified Azure resource group name.
*/

variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}

resource "azurerm_resource_group" "group" {
  name     = var.resource_group_name
  location = var.location
}

output "resource_group_name" {
  value = azurerm_resource_group.group.name
}

output "resource_location" {
  value = azurerm_resource_group.group.location
}
