/*
    Creates specitifed number of Azure subnets.
*/

variable "turn_on" {}
variable "vnet_name" {}
variable "address_prefixes" {}
variable "subnet_name_prefix" {}
variable "resource_group_name" {}
variable "service_endpoints" {}

resource "azurerm_subnet" "itself" {
  count                = var.turn_on == true ? length(var.address_prefixes) : 0
  name                 = format("%s-subnet-%s", var.subnet_name_prefix, count.index)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.address_prefixes[count.index]]
  service_endpoints    = var.service_endpoints
}

output "subnet_id" {
  value = azurerm_subnet.itself[*].id
}
