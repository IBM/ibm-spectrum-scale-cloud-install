/*
    Creates AWS Route table association.
*/

variable "total_associations" {}
variable "subnet_id" {}
variable "route_table_id" {}

resource "aws_route_table_association" "route_table_assoc" {
  count          = var.total_associations
  subnet_id      = element(var.subnet_id, count.index)
  route_table_id = element(var.route_table_id, count.index)
}
