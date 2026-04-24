output "vpc_id" {
  value       = module.vpc.vpc_ref
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

output "transit_gateway_id" {
  value       = module.vpc_peering.transit_gateway_id
  description = "ID of the Transit Gateway used for VPC connectivity."
}

output "transit_gateway_crn" {
  value       = module.vpc_peering.transit_gateway_crn
  description = "CRN of the Transit Gateway used for VPC connectivity."
}

output "transit_gateway_name" {
  value       = module.vpc_peering.transit_gateway_name
  description = "Name of the Transit Gateway."
}

output "new_vpc_connection_id" {
  value       = module.vpc_peering.new_vpc_connection_id
  description = "ID of the Transit Gateway connection for the newly created VPC."
}

output "peer_vpc_connection_id" {
  value       = module.vpc_peering.peer_vpc_connection_id
  description = "ID of the Transit Gateway connection for the peer VPC."
}

output "transit_gateway_status" {
  value       = module.vpc_peering.transit_gateway_status
  description = "Status of the Transit Gateway."
}

output "bastion_security_group_id" {
  value       = module.bastion.bastion_security_group_ref
  description = "Bastion security group id."
}

output "bastion_instance_ref" {
  value       = module.bastion.bastion_instance_autoscaling_group_ref
  description = "Bastion instance autoscaling group reference."
}

/*
output "compute_cluster_instance_ids" {
  value       = try(module.scale_instances.compute_cluster_instance_ids, [])
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = try(module.scale_instances.compute_cluster_instance_private_ips, [])
  description = "Private IP address of compute cluster instances."
}

output "storage_cluster_instance_ids" {
  value       = try(module.scale_instances.storage_cluster_instance_ids, [])
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = try(module.scale_instances.storage_cluster_instance_private_ips, [])
  description = "Private IP address of storage cluster instances."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = try(module.scale_instances.storage_cluster_with_data_volume_mapping, {})
  description = "Mapping of storage cluster instance ip vs. device path."
}

output "storage_cluster_desc_instance_ids" {
  value       = try(module.scale_instances.storage_cluster_desc_instance_ids, [])
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = try(module.scale_instances.storage_cluster_desc_instance_private_ips, [])
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = try(module.scale_instances.storage_cluster_desc_data_volume_mapping, {})
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "placement_group_id" {
  value       = try(module.scale_instances.placement_group_id, null)
  description = "IBM Cloud placement group id for single-AZ deployments."
}
*/
