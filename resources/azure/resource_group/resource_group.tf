/*
    Creates specified Azure resource group name.
*/

variable "resource_group_name" {}
variable "location" {}

resource "azurerm_resource_group" "itself" {
  name     = var.resource_group_name
  location = var.location
}

output "resource_group_name" {
  value      = var.resource_group_name
  depends_on = [azurerm_resource_group.itself]
}
