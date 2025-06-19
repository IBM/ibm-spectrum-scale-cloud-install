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
variable "port" {}

resource "ibm_is_security_group_rule" "itself" {
  for_each = toset(var.remote_ip_addr)

  group     = var.security_group_id
  direction = var.sg_direction
  remote    = each.key

  tcp {
    port_min = var.port
    port_max = var.port
  }
}

output "security_rule_id" {
  value = [for rule in ibm_is_security_group_rule.itself : rule.id]
}
