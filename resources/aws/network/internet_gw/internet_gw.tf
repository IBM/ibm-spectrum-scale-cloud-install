/*
    Creates AWS internet gateway.
*/

variable "vpc_id" {}
variable "internet_gateway_name_tag" {}

resource "aws_internet_gateway" "internet_gw" {
    vpc_id = var.vpc_id

    tags = {
        Name = var.internet_gateway_name_tag
    }
}

output "internet_gw_id" {
    value = aws_internet_gateway.internet_gw.id
}
