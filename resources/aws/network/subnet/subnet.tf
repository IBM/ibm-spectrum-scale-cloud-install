/*
    Creates AWS new Subnet.
*/

variable "total_subnets" {}
variable "vpc_id" {}
variable "subnets_cidr" {}
variable "avail_zones" {}
variable "subnet_name_tag" {}

resource "aws_subnet" "subnet" {
  count             = var.total_subnets
  vpc_id            = var.vpc_id
  cidr_block        = var.subnets_cidr[count.index]
  availability_zone = var.avail_zones[count.index]

  tags = {
    Name = "${var.subnet_name_tag}-${count.index + 1}"
  }
}

output "subnet_id" {
  value = aws_subnet.subnet.*.id
}
