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
variable "vpc" {}
variable "resource_group_id" {}

data "ibm_is_vpc" "itself" {
  name = var.vpc
}

resource "ibm_is_security_group" "itself" {
  count          = tobool(var.turn_on) == true ? 1 : 0
  name           = element(var.sec_group_name, count.index)
  vpc            = data.ibm_is_vpc.itself.id
  resource_group = var.resource_group_id
}

output "sec_group_id" {
  value = try(ibm_is_security_group.itself[0].id, null)
}
