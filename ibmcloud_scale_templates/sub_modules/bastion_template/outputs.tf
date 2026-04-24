output "bastion_instance_autoscaling_group_ref" {
  value       = try(module.bastion_autoscaling_group[0].asg_id, null)
  description = "Bastion instances autoscaling group ID."
}

output "bastion_security_group_ref" {
  value       = try(module.bastion_security_group[0].sec_group_id, null)
  description = "Bastion security group ID."
}
