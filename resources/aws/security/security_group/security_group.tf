/*
    Creates new AWS security group.
*/

variable "sec_group_name" {}
variable "sec_group_description" {}
variable "total_sec_groups" {}
variable "vpc_id" {}
variable "sec_group_tag" {}

resource "aws_security_group" "itself" {
  count       = var.total_sec_groups
  name_prefix = element(var.sec_group_name, count.index)
  description = element(var.sec_group_description, count.index)
  vpc_id      = var.vpc_id

  tags = { "Name" = var.sec_group_tag[count.index] }
}

output "sec_group_id" {
  value = aws_security_group.itself.*.id
}
