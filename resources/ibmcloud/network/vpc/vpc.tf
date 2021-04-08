/*
    Creates new IBM Virtual Private Cloud.
*/

variable "vpc_name_prefix" {
  type        = string
  description = "Name prefix to be used for VPC"
}
variable "resource_grp_id" {}


resource "ibm_is_vpc" "new_vpc" {
  name                        = format("%s-vpc", var.vpc_name_prefix)
  address_prefix_management   = "manual"
  resource_group              = var.resource_grp_id
  default_security_group_name = format("%s-vpc-sg", var.vpc_name_prefix)
  default_routing_table_name  = format("%s-vpc-rt", var.vpc_name_prefix)
  default_network_acl_name    = format("%s-vpc-nwacl", var.vpc_name_prefix)
}

output "vpc_id" {
  value = ibm_is_vpc.new_vpc.id
}

output "vpc_crn" {
  value = ibm_is_vpc.new_vpc.crn
}
