/*
    Creates specitifed number of security group rules.
*/

variable "total_rules" {
  type = string
}
variable "security_group_id" {
  type = list(string)
}
variable "security_rule_description" {
  type = list(string)
}
variable "security_rule_type" {
  type = list(string)
}
variable "traffic_from_port" {
  type = list(string)
}
variable "traffic_to_port" {
  type = list(string)
}
variable "traffic_protocol" {
  type = list(string)
}
variable "cidr_blocks" {
  type = list(string)
}
variable "security_prefix_list_ids" {
  # Applicable only for egress type
  type = list(string)
}


resource "aws_security_group_rule" "security_rule" {
  count             = var.total_rules
  security_group_id = var.security_group_id[count.index]
  description       = var.security_rule_description[count.index]
  type              = var.security_rule_type[count.index]
  from_port         = var.traffic_from_port[count.index]
  to_port           = var.traffic_from_port[count.index]
  protocol          = var.traffic_protocol[count.index]
  cidr_blocks       = var.cidr_blocks
  prefix_list_ids   = var.security_prefix_list_ids
}

output "security_rule_id" {
  value = aws_security_group_rule.security_rule.*.id
}
