/*
    Creates CIDR specific security group rule.
*/

variable "security_group_ids" {}
variable "sg_direction" {}
variable "remote_cidr" {}


resource "ibm_is_security_group_rule" "sg_rule" {
  count     = length(var.security_group_ids)
  group     = element(var.security_group_ids, count.index)
  direction = var.sg_direction
  remote    = element(var.remote_cidr, count.index)
}


output "security_rule_id" {
  value = ibm_is_security_group_rule.sg_rule.*.id
}
