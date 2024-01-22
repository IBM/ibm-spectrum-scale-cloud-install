/*
    Associate a nat gateway with a subnet.
*/

variable "subnet_id" {}
variable "nat_gateway_id" {}

resource "azurerm_subnet_nat_gateway_association" "itself" {
  count          = length(var.subnet_id)
  subnet_id      = var.subnet_id[count.index]
  nat_gateway_id = var.nat_gateway_id
}

output "subnet_association" {
  value = azurerm_subnet_nat_gateway_association.itself[*].id
}
