/*
    Creates AWS cloudwatch log group.
*/

variable "group_name_prefix" {}

resource "aws_cloudwatch_log_group" "log_group" {
    name_prefix = var.group_name_prefix
}

output "log_group_arn" {
    value = aws_cloudwatch_log_group.log_group.arn
}

output "log_group_name" {
    value = aws_cloudwatch_log_group.log_group.name
}
