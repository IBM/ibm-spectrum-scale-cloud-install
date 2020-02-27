/*
    Creates new AWS security group.
*/

variable "sec_group_name" {
    type = list(string)
}
variable "sec_group_description" {
    type = list(string)
}
variable "total_sec_groups" {
    type = string
}
variable "vpc_id" {
    type = list(string)
}
variable "sec_group_tag_name" {
    type = list(string)
}

resource "aws_security_group" "host_security_group" {
    count       = var.total_sec_groups
    name_prefix = var.sec_group_name[count.index]
    description = var.sec_group_description[count.index]
    vpc_id      = var.vpc_id[count.index]

    tags = {"Name" = var.sec_group_tag_name[count.index]}
}

output "sec_group_id" {
    value = aws_security_group.host_security_group.*.id
}
