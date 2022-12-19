/*
    Creates a new nat gateway.
*/

variable "name" {}
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_nat_gateway" "itself" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.itself.id
}
