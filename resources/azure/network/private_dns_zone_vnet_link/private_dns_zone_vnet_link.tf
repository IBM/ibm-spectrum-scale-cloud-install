/*
    Creates an Azure Private DNS zone.
*/

variable "resource_group_name" {
    type = string
}
variable "zone_vnet_link_name" {
    type = string
}
variable "private_dns_zone_name" {
    type = string
}
variable "vnet_id" {
    type = string
}


resource "azurerm_private_dns_zone_virtual_network_link" "zone_vnet_link" {
    name                  = var.zone_vnet_link_name
    resource_group_name   = var.resource_group_name
    private_dns_zone_name = var.private_dns_zone_name
    virtual_network_id    = var.vnet_id
    # Note: Auto registration is intentionally enabled.
    registration_enabled  = true
}

output "private_dns_zone_vnet_link_name" {
    value = azurerm_private_dns_zone_virtual_network_link.zone_vnet_link.name
}
