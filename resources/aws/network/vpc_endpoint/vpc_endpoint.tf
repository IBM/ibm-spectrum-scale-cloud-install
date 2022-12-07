/*
    Creates AWS VPC-Endpoints.
*/

variable "turn_on" {}
variable "total_vpc_endpoints" {}
variable "vpc_id" {}
variable "service_name" {}
variable "resource_prefix" {}

resource "aws_vpc_endpoint" "itself" {
  count        = var.turn_on == true ? var.total_vpc_endpoints : 0
  vpc_id       = var.vpc_id
  service_name = var.service_name
  tags = {
    Name = var.resource_prefix
  }
}

output "vpce_id" {
  value = try(aws_vpc_endpoint.itself[*].id, null)
}
