/*
   Associates a Network Security Group with a Subnet within a Virtual Network.
*/

variable "subnet_ids" {}
variable "network_security_group_id" {}

resource "azurerm_subnet_network_security_group_association" "itself" {
  count                     = length(var.subnet_ids)
  subnet_id                 = element(var.subnet_ids, count.index)
  network_security_group_id = var.network_security_group_id
}
