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
variable "enable_rule" {}

locals {
  # Normalize inputs so the resource always receives strings/lists.
  ports     = flatten([var.port])                        # 22 -> [22], [22,8080,9081] -> [22,8080,9081]
  sg_id     = element(flatten([var.security_group_id]), 0)
  direction = element(flatten([var.sg_direction]), 0)
  remote    = element(flatten([var.remote_ip_addr]), 0)  # single remote (SG ID or CIDR)
}

resource "ibm_is_security_group_rule" "itself" {
  for_each = var.enable_rule ? { for p in local.ports : tostring(p) => p } : {}

  group     = local.sg_id
  direction = local.direction
  remote    = local.remote

  tcp {
    port_min = each.value
    port_max = each.value
  }
}

output "security_rule_id" {
  value = [for rule in ibm_is_security_group_rule.itself : rule.id]
}
