/*
    Creates AWS IAM policy
*/

variable "role_policy_name_prefix" {}
variable "iam_role_id" {}
variable "iam_role_policy" {}
variable "turn_on" {}

resource "aws_iam_role_policy" "itself" {
  count       = (var.turn_on == true) ? 1 : 0
  name_prefix = var.role_policy_name_prefix
  role        = element(var.iam_role_id, count.index)
  policy      = var.iam_role_policy
  # Admin might add IAM roles, hence avoid to overwritten it
  lifecycle {
    ignore_changes = all
  }
}

output "role_name" {
  value = aws_iam_role_policy.itself[*].name
}

output "role_policy_name" {
  value = aws_iam_role_policy.itself[*].role
}

output "role_policy_id" {
  value = aws_iam_role_policy.itself[*].id
}
