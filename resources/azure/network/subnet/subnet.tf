/*
    Creates specitifed number of Azure subnets.
*/

variable "vnet_name" {
    type = string
}
variable "subnet_address_prefix" {
    type = string
}
variable "subnet_name" {
    type = string
}
variable "resource_group_name" {
    type = string
}

resource "azurerm_subnet" "subnet" {
    name                 = var.subnet_name
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefix       = var.subnet_address_prefix
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
}

output "subnet_name" {
    value = azurerm_subnet.subnet.name
}
