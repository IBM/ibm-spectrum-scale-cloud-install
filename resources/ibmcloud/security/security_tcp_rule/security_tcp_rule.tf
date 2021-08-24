/*
    Creates TCP specific security group rule.
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

resource "ibm_is_security_group_rule" "itself" {
  group     = var.security_group_id
  direction = var.sg_direction
  remote    = var.remote_ip_addr

  tcp {
    port_min = 22
    port_max = 22
  }
}

output "security_rule_id" {
  value = ibm_is_security_group_rule.itself.id
}
