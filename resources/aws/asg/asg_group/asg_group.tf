/*
    Creates AWS autoscaling group.
*/

variable "asg_name_prefix" {
    type = string
}

variable "asg_max_size" {
    type    = string
    default = 1
}

variable "asg_min_size" {
    type    = string
    default = 1
}

variable "asg_desired_size" {
    type    = string
    default = 1
}

variable "auto_scaling_group_subnets" {
    type = list(string)
}

variable "asg_suspend_processes" {
    type    = list(string)
    default = ["HealthCheck", "ReplaceUnhealthy", "AZRebalance"]
}

variable "asg_launch_config_name" {
    type = string
}
variable "asg_tags" {}

resource "aws_autoscaling_group" "auto_scaling_group" {
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

output "asg_arn" {
    value = aws_autoscaling_group.auto_scaling_group.arn
}

output "asg_instance_ids" {
    value = aws_autoscaling_group.auto_scaling_group.*.id
}
