/*
    Creates ICMP specific security group rule.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "security_group_id" {}
variable "sg_direction" {}
variable "remote_ip_addr" {}

locals {
  remotes = element(flatten([var.remote_ip_addr]), 0)
}

resource "ibm_is_security_group_rule" "itself" {
  group     = var.security_group_id
  direction = var.sg_direction
  remote    = local.remotes
  icmp {
    type = 8
    code = 0
  }
}

output "security_rule_id" {
  value = ibm_is_security_group_rule.itself[*].id
}
