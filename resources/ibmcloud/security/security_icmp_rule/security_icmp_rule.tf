/*
    Creates ICMP specific security group rule.
*/

variable "security_group_id" {}
variable "sg_direction" {}
variable "remote_ip_addr" {}


resource "ibm_is_security_group_rule" "sg_rule" {
  group     = var.security_group_id
  direction = var.sg_direction
  remote    = var.remote_ip_addr

  icmp {
    type = 8
    code = 20
  }
}


output "security_rule_id" {
  value = ibm_is_security_group_rule.sg_rule.id
}
