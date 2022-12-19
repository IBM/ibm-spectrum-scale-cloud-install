/*
    Associate the nat gateway with public ip address.
*/

variable "nat_gateway_id" {}
variable "public_ip_address_id" {}

resource "azurerm_nat_gateway_public_ip_association" "itself" {
  nat_gateway_id       = var.nat_gateway_id
  public_ip_address_id = var.public_ip_address_id
}

output "nat_gw_association" {
  value = azurerm_nat_gateway_public_ip_association.itself.id
}
