/*
    Creates AWS internet gateway.
*/

variable "turn_on" {}
variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_internet_gateway" "itself" {
  count  = var.turn_on == true ? 1 : 0
  vpc_id = var.vpc_id
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

output "internet_gw_id" {
  value = try(aws_internet_gateway.itself[0].id, null)
}
