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
variable "source_security_group_id" {
  type = list(string)
}


resource "aws_security_group_rule" "src_based_sec_rule" {
  count                    = var.total_rules
  security_group_id        = var.security_group_id[count.index]
  description              = var.security_rule_description[count.index]
  type                     = var.security_rule_type[count.index]
  from_port                = var.traffic_from_port[count.index]
  to_port                  = var.traffic_from_port[count.index]
  protocol                 = var.traffic_protocol[count.index]
  source_security_group_id = var.source_security_group_id[count.index]
}

output "src_security_rule_id" {
  value = aws_security_group_rule.src_based_sec_rule.*.id
}
