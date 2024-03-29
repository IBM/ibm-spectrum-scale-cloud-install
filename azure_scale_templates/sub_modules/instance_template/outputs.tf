output "compute_cluster_instance_ids" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_ids]
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_private_ips]
  description = "Private IP address of compute cluster instances."
}

output "storage_cluster_instance_ids" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_ids]
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_private_ips]
  description = "Private IP address of storage cluster instances."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = local.storage_instance_ips_with_disk_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}

output "bastion_user" {
  value       = var.bastion_user
  description = "Bastion OS Login username."
}

output "storage_cluster_desc_instance_ids" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids]
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips]
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = local.storage_instance_desc_ip_with_disk_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "scale_cluster_asg_id" {
  value       = module.scale_cluster_asg.asg_id
  description = "Scale cluster Asg id."
}

output "storage_cluster_security_group_id" {
  value       = module.scale_cluster_nsg.sec_group_id
  description = "Storage cluster security group id."
}

output "compute_cluster_security_group_id" {
  value       = module.scale_cluster_nsg.sec_group_id
  description = "Compute cluster security group id."
}
