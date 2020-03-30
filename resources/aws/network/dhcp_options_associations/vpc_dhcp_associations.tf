/*
    Sets VPC DHCP options.
*/

variable "vpc_id" {}
variable "vpc_dhcp_options_id" {}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = var.vpc_dhcp_options_id
}
