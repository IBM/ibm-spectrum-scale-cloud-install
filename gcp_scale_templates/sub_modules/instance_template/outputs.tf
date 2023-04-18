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

output "storage_cluster_security_id" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? concat(module.allow_traffic_scale_cluster_storage_internals.firewall_uri_ingress_bi, module.allow_traffic_scale_cluster_compute_to_storage.firewall_uri_ingress_bi, module.allow_traffic_scale_cluster_storage_egress_all.firewall_uri_egress, module.allow_traffic_scale_cluster_storage_egress_all.firewall_uri_egress_all) : null
  description = "Storage cluster security ids."
}

output "compute_cluster_security_id" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? concat(module.allow_traffic_scale_cluster_compute_internal.firewall_uri_ingress_bi, module.allow_traffic_scale_cluster_storage_to_compute.firewall_uri_ingress_bi) : null
  description = "Compute cluster security ids."
}