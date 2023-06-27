/*
    Creates AWS autoscaling group.
*/

variable "asg_name_prefix" {}
variable "asg_max_size" {}
variable "asg_min_size" {}
variable "asg_desired_size" {}
variable "auto_scaling_group_subnets" {}
variable "asg_suspend_processes" {}
variable "asg_launch_template_id" {}
variable "asg_tags" {}

resource "aws_autoscaling_group" "itself" {
  name_prefix = var.asg_name_prefix
  launch_template {
    id      = var.asg_launch_template_id
    version = "$Latest"
  }
  default_cooldown          = 180
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_size
  vpc_zone_identifier       = var.auto_scaling_group_subnets
  suspended_processes       = var.asg_suspend_processes

  tag {
    key                 = lookup(var.asg_tags, "key")
    value               = lookup(var.asg_tags, "value")
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to desired_capacity, min_size, max_size attributes (as they can be altered be modified externally)
      desired_capacity,
      min_size,
      max_size
    ]
  }
}

data "aws_instances" "itself" {
  depends_on = [aws_autoscaling_group.itself]

  instance_tags = {
    Name = var.asg_tags["value"]
  }
}

data "aws_instance" "itself" {
  count       = var.asg_desired_size
  depends_on  = [data.aws_instances.itself]
  instance_id = data.aws_instances.itself.ids[count.index]
}

output "asg_id" {
  value = aws_autoscaling_group.itself.id
}

output "asg_id" {
  value = aws_autoscaling_group.itself.id
}

output "asg_id" {
  value = aws_autoscaling_group.itself.id
}

output "asg_arn" {
  value = aws_autoscaling_group.itself.arn
}

output "asg_instance_id" {
  value = data.aws_instance.itself[*].id
}

output "asg_instance_public_ip" {
  value = data.aws_instance.itself[*].public_ip
}

output "asg_instance_private_ip" {
  value = data.aws_instance.itself[*].private_ip
}
