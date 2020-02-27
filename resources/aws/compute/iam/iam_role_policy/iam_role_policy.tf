/*
    Creates AWS IAM policy
*/

variable "role_policy_name_prefix" {}
variable "iam_role_id" {}
variable "iam_role_policy" {}

resource "aws_iam_role_policy" "host_role_policy" {
    name_prefix = var.role_policy_name_prefix
    role        = var.iam_role_id
    policy      = var.iam_role_policy
}

output "role_name" {
    # name - The name of the IAM policy
    value = aws_iam_role_policy.host_role_policy.name
}

output "role_policy_name" {
    # role - The name of the role associated with the policy.
    value = aws_iam_role_policy.host_role_policy.role
}

output "role_policy_id" {
    # id - The role policy ID, in the form of role_name:role_policy_name
    value = aws_iam_role_policy.host_role_policy.id
}
