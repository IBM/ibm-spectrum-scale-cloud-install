output "compute_instance_ids" {
  value       = module.instance_modules.compute_instance_ids
  description = "GCP compute instance ids."
}

output "compute_instance_ips" {
  value       = module.instance_modules.compute_instance_ips
  description = "Private IP address of GCP compute instances."
}

output "compute_instance_desc_ip" {
  value       = module.instance_modules.compute_instance_desc_ip
  description = "Private IP address of GCP desc compute instance."
}

output "compute_instance_desc_id" {
  value       = module.instance_modules.compute_instance_desc_id
  description = "GCP compute desc instance id."
}

output "storage_instance_1A_zone_ids" {
  value       = module.instance_modules.storage_instance_1A_zone_ids
  description = "GCP storage instance ids."
}

output "storage_instance_1A_zone_ips" {
  value       = module.instance_modules.storage_instance_1A_zone_ips
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_2A_zone_ids" {
  value       = module.instance_modules.storage_instance_2A_zone_ids
  description = "GCP storage instance ids."
}

output "storage_instance_2A_zone_ips" {
  value       = module.instance_modules.storage_instance_2A_zone_ips
  description = "Private IP address of GCP storage instances."
}

output "bastion_instance_public_ip" {
  value       = module.bastion_module.bastion_instance_public_ip
  description = "GCP storage instance ids."
}

output "bastion_instance_private_ip" {
  value       = module.bastion_module.bastion_instance_private_ip
  description = "Private IP address of GCP storage instances."
}
