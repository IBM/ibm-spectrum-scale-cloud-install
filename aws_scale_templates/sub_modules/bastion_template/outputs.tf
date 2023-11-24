output "bastion_instance_autoscaling_group_ref" {
  value       = try(module.bastion_autoscaling_group.asg_id[0], null)
  description = "Bastion instances autoscaling group (id/self-link)."
}

output "bastion_security_group_ref" {
  value       = module.bastion_security_group.sec_group_id
  description = "Bastion security group reference (id/self-link)."
}
