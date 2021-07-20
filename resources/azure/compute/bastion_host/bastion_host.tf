/*
    Creates an Azure Bastion host.
*/

variable "bastion_host_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {}
variable "public_ip" {}

resource "azurerm_bastion_host" "itself" {
  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = format("%s-config", var.bastion_host_name)
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip
  }
}

output "bastion_dns_name" {
  value = azurerm_bastion_host.itself.dns_name
}
