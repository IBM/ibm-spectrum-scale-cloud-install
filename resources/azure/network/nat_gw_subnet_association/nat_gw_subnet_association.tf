/*
    Associate a nat gateway with a subnet.
*/

variable "turn_on" {}
variable "subnet_id" {}
variable "nat_gateway_id" {}

resource "azurerm_subnet_nat_gateway_association" "itself" {
  count          = var.turn_on ? length(var.subnet_id) : 0
  subnet_id      = element(var.subnet_id, count.index)
  nat_gateway_id = element(var.nat_gateway_id, count.index)
}

output "subnet_association" {
  value = azurerm_subnet_nat_gateway_association.itself[*].id
}
