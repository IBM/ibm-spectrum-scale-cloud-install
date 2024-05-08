/*
    Creates an Azure Private DNS zone.
*/

variable "turn_on" {}
variable "resource_group_name" {}
variable "zone_name" {}

resource "azurerm_private_dns_zone" "itself" {
  count               = tobool(var.turn_on) == true ? 1 : 0
  name                = var.zone_name
  resource_group_name = var.resource_group_name
}

output "zone_id" {
  value = try(azurerm_private_dns_zone.itself[0].id, null)
}
