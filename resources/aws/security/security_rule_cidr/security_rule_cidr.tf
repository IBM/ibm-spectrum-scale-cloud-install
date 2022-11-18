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
variable "cidr_blocks" {}
variable "security_prefix_list_ids" {}

#tfsec:ignore:aws-ec2-no-public-egress-sgr #tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group_rule" "itself" {
  count             = var.total_rules
  security_group_id = var.security_group_id[count.index]
  description       = var.security_rule_description[count.index]
  type              = var.security_rule_type[count.index]
  from_port         = var.traffic_from_port[count.index]
  to_port           = var.traffic_to_port[count.index]
  protocol          = var.traffic_protocol[count.index]
  cidr_blocks       = var.cidr_blocks
  prefix_list_ids   = var.security_prefix_list_ids
}

output "security_rule_id" {
  value = aws_security_group_rule.itself[*].id
}
