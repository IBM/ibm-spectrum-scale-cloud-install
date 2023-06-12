/*
    Creates AWS launch template.
*/

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

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
EOF
}

data "template_cloudinit_config" "user_data64" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
}

#tfsec:ignore:aws-ec2-no-public-ip
resource "aws_launch_template" "itself" {
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
  user_data = var.enable_userdata ? data.template_cloudinit_config.user_data64.rendered : null
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
