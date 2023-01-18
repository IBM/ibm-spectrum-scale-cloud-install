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
