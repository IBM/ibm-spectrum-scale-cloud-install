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

variable "total_rules" {}
variable "security_group_id" {}
variable "sg_direction" {}
variable "source_security_group_id" {}

resource "ibm_is_security_group_rule" "itself" {
  count     = var.total_rules
  group     = element(var.security_group_id, count.index)
  direction = element(var.sg_direction, count.index)
  remote    = element(var.source_security_group_id, count.index)
}

output "src_security_rule_id" {
  value = ibm_is_security_group_rule.itself[*].id
}
