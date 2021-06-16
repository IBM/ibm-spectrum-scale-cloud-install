/*
    Creates new AWS security group.
*/

variable "sec_group_name" {}
variable "sec_group_description" {}
variable "turn_on" {}
variable "vpc_id" {}
variable "sec_group_tag" {}

resource "aws_security_group" "itself" {
  count       = tobool(var.turn_on) == true ? 1 : 0
  name_prefix = element(var.sec_group_name, count.index)
  description = element(var.sec_group_description, count.index)
  vpc_id      = var.vpc_id

  tags = { "Name" = var.sec_group_tag[count.index] }
}

output "sec_group_id" {
  value = try(aws_security_group.itself[0].id, null)
}
