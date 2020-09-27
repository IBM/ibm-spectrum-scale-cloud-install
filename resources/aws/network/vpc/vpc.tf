/*
    Creates new AWS Virtual Private Cloud.
*/

variable "vpc_name_tag" {
  type        = string
  description = "Name to be used on all the resources as identifier"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but can be overridden"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name_tag
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

