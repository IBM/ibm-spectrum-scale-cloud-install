/*
    Creates AWS Route table.
*/

variable "turn_on" {}
variable "total_rt" {}
variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_route_table" "itself" {
  count  = var.turn_on == true ? var.total_rt : 0
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

output "table_id" {
  value = try(aws_route_table.itself[*].id, null)
}
