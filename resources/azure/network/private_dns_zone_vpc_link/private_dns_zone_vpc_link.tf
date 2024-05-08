/*
    Enables Private DNS zone Virtual Network Links.
*/

variable "turn_on" {}
variable "resource_group_name" {}
variable "vnet_zone_link_name" {}
variable "private_dns_zone_name" {}
variable "vnet_id" {}

resource "azurerm_private_dns_zone_virtual_network_link" "itself" {
  count                 = tobool(var.turn_on) == true ? 1 : 0
  name                  = var.vnet_zone_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = var.vnet_id
}

output "association_id" {
  value = try(azurerm_private_dns_zone_virtual_network_link.itself[0].id, null)
}
