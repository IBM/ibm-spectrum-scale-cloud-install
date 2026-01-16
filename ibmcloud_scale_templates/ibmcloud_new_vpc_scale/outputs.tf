output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.vpc.vpc_storage_cluster_private_subnets
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.vpc.vpc_compute_cluster_private_subnets
  description = "List of IDs of compute cluster private subnets."
}

output "bastion_security_group_id" {
  value       = module.bastion.bastion_security_group_id
  description = "Bastion security group id."
}

output "bastion_instance_public_ip" {
  value       = module.bastion.bastion_instance_public_ip
  description = "Bastion instance public ip addresses."
}

output "bastion_instance_private_ip" {
  value       = module.bastion.bastion_instance_private_ip
  description = "Bastion instance private ip addresses."
}

output "bastion_instance_id" {
  value       = module.bastion.bastion_instance_id
  description = "Bastion instance id."
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

output "storage_cluster_desc_instance_ids" {
  value       = module.scale_instances.storage_cluster_desc_instance_ids
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = module.scale_instances.storage_cluster_desc_instance_private_ips
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = module.scale_instances.storage_cluster_desc_data_volume_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}
