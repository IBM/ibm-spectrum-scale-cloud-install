output "vpc_ref" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "The name of the VPC."
}

output "vpc_crn" {
  value       = module.vpc.vpc_crn
  description = "The CRN of the VPC."
}

output "resource_group_id" {
  value       = data.ibm_resource_group.itself.id
  description = "The ID of the resource group used for VPC resources."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets, if storage subnets are enabled for the selected cluster type."
}

output "vpc_storage_cluster_private_subnets_name" {
  value       = module.storage_private_subnet.subnet_name
  description = "List of names of storage cluster private subnets, if storage subnets are enabled for the selected cluster type."
}

output "vpc_storage_cluster_private_subnets_crn" {
  value       = module.storage_private_subnet.subnet_crn
  description = "List of CRNs of storage cluster private subnets, if storage subnets are enabled for the selected cluster type."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.compute_private_subnet.subnet_id
  description = "List of IDs of compute cluster private subnets, if compute subnets are enabled for the selected cluster type."
}

output "vpc_compute_cluster_private_subnets_name" {
  value       = module.compute_private_subnet.subnet_name
  description = "List of names of compute cluster private subnets, if compute subnets are enabled for the selected cluster type."
}

output "vpc_compute_cluster_private_subnets_crn" {
  value       = module.compute_private_subnet.subnet_crn
  description = "List of CRNs of compute cluster private subnets, if compute subnets are enabled for the selected cluster type."
}

output "vpc_protocol_private_subnets" {
  value       = module.protocol_private_subnet.subnet_id
  description = "List of IDs of protocol cluster private subnets, if protocol subnets are enabled for the selected cluster type."
}

output "vpc_protocol_private_subnets_name" {
  value       = module.protocol_private_subnet.subnet_name
  description = "List of names of protocol cluster private subnets, if protocol subnets are enabled for the selected cluster type."
}

output "vpc_protocol_private_subnets_crn" {
  value       = module.protocol_private_subnet.subnet_crn
  description = "List of CRNs of protocol cluster private subnets, if protocol subnets are enabled for the selected cluster type."
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_id
  description = "List of IDs of public subnets, if public subnets are enabled."
}

output "vpc_public_subnets_name" {
  value       = module.public_subnet.subnet_name
  description = "List of names of public subnets, if public subnets are enabled."
}

output "vpc_public_subnets_crn" {
  value       = module.public_subnet.subnet_crn
  description = "List of CRNs of public subnets, if public subnets are enabled."
}

output "vpc_public_gateway_ids" {
  value       = module.vpc_internet_gw.public_gw_id
  description = "List of IDs of public gateways created for the enabled subnets across the configured availability zones."
}
