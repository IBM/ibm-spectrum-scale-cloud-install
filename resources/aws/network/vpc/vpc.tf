/*
    Creates new AWS Virtual Private Cloud.
*/

variable "turn_on" {}
variable "cidr_block" {}
variable "vpc_name" {}
variable "domain_name" {}
variable "vpc_tags" {}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "itself" {
  count                            = var.turn_on ? 1 : 0
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
  count                  = var.turn_on ? 1 : 0
  default_network_acl_id = try(aws_vpc.itself[0].default_network_acl_id, null)
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

resource "aws_default_route_table" "itself" {
  count                  = var.turn_on ? 1 : 0
  default_route_table_id = try(aws_vpc.itself[0].default_route_table_id, null)
  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

resource "aws_default_security_group" "itself" {
  count  = var.turn_on ? 1 : 0
  vpc_id = try(aws_vpc.itself[0].id, null)
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
}

# Note: Each AWS region comes with a default set of DHCP options. Terraform cannot destroy it.
# Hence using our own dhcp options set which can be deleted.
resource "aws_vpc_dhcp_options" "itself" {
  count               = var.turn_on ? 1 : 0
  domain_name         = var.domain_name
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = merge(
    {
      "Name" = format("%s", var.vpc_name)
    },
    var.vpc_tags,
  )
  depends_on = [aws_vpc.itself]
}

resource "aws_vpc_dhcp_options_association" "itself" {
  count           = var.turn_on ? 1 : 0
  vpc_id          = try(aws_vpc.itself[0].id, null)
  dhcp_options_id = try(aws_vpc_dhcp_options.itself[0].id, null)
}

output "vpc_id" {
  value = try(aws_vpc.itself[0].id, null)
}

output "vpc_main_route_table_id" {
  value = try(aws_vpc.itself[0].main_route_table_id, null)
}

output "vpc_dhcp_options_id" {
  value = try(aws_vpc_dhcp_options.itself[0].id, null)
}
