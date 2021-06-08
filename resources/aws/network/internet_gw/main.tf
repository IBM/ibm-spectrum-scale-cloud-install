/*
    Creates AWS internet gateway.
*/

variable "vpc_id" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_internet_gateway" "itself" {
  vpc_id = var.vpc_id
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

output "internet_gw_id" {
  value = aws_internet_gateway.itself.id
}
