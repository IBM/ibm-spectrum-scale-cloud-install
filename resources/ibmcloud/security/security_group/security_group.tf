/*
    Creates new IBM Cloud security group.
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "turn_on" {}
variable "sec_group_name" {}
variable "vpc_id" {}
variable "resource_group_id" {}
variable "tags" {
  type    = list(string)
  default = []
}

resource "ibm_is_security_group" "itself" {
  count          = tobool(var.turn_on) == true ? 1 : 0
  name           = var.sec_group_name
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  tags           = var.tags
}

output "sec_group_id" {
  value = try(ibm_is_security_group.itself[0].id, null)
}
