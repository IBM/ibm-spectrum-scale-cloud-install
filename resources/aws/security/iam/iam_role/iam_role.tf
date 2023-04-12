/*
    Creates IAM role.
*/

variable "role_name_prefix" {}
variable "role_policy" {}
variable "turn_on" {}

resource "aws_iam_role" "itself" {
  count              = (var.turn_on == true) ? 1 : 0
  name_prefix        = var.role_name_prefix
  path               = "/"
  assume_role_policy = var.role_policy
}

output "iam_role_id" {
  value = aws_iam_role.itself[*].id
}

output "iam_role_arn" {
  value = aws_iam_role.itself[*].arn
}
