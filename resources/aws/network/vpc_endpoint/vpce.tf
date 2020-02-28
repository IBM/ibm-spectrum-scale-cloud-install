/*
    Creates AWS VPC-Endpoints.
*/

variable "total_vpc_endpoints" {}
variable "vpc_id" {}
variable "service_name" {}

resource "aws_vpc_endpoint" "service" {
    count        = var.total_vpc_endpoints
    vpc_id       = var.vpc_id
    service_name = var.service_name
}

output "vpce_id" {
    value = aws_vpc_endpoint.service.*.id
}
