/*
    Creates IAM role.
*/

variable "role_name_prefix" {}
variable "role_policy" {}

resource "aws_iam_role" "itself" {
  name_prefix        = var.role_name_prefix
  path               = "/"
  assume_role_policy = var.role_policy
}

output "iam_role_id" {
  value = aws_iam_role.itself.id
}

output "iam_role_arn" {
  value = aws_iam_role.itself.arn
}
