output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = var.vpc_create_separate_subnets == true ? module.compute_private_subnet.subnet_id : []
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_storage_cluster_dns_service_id" {
  value       = module.dns_service.resource_guid[0]
  description = "IBM Cloud DNS storage cluster resource instance server ID."
}

output "vpc_compute_cluster_dns_service_id" {
  value       = var.vpc_create_separate_subnets == true ? module.dns_service.resource_guid[1] : []
  description = "IBM Cloud DNS compute cluster resource instance server ID."
}

output "vpc_storage_cluster_dns_zone_id" {
  value       = module.storage_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}

output "vpc_compute_cluster_dns_zone_id" {
  value       = module.compute_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}
