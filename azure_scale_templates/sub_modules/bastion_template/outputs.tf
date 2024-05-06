output "bastion_instance_public_ip" {
  value       = module.bastion_autoscaling_group[*].instance_public_ips
  description = "Bastion instance public ip address."
}

output "bastion_instance_autoscaling_group_ref" {
  value       = try(module.bastion_autoscaling_group[0].instance_ids[0], null)
  description = "Bastion instance id."
}

output "bastion_service_instance_id" {
  value       = module.azure_bastion_service[*].bastion_service_id
  description = "Bastion service instance id."
}

output "bastion_service_instance_dns_name" {
  value       = module.azure_bastion_service[*].bastion_service_dns_name
  description = "Bastion instance dns name."
}

output "bastion_security_group_ref" {
  value       = module.bastion_app_security_grp.asg_id
  description = "Bastion network security group name."
}
