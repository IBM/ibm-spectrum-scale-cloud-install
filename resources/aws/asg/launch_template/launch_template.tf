/*
    Creates AWS launch template.
*/

variable "turn_on" {}
variable "launch_template_name_prefix" {}
variable "image_id" {}
variable "instance_type" {}
variable "instance_iam_profile" {}
variable "enable_public_ip_address" {}
variable "key_name" {}
variable "sec_groups" {}
variable "enable_userdata" {}
variable "meta_private_key" {}
variable "meta_public_key" {}

locals {
  user_data = <<-EOT
    #!/usr/bin/env bash
    echo "${var.meta_private_key}" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
    echo "StrictHostKeyChecking no" >> ~/.ssh/config
  EOT
}

#tfsec:ignore:aws-ec2-no-public-ip
resource "aws_launch_template" "itself" {
  count                                = var.turn_on == true ? 1 : 0
  name_prefix                          = var.launch_template_name_prefix
  image_id                             = var.image_id
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  network_interfaces {
    associate_public_ip_address = var.enable_public_ip_address ? true : false
    security_groups             = var.sec_groups
  }
  iam_instance_profile {
    name = var.instance_iam_profile
  }
  key_name  = var.key_name
  user_data = var.enable_userdata ? base64_encode(local.user_data) : null
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
  value = aws_launch_template.itself[*].id
}
