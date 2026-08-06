output "airgap" {
  value       = var.airgap
  description = "Air gap environment"
}

output "storage_cluster_security_group_id" {
  value       = module.cluster_security_group.sec_group_id
  description = "Storage cluster security group id."
}

output "compute_cluster_security_group_id" {
  value       = module.cluster_security_group.sec_group_id
  description = "Compute cluster security group id."
}

output "protocol_cluster_security_group_id" {
  value       = module.protocol_security_group.sec_group_id
  description = "Protocol cluster security group id."
}

output "ces_private_ips" {
  value       = [for ip in module.protocol_instances : ip.ces_private_ip]
  description = "CES/Protocol ENI (secondary private) ips."
}

output "compute_cluster_instance_details" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_details]
  description = "Compute cluster instance details (map of id, private_ip, dns)"
}

output "compute_cluster_instance_ids" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_details.id]
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_details.private_ip]
  description = "Private IP address of compute cluster instances."
}

output "gateway_instance_details" {
  value       = [for instance in module.gateway_instances : instance.instance_details]
  description = "Gateway instance details (map of id, private_ip, dns)"
}

/*
output "instance_iam_profile" {
  value = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
}
*/

output "placement_group_id" {
  value       = local.create_placement_group ? ibm_is_placement_group.storage_cluster[0].id : null
  description = "IBM Cloud placement group id."
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

output "storage_cluster_desc_instance_ids" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details.id]
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details.private_ip]
  description = "Private IP address of storage cluster desc instance."
}

# output "storage_cluster_instance_cidrs" {
#   value = [for subnet in data.aws_subnet.vpc_storage_cluster_private_subnet_cidrs : subnet.cidr_block]
# }

output "storage_cluster_instance_details" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_details]
  description = "Protocol instance details (map of id, private_ip, dns)"
}

output "storage_cluster_instance_ids" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_details.id]
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_details.private_ip]
  description = "Private IP address of storage cluster instances."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = local.storage_instance_ips_with_disk_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}

output "storage_vm_zone_map" {
  value = local.storage_vm_zone_map
}


output "storage_instance_ips_with_disk_mapping" {
  value = local.storage_instance_ips_with_disk_mapping
}

output "storage_cluster_instance_id_name_map" {
  value       = { for instance in module.storage_cluster_instances : instance.instance_details.id => instance.instance_details.dns }
  description = "Map of storage cluster instance ID to DNS hostname."
}

output "protocol_cluster_instance_id_name_map" {
  value       = { for instance in module.protocol_instances : instance.instance_details.id => instance.instance_details.dns }
  description = "Map of protocol cluster instance ID to DNS hostname."
}

output "storage_cluster_volume_ids" {
  value       = length(module.storage_cluster_instances) > 0 ? merge([for instance in module.storage_cluster_instances : instance.volume_ids]...) : {}
  description = "Flat map of disk-key to volume ID for all storage cluster data volumes."
}

output "storage_cluster_desc_volume_ids" {
  value       = length(module.storage_cluster_tie_breaker_instance) > 0 ? merge([for instance in module.storage_cluster_tie_breaker_instance : instance.volume_ids]...) : {}
  description = "Flat map of disk-key to volume ID for storage cluster tiebreaker data volumes."
}
