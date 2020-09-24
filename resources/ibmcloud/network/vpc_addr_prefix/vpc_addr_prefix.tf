/*
    Creates new IBM VPC address prefixes.
*/

variable "vpc_id" {
  type        = string
  description = "IBM Cloud VPC ID."
}

variable "address_name_prefix" {
  type        = string
  description = "Address prefix name"
}

variable "zones" {
  type        = list(string)
  description = "List of zones"
}

variable "cidr_block" {
  type        = list(string)
  description = "CIDR block for the VPC per zone"
}


resource "ibm_is_vpc_address_prefix" "new_vpc_address_prefix" {
  count = length(var.zones)
  name  = "addr-${var.address_name_prefix}-${count.index + 1}"
  zone  = element(var.zones, count.index)
  vpc   = var.vpc_id
  cidr  = element(var.cidr_block, count.index)
}

output "vpc_addr_prefix_id" {
  value = ibm_is_vpc_address_prefix.new_vpc_address_prefix.*.id
}
