output "bastion_instance_public_ip" {
  value       = module.scale_bastion.instance_public_ips
  description = "Bastion instance public ip address."
}

output "bastion_instance_id" {
  value       = module.scale_bastion.instance_ids
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
