/*
    Creates new IBM VPC address prefixes.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "vpc_id" {}
variable "address_name" {}
variable "zones" {}
variable "cidr_block" {}

resource "ibm_is_vpc_address_prefix" "itself" {
  count = length(var.zones)
  name  = "${var.address_name}-${count.index + 1}"
  zone  = element(var.zones, count.index)
  vpc   = var.vpc_id
  cidr  = element(var.cidr_block, count.index)
}

output "vpc_addr_prefix_id" {
  value = ibm_is_vpc_address_prefix.itself[*].id
}
