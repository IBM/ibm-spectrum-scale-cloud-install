output "vnet_id" {
  value       = module.vnet.vnet_id
  description = "The ID of the vnet."
}

/*
output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "New resource group name"
}

output "vnet_public_subnets" {
  value       = module.public_subnet.sub_id
  description = "List of IDs of public subnets."
}

output "vnet_storage_cluster_private_subnets" {
  value       = module.vnet_strg_private_subnet.sub_id
  description = "List of IDs of storage cluster private subnets."
}

output "vnet_compute_cluster_private_subnets" {
  value       = module.vnet_comp_private_subnet.sub_id
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