output "vpc_id" {
  value       = module.vnet.vnet_id
  description = "The ID of the vpc."
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "New resource group name"
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_id
  description = "List of IDs of public subnets."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.vnet_strg_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.vnet_comp_private_subnet.subnet_id
  description = "List of IDs of compute cluster private subnets."
}

