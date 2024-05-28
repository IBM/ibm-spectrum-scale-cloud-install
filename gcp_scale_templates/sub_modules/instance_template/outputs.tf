output "airgap" {
  value       = var.airgap
  description = "Air gap environment"
}

output "compute_cluster_instance_details" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_details]
  description = "Compute cluster instance details (map of id, private_ip, dns)"
}

output "compute_cluster_security_group_id" {
  value       = local.scale_cluster_network_tag
  description = "Compute cluster security ids."
}

output "gateway_instance_details" {
  value       = [for instance in module.gateway_instances : instance.instance_details]
  description = "Gateway instance details (map of id, private_ip, dns)"
}

output "protocol_instance_details" {
  value       = [for instance in module.protocol_instances : instance.instance_details]
  description = "Protocol instance details (map of id, private_ip, dns)"
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = local.storage_instance_desc_ip_with_disk_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "storage_cluster_dec_instance_details" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
  description = "Storage cluster desc instance details (map of id, private_ip, dns)"
}

output "storage_cluster_instance_details" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_details]
  description = "Protocol instance details (map of id, private_ip, dns)"
}

output "storage_cluster_security_group_id" {
  value       = local.scale_cluster_network_tag
  description = "Storage cluster security ids."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = local.storage_instance_ips_with_disk_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}
