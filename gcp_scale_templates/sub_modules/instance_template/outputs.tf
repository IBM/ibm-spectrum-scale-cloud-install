output "airgap" {
  value       = var.airgap
  description = "Air gap environment"
}

output "compute_cluster_instance_ids" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_selflink]
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_private_ips]
  description = "Compute cluster private ips."
}

output "compute_cluster_security_group_id" {
  value       = local.scale_cluster_network_tag
  description = "Compute cluster security ids."
}

output "compute_cluster_with_dns_hostname" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_private_dns_name]
  description = "Compute cluster dns hostname mapping."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = local.storage_instance_desc_ip_with_disk_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "storage_cluster_desc_instance_ids" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_selflink]
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ip]
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_with_dns_hostname" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_dns_name]
  description = "Storage cluster desc dns hostname mapping."
}

output "storage_cluster_instance_ids" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_selflink]
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_private_ips]
  description = "Storage cluster private ips."
}

output "storage_cluster_security_group_id" {
  value       = local.scale_cluster_network_tag
  description = "Storage cluster security ids."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = local.storage_instance_ips_with_disk_mapping
  description = "Storage cluster data volume mapping."
}

output "storage_cluster_with_dns_hostname" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_private_dns_name]
  description = "Storage cluster dns hostname mapping."
}

output "vpc_compute_cloud_dns" {
  value       = module.compute_dns_zone.dns_managed_zone_id
  description = "List of IDs of compute cluster cloud DNS."
}

output "vpc_storage_cloud_dns" {
  value       = module.storage_dns_zone.dns_managed_zone_id
  description = "List of IDs of storage cluster cloud DNS."
}
