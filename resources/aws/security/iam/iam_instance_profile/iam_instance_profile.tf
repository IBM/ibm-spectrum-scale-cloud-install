/*
    Creates AWS instance profile.
*/

variable "instance_profile_name_prefix" {}
variable "iam_host_role" {}
variable "turn_on" {}

resource "aws_iam_instance_profile" "itself" {
  count       = (var.turn_on == true) ? 1 : 0
  name_prefix = var.instance_profile_name_prefix
  role        = element(var.iam_host_role, count.index)
  path        = "/"
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.itself[*].name
}
