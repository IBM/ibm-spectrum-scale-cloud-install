/*
    Creates Azure Bastion subnets.
*/

variable "vnet_name" {}
variable "address_prefixes" {}
variable "resource_group_name" {}

resource "azurerm_subnet" "itself" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
}

output "subnet_id" {
  value = azurerm_subnet.itself.id
}
