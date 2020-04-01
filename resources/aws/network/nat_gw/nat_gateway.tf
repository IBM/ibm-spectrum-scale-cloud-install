/*
    Creates AWS NAT gateway.
*/

variable "total_nat_gws" {}
variable "eip_id" {}
variable "target_subnet_id" {}
variable "nat_gw_name_tag" {}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.total_nat_gws
  allocation_id = var.eip_id[count.index]
  subnet_id     = var.target_subnet_id[count.index]

  tags = {
    Name = "${var.nat_gw_name_tag}-${count.index + 1}"
  }
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat_gw.*.id
}