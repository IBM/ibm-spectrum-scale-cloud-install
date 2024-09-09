/*
    Creates a new nat gateway.
*/

variable "name" {}
variable "turn_on" {}
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_nat_gateway" "itself" {
  count                   = var.turn_on ? 1 : 0
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

output "nat_gateway_id" {
  value = try(azurerm_nat_gateway.itself[*].id, null)
}
