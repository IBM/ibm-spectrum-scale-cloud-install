output "vnet_id" {
  value       = module.vnet.vnet_id
  description = "The ID of the VNET."
}

output "resource_group_name" {
  value       = module.vnet.resource_group_name
  description = "New resource group name"
}

output "ansible_jump_host_id" {
  value       = module.ansible_jump_host.ansible_jump_host_id
  description = "Ansible jump host instance id."
}

output "ansible_jump_host_public_ip" {
  value       = module.ansible_jump_host.ansible_jump_host_public_ip
  description = "Ansible jump host instance public ip addresses."
}

output "ansible_jump_host_private_ip" {
  value       = module.ansible_jump_host.ansible_jump_host_private_ip
  description = "Ansible jump host instance private ip addresses."
}

output "bastion_instance_public_ip" {
  value       = module.bastion.bastion_instance_public_ip
  description = "Bastion instance public ip addresses."
}

output "compute_cluster_instance_ids" {
  value       = module.scale_instances.compute_cluster_instance_ids
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = module.scale_instances.compute_cluster_instance_private_ips
  description = "Private IP address of compute cluster instances."
}

output "storage_cluster_instance_ids" {
  value       = module.scale_instances.storage_cluster_instance_ids
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = module.scale_instances.storage_cluster_instance_private_ips
  description = "Private IP address of storage cluster instances."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = module.scale_instances.storage_cluster_with_data_volume_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}
