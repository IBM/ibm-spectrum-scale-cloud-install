/*
    Creates IAM role (with specified name).
*/

variable "role_name" {}
variable "role_policy" {}

resource "aws_iam_role" "itself" {
  name               = var.role_name
  path               = "/"
  assume_role_policy = var.role_policy
}

output "iam_role_id" {
  value = aws_iam_role.itself.id
}

output "iam_role_arn" {
  value = aws_iam_role.itself.arn
}
