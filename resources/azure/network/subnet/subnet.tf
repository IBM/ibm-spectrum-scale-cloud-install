/*
    Creates specitifed number of Azure subnets.
*/

variable "turn_on" {}
variable "vnet_name" {}
variable "subnet_cidr_range" {}
variable "subnet_name" {}
variable "resource_group_name" {}

resource "azurerm_subnet" "itself" {
  count                = var.turn_on == true ? length(var.subnet_cidr_range) : 0
  name                 = format("%s-%s", var.subnet_name, count.index)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_cidr_range[count.index]]
  service_endpoints    = ["Microsoft.Storage"]
}

output "subnet_id" {
  value = azurerm_subnet.itself[*].id
}
