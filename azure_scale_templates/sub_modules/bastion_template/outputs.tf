output "bastion_instance_public_ip" {
  value       = module.scale_bastion.instance_public_ips
  description = "Bastion instance public ip address."
}

output "bastion_instance_id" {
  value       = module.scale_bastion.instance_ids
  description = "Bastion instance id."
}
