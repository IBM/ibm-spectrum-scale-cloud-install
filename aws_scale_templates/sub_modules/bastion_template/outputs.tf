output "bastion_instance_autoscaling_group_ref" {
  value       = module.bastion_autoscaling_group.asg_id
  description = "Bastion instances autoscaling group (id/self-link)."
}

output "bastion_security_group_ref" {
  value       = module.bastion_security_group.sec_group_id
  description = "Bastion security group reference (id/self-link)."
}

output "bastion_instance_ref" {
  value       = module.bastion_autoscaling_group.asg_instance_id
  description = "Bastion instance ref."
}

output "bastion_instance_public_ip" {
  value       = module.bastion_autoscaling_group.asg_instance_public_ip
  description = "Bastion instance public ip addresses."
}

output "bastion_instance_private_ip" {
  value       = module.bastion_autoscaling_group.asg_instance_private_ip
  description = "Bastion instance private ip addresses."
}
