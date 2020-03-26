/*
    Creates AWS Route table.
*/

variable "total_rt" {}
variable "vpc_id" {}
variable "route_table_name_tag" {}

resource "aws_route_table" "route_table" {
  count  = var.total_rt
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.route_table_name_tag}-${count.index + 1}"
  }
}

output "table_id" {
  value = aws_route_table.route_table.*.id
}
