/*
    Creates AWS instance profile.
*/

variable "instance_profile_name_prefix" {}
variable "iam_host_role" {}

resource "aws_iam_instance_profile" "host_profile" {
  name_prefix = var.instance_profile_name_prefix
  role        = var.iam_host_role
  path        = "/"
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.host_profile.name
}
