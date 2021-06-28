/*
    Creates AWS Route table.
*/

variable "total_rt" {}
variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_route_table" "itself" {
  count  = var.total_rt
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

output "table_id" {
  value = aws_route_table.itself.*.id
}
