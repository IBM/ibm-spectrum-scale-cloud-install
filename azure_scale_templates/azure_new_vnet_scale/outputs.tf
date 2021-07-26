output "compute_cluster_instance_ids" {
  value       = module.scale_instances.compute_cluster_instance_ids
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = module.scale_instances.compute_cluster_instance_private_ips
  description = "Private IP address of compute cluster instances."
}
