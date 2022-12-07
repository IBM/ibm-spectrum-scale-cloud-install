/*
    Creates specitifed number of Azure subnets.
*/

variable "turn_on" {}
variable "vpc_name" {}
variable "address_prefixes" {}
variable "subnet_name" {}
variable "resource_group_name" {}

resource "azurerm_subnet" "itself" {
  count                = var.turn_on == true ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vpc_name
  address_prefixes     = var.address_prefixes
}

output "sub_id" {
  value = azurerm_subnet.itself[*].id
}
