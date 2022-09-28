/*
    Creates AWS Route table association.
*/

variable "turn_on" {}
variable "total_associations" {}
variable "subnet_id" {}
variable "route_table_id" {}

resource "aws_route_table_association" "itself" {
  count          = var.turn_on == true ? var.total_associations : 0
  subnet_id      = element(var.subnet_id, count.index)
  route_table_id = element(var.route_table_id, count.index)
}
