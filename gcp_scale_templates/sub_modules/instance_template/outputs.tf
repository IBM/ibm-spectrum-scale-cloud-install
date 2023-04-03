output "storage_cluster_instance_ids" {
  value       = flatten(module.storage_cluster_instances[*].instance_ids)
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       =  flatten(module.storage_cluster_instances[*].instance_ips)
  description = "Storage cluster private ips."
}

output "storage_cluster_with_data_volume_mapping" {
  value       =  module.storage_cluster_instances[*].disk_device_mapping
  description = "Storage cluster data volume mapping."
}

output "storage_cluster_with_dns_hostname" {
  value       =  module.storage_cluster_instances[*].dns_hostname
  description = "Storage cluster dns hostname mapping."
}

output "compute_cluster_instance_ids" {
  value       = flatten(module.compute_cluster_instances[*].instance_ids)
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       =  flatten(module.compute_cluster_instances[*].instance_ips)
  description = "Compute cluster private ips."
}

output "storage_cluster_desc_instance_ids" {
  value       = module.storage_cluster_tie_breaker_instance[*].instance_ids
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = module.storage_cluster_tie_breaker_instance[*].instance_ips
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = module.storage_cluster_tie_breaker_instance[*].disk_device_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}