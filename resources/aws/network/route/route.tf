/*
    Creates AWS Route.
*/

variable "turn_on" {}
variable "total_routes" {}
variable "route_table_id" {}
variable "dest_cidr_block" {}
variable "gateway_id" {}
variable "nat_gateway_id" {}

resource "aws_route" "itself" {
  count                  = var.turn_on == true ? var.total_routes : 0
  route_table_id         = element(var.route_table_id, count.index)
  destination_cidr_block = var.dest_cidr_block
  gateway_id             = var.gateway_id == null ? null : element(var.gateway_id, count.index)
  nat_gateway_id         = var.nat_gateway_id == null ? null : element(var.nat_gateway_id, count.index)
}
