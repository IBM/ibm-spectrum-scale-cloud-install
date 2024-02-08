/*
    Creates an Azure Bastion host.
*/

variable "bastion_host_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "public_ip" {}
variable "vpc_ref" {}

data "azurerm_subnet" "itself" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = var.vpc_ref
  resource_group_name  = var.resource_group_name
}

resource "azurerm_bastion_host" "itself" {
  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  ip_configuration {
    name                 = format("%s-config", var.bastion_host_name)
    subnet_id            = data.azurerm_subnet.itself.id
    public_ip_address_id = var.public_ip
  }
}

output "bastion_service_id" {
  value = azurerm_bastion_host.itself.id
}

output "bastion_service_dns_name" {
  value = azurerm_bastion_host.itself.dns_name
}
