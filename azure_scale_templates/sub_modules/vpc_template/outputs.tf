output "vpc_id" {
  value       = module.vpc.vnet_id
  description = "The ID of the vpc."
}

/*
output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "New resource group name"
}

output "vpc_public_subnets" {
  value       = module.public_subnet.sub_id
  description = "List of IDs of public subnets."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.vpc_strg_private_subnet.sub_id
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.vpc_comp_private_subnet.sub_id
  description = "List of IDs of compute cluster private subnets."
}

output "storage_priv_dns_zone_name" {
  value       = module.storage_private_dns_zone.private_dns_zone_name
  description = "The dns zone for storage private zone."
}

output "compute_priv_dns_zone_name" {
  value       = module.compute_private_dns_zone.private_dns_zone_name
  description = "The dns zone for compute private zone."
}
*/