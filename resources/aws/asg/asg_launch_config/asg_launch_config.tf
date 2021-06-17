/*
    Creates AWS autoscaling lauch config.
*/

variable "launch_config_name_prefix" {}
variable "image_id" {}
variable "instance_type" {}
variable "assoc_public_ip" {}
variable "instance_iam_profile" {}
variable "key_name" {}
variable "sec_groups" {}

resource "aws_launch_configuration" "itself" {
  name_prefix                 = var.launch_config_name_prefix
  image_id                    = var.image_id
  instance_type               = var.instance_type
  associate_public_ip_address = var.assoc_public_ip #tfsec:ignore:AWS012
  iam_instance_profile        = var.instance_iam_profile
  key_name                    = var.key_name
  security_groups             = var.sec_groups
  root_block_device {
    encrypted = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "asg_launch_config_name" {
  value = aws_launch_configuration.itself.name
}
