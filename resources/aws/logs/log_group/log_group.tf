/*
    Creates AWS cloudwatch log group.
*/

variable "log_group_name_prefix" {}

#tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "itself" {
  name_prefix = var.log_group_name_prefix
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.itself.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.itself.name
}
