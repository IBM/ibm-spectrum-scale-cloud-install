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

variable "turn_on" {}
variable "sec_group_name" {}
variable "vpc_id" {}
variable "resource_group_id" {}
variable "resource_tags" {}

resource "ibm_is_security_group" "itself" {
  count          = tobool(var.turn_on) == true ? 1 : 0
  name           = element(var.sec_group_name, count.index)
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.resource_tags
}

output "sec_group_id" {
  value = try(ibm_is_security_group.itself[0].id, null)
}
