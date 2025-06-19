output "bastion_instance_autoscaling_group_ref" {
  value       = module.bastion_autoscaling_group.asg_id
  description = "Bastion instances autoscaling group (id/self-link)."
}
output "bastion_security_group_id" {
  value       = module.bastion_security_group.sec_group_id
  description = "Bastion security group id."
}
