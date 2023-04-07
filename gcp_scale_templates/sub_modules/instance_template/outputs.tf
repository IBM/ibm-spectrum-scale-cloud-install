output "storage_cluster_instance_ids" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? flatten(module.storage_cluster_instances[*].instance_selflink) : null
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? flatten(module.storage_cluster_instances[*].instance_ips) : null
  description = "Storage cluster private ips."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? module.storage_cluster_instances[*].disk_device_mapping : null
  description = "Storage cluster data volume mapping."
}

output "storage_cluster_with_dns_hostname" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? module.storage_cluster_instances[*].dns_hostname : null
  description = "Storage cluster dns hostname mapping."
}

output "compute_cluster_instance_ids" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? flatten(module.compute_cluster_instances[*].instance_selflink) : null
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? flatten(module.compute_cluster_instances[*].instance_ips) : null
  description = "Compute cluster private ips."
}

output "storage_cluster_desc_instance_ids" {
  value       = length(var.vpc_availability_zones) > 2 && local.cluster_type != "compute" ? module.storage_cluster_tie_breaker_instance[*].instance_selflink : null
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = length(var.vpc_availability_zones) > 2 && local.cluster_type != "compute" ? module.storage_cluster_tie_breaker_instance[*].instance_ips : null
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = length(var.vpc_availability_zones) > 2 && local.cluster_type != "compute" ? module.storage_cluster_tie_breaker_instance[*].disk_device_mapping : null
  description = "Mapping of storage cluster desc instance ip vs. device path."
}
