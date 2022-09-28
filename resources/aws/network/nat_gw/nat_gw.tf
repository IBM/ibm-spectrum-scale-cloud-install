/*
    Creates AWS NAT gateway.
*/

variable "turn_on" {}
variable "total_nat_gws" {}
variable "eip_id" {}
variable "target_subnet_id" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_nat_gateway" "itself" {
  count         = var.turn_on == true ? var.total_nat_gws : 0
  allocation_id = element(var.eip_id, count.index)
  subnet_id     = element(var.target_subnet_id, count.index)

  tags = merge(
    {
      "Name" = format("%s-%s", var.vpc_name, count.index)
    },
    var.vpc_tags,
  )
}

output "nat_gw_id" {
  value = try(aws_nat_gateway.itself.*.id, null)
}
