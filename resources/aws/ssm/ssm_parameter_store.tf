/*
    Creates AWS SSM parameter.
*/

variable "parameter_name" {}
variable "parameter_value" {}
variable "parameter_type" {}


resource "aws_ssm_parameter" "ssm_parameter" {
  name  = var.parameter_name
  type  = var.parameter_type
  value = var.parameter_value
}

output "ssm_parameter_arn" {
  value = aws_ssm_parameter.ssm_parameter.arn
}

output "ssm_parameter_name" {
  value      = aws_ssm_parameter.ssm_parameter.name
  depends_on = [aws_ssm_parameter.ssm_parameter.arn]
}

