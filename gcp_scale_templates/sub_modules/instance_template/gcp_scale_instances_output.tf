output "compute_instance_ids" {
  value       = module.compute_instances.instance_ids_with_0_datadisks
  description = "GCP compute instance ids."
}

output "compute_instance_ips" {
  value       = module.compute_instances.instance_ips_with_0_datadisks
  description = "Private IP address of GCP compute instances."
}

output "compute_instance_desc_ip" {
  value       = module.desc_compute_instance.instance_ips_with_1_datadisks
  description = "Private IP address of GCP desc compute instance."
}

output "compute_instance_desc_id" {
  value       = module.desc_compute_instance.instance_ids_with_1_datadisks
  description = "GCP compute desc instance id."
}

output "storage_instance_1A_zone_ids" {
  value       = module.storage_instances_1A_zone.instance_ids
  description = "GCP storage instance ids."
}

output "storage_instance_2A_zone_ids" {
  value       = module.storage_instances_2A_zone.instance_ids
  description = "GCP storage instance ids."
}

output "storage_instance_1A_zone_ips" {
  value       = module.storage_instances_1A_zone.instance_ips
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_2A_zone_ips" {
  value       = module.storage_instances_2A_zone.instance_ips
  description = "Private IP address of GCP storage instances."
}