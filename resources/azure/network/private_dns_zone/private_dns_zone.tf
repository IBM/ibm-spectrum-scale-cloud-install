/*
    Creates an Azure Private DNS zone.
*/

variable "resource_group_name" {
  type = string
}
variable "dns_domain_name" {
  type = string
}


resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.dns_domain_name
  resource_group_name = var.resource_group_name
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.private_dns_zone.id
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.private_dns_zone.name
}
