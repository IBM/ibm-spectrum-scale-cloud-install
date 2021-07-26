output "vnet_id" {
  value       = module.vnet.vnet_id
  description = "The ID of the VNET."
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "New resource group name"
}

output "vnet_public_subnets" {
  value       = module.create_subnet.subnet_id[0]
  description = "List of IDs of public subnets."
}

output "vnet_storage_cluster_private_subnets" {
  value       = [module.create_subnet.subnet_id[1]]
  description = "List of IDs of storage cluster private subnets."
}

output "vnet_compute_cluster_private_subnets" {
  value       = var.vnet_create_separate_subnets == true ? [module.create_subnet.subnet_id[2]] : []
  description = "List of IDs of compute cluster private subnets."
}

output "vnet_storage_private_dns_zone_name" {
  value       = module.storage_private_dns_zone.private_dns_zone_name
  description = "Storage cluster private DNS zone name."
}

output "vnet_compute_private_dns_zone_name" {
  value       = var.vnet_create_separate_subnets == true ? module.compute_private_dns_zone.private_dns_zone_name : null
  description = "Compute cluster private DNS zone name."
}
