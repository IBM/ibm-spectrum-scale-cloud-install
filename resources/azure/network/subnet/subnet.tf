/*
    Creates specitifed number of Azure subnets.
*/

variable "total_subnets" {}
variable "vnet_name" {}
variable "address_prefixes" {}
variable "subnet_name" {}
variable "resource_group_name" {}

resource "azurerm_subnet" "itself" {
  count                = var.total_subnets
  name                 = element(var.subnet_name, count.index)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [element(var.address_prefixes, count.index)]
}

output "subnet_id" {
  value = azurerm_subnet.itself.*.id
}

output "subnet_name" {
  value = azurerm_subnet.itself.*.name
}
