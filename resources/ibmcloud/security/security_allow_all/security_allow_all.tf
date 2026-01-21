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

variable "security_group_ids" {}
variable "sg_direction" {}
variable "remote_ip_addr" {}

resource "ibm_is_security_group_rule" "itself" {
  for_each  = toset(var.remote_ip_addr)
  group     = var.security_group_ids
  direction = var.sg_direction
  remote    = each.key
}

output "security_rule_id" {
  value = values(ibm_is_security_group_rule.itself)[*].id
}
