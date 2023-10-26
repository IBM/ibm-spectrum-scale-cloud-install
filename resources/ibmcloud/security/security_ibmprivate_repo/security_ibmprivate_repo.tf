/*
    Creates Allow All traffic security group rule.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "turn_on" {}
variable "security_group_id" {}
variable "sg_direction" {}
variable "remote_ip_addr" {}

resource "ibm_is_security_group_rule" "itself" {
  count     = tobool(var.turn_on) == true ? 1 : 0
  group     = var.security_group_id
  direction = element(var.sg_direction, count.index)
  remote    = element(var.remote_ip_addr, count.index)
}

output "security_rule_id" {
  value = ibm_is_security_group_rule.itself[*].id
}
