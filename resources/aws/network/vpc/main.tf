/*
    Creates new AWS Virtual Private Cloud.
*/

variable "cidr_block" {}
variable "vpc_name" {}
variable "vpc_tags" {}

resource "aws_vpc" "itself" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

resource "aws_default_network_acl" "itself" {
  default_network_acl_id = aws_vpc.itself.default_network_acl_id
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

resource "aws_default_route_table" "itself" {
  default_route_table_id = aws_vpc.itself.default_route_table_id
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

resource "aws_default_security_group" "itself" {
  vpc_id = aws_vpc.itself.id
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

resource "aws_default_vpc_dhcp_options" "itself" {
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
  depends_on = [aws_vpc.itself]
}

output "vpc_id" {
  value = aws_vpc.itself.id
}

output "vpc_main_route_table_id" {
  value = aws_vpc.itself.main_route_table_id
}

output "vpc_dhcp_options_id" {
  value = aws_default_vpc_dhcp_options.itself.id
}
