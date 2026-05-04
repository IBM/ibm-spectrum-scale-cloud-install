output "bastion_instance_autoscaling_group_id" {
  value       = try(module.bastion_autoscaling_group[0].asg_id, null)
  description = "Bastion instances autoscaling group ID."
}

output "bastion_instance_autoscaling_group_crn" {
  value       = try(module.bastion_autoscaling_group[0].asg_crn, null)
  description = "Bastion instances autoscaling group CRN."
}

output "bastion_security_group_id" {
  value       = try(module.bastion_security_group[0].sec_group_id, null)
  description = "Bastion security group ID."
}

output "bastion_public_ip_addresses" {
  value       = try(module.bastion_autoscaling_group[0].floating_ip_addresses, [])
  description = "List of public IP addresses for bastion instances."
}
