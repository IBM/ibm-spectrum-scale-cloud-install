/*
    Creates CIDR specific security group rule.
*/

variable "total_cidr_rules" {}
variable "security_group_ids" {}
variable "sg_direction" {}
variable "remote_cidr" {}


resource "ibm_is_security_group_rule" "sg_rule" {
  count     = var.total_cidr_rules
  group     = var.security_group_ids
  direction = var.sg_direction
  remote    = element(var.remote_cidr, count.index)
}


output "security_rule_id" {
  value = ibm_is_security_group_rule.sg_rule.*.id
}
