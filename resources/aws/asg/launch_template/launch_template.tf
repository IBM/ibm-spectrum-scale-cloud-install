/*
    Creates AWS launch template.
*/

variable "launch_template_name_prefix" {}
variable "image_id" {}
variable "instance_type" {}
variable "instance_iam_profile" {}
variable "key_name" {}
variable "sec_groups" {}

#tfsec:ignore:aws-ec2-no-public-ip
resource "aws_launch_template" "itself" {
  name_prefix                          = var.launch_template_name_prefix
  image_id                             = var.image_id
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.sec_groups
  }
  iam_instance_profile {
    name = var.instance_iam_profile
  }
  key_name = var.key_name
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "asg_launch_template_id" {
  value = aws_launch_template.itself.id
}
