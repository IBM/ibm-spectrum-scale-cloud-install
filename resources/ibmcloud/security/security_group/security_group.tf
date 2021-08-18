/*
    Creates new IBM Cloud security group.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "total_sec_groups" {}
variable "sec_group_name" {}
variable "vpc_id" {}
variable "resource_group_id" {}

resource "ibm_is_security_group" "itself" {
  count          = var.total_sec_groups
  name           = element(var.sec_group_name, count.index)
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

output "sec_group_id" {
  value = ibm_is_security_group.itself.*.id
}
