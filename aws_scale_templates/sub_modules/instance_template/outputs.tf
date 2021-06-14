output "compute_cluster_instance_ids" {
  value       = module.compute_cluster_instances.instance_ids
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = module.compute_cluster_instances.instance_private_ips
  description = "Private IP address of compute cluster instances."
}

output "storage_cluster_instance_ids" {
  value       = module.storage_cluster_instances.instance_ids
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = module.storage_cluster_instances.instance_private_ips
  description = "Private IP address of storage cluster instances."
}

output "storage_cluster_with_data_volume_mapping" {
  value = module.storage_cluster_instances.instance_ips_with_ebs_mapping
}
