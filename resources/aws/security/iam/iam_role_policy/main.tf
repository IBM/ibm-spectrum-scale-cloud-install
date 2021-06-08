/*
    Creates AWS IAM policy
*/

variable "role_policy_name_prefix" {}
variable "iam_role_id" {}
variable "iam_role_policy" {}

resource "aws_iam_role_policy" "itself" {
  name_prefix = var.role_policy_name_prefix
  role        = var.iam_role_id
  policy      = var.iam_role_policy
}

output "role_name" {
  value = aws_iam_role_policy.itself.name
}

output "role_policy_name" {
  value = aws_iam_role_policy.itself.role
}

output "role_policy_id" {
  value = aws_iam_role_policy.itself.id
}
