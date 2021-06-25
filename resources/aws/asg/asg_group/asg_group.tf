/*
    Creates AWS autoscaling group.
*/

variable "asg_name_prefix" {}
variable "asg_max_size" {}
variable "asg_min_size" {}
variable "asg_desired_size" {}
variable "auto_scaling_group_subnets" {}
variable "asg_suspend_processes" {}
variable "asg_launch_config_name" {}
variable "asg_tags" {}

resource "aws_autoscaling_group" "itself" {
  name_prefix               = var.asg_name_prefix
  launch_configuration      = var.asg_launch_config_name
  default_cooldown          = 180
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_size
  vpc_zone_identifier       = var.auto_scaling_group_subnets
  suspended_processes       = var.asg_suspend_processes

  tags = var.asg_tags
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_instances" "itself" {
  depends_on = [aws_autoscaling_group.itself]

  instance_tags = {
    Name = var.asg_tags[0]["value"]
  }
}

data "aws_instance" "itself" {
  count       = var.asg_desired_size
  depends_on  = [data.aws_instances.itself]
  instance_id = data.aws_instances.itself.ids[count.index]
}


output "asg_arn" {
  value = aws_autoscaling_group.itself.arn
}

output "asg_instance_ids" {
  value = aws_autoscaling_group.itself.*.id
}

output "asg_instance_public_ip" {
  value = data.aws_instance.itself.*.public_ip
}

output "asg_instance_private_ip" {
  value = data.aws_instance.itself.*.private_ip
}
