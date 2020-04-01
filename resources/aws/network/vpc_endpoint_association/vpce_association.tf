/*
    Creates AWS VPC-Endpoint association.
*/

variable "total_vpce_associations" {}
variable "route_table_id" {}
variable "vpce_id" {}

resource "aws_vpc_endpoint_route_table_association" "vpce_association" {
  count           = var.total_vpce_associations
  route_table_id  = var.route_table_id[0][count.index]
  vpc_endpoint_id = var.vpce_id[0][count.index]
}
