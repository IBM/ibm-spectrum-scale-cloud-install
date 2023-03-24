output "compute_cluster_instance_details" {
  value       = module.compute_cluster_instances
  description = "GCP compute instance details."
}

output "storage_cluster_instance_details" {
  value       = module.storage_cluster_instances
  description = "GCP compute instance details."
}

output "storage_cluster_tie_breaker_instance_details" {
  value       = module.storage_cluster_tie_breaker_instance
  description = "GCP compute desc instance details."
}

output "storage_cluster_instance_ids" {
  value       = module.storage_cluster_instances[0].instance_ids
  description = "GCP storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       =  module.storage_cluster_instances[0].instance_ips
  description = "GCP storage cluster private ips."
}

output "storage_cluster_with_data_volume_mapping" {
  value       =  module.storage_cluster_instances[0
  ].disk_device_mapping
  description = "GCP storage cluster data volume mapping."
}
