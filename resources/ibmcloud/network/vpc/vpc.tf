/*
   Creates new IBM Virtual Private Cloud.
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "vpc_name" {}
variable "vpc_address_prefix_management" {}
variable "vpc_sg_name" {}
variable "vpc_rt_name" {}
variable "vpc_nw_acl_name" {}
variable "resource_group_id" {}
variable "tags" {
  type    = list(string)
  default = []
}

resource "ibm_is_vpc" "itself" {
  name                        = var.vpc_name
  address_prefix_management   = var.vpc_address_prefix_management
  resource_group              = var.resource_group_id
  default_security_group_name = var.vpc_sg_name
  default_routing_table_name  = var.vpc_rt_name
  default_network_acl_name    = var.vpc_nw_acl_name
  tags                        = var.tags
}

output "vpc_id" {
  value = ibm_is_vpc.itself.id
}

output "vpc_crn" {
  value = ibm_is_vpc.itself.crn
}

output "vpc_name" {
  value = ibm_is_vpc.itself.name
}
