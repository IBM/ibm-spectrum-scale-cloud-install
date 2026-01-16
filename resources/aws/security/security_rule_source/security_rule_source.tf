/*
    Creates specitifed number of security group rules.
*/

variable "total_rules" {}
variable "security_group_id" {}
variable "security_rule_description" {}
variable "security_rule_type" {}
variable "traffic_from_port" {}
variable "traffic_to_port" {}
variable "traffic_protocol" {}
variable "source_security_group_id" {}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "itself" {
  count                    = var.total_rules
  security_group_id        = element(var.security_group_id, count.index)
  description              = element(var.security_rule_description, count.index)
  type                     = element(var.security_rule_type, count.index)
  from_port                = element(var.traffic_from_port, count.index)
  to_port                  = element(var.traffic_to_port, count.index)
  protocol                 = element(var.traffic_protocol, count.index)
  source_security_group_id = element(var.source_security_group_id, count.index)
}

output "src_security_rule_id" {
  value = aws_security_group_rule.itself[*].id
}
