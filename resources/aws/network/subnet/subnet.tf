/*
    Creates AWS new Subnet.
*/

variable "turn_on" {}
variable "vpc_id" {}
variable "subnets_cidr" {}
variable "avail_zones" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_subnet" "itself" {
  count             = var.turn_on == true ? length(var.avail_zones) : 0
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnets_cidr, count.index)
  availability_zone = element(var.avail_zones, count.index)

  tags = merge(
    {
      "Name" = format("%s-%s", var.vpc_name, element(var.avail_zones, count.index))
    },
    var.vpc_tags,
  )
}

output "subnet_id" {
  value = aws_subnet.itself.*.id
}
