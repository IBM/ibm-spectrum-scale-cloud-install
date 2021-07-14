/*
   Associates a Network Security Group with a Subnet within a Virtual Network.
*/

variable "subnet_id" {}
variable "network_security_group_id" {}

resource "azurerm_subnet_network_security_group_association" "itself" {
  subnet_id                 = var.subnet_id
  network_security_group_id = var.network_security_group_id
}
