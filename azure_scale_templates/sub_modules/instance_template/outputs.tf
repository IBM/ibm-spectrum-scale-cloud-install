output "airgap" {
  value       = var.airgap
  description = "Air gap environment"
}

output "bastion_user" {
  value       = var.bastion_user
  description = "Bastion OS Login username."
}

output "compute_cluster_instance_details" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_details]
  description = "Compute cluster instance details (map of id, private_ip, dns)"
}

output "compute_cluster_security_group_id" {
  value       = module.cluster_security_group.asg_id
  description = "Compute cluster security ids."
}

output "gateway_instance_details" {
  value       = [for instance in module.gateway_instances : instance.instance_details]
  description = "Gateway instance details (map of id, private_ip, dns)"
}

output "placement_group_id" {
  value       = local.create_placement_group == true ? var.resource_prefix : null
  description = "Placement group id."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = local.storage_instance_desc_ip_with_disk_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "storage_cluster_desc_instance_ids" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids]
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips]
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_instance_details" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_details]
  description = "Protocol instance details (map of id, private_ip, dns)"
}

output "storage_cluster_security_group_id" {
  value       = module.cluster_security_group.asg_id
  description = "Storage cluster security group id."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = local.storage_instance_ips_with_disk_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}
