/*
    Creates an Azure Private DNS zone.
*/

variable "turn_on" {}
variable "resource_group_name" {}
variable "dns_domain_name" {}

resource "azurerm_private_dns_zone" "itself" {
  count               = tobool(var.turn_on) == true ? 1 : 0
  name                = var.dns_domain_name
  resource_group_name = var.resource_group_name
}

output "private_dns_zone_name" {
  value      = try(azurerm_private_dns_zone.itself[0].name, " ")
  depends_on = [azurerm_private_dns_zone.itself]
}

output "private_dns_zone_id" {
  value = try(azurerm_private_dns_zone.itself[0].id, " ")
}
