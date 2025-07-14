output "vpc_compute_cluster_dns_service_id" {
  value       = module.dns_service.resource_guid
  description = "IBM Cloud DNS compute cluster resource instance server ID."
}

output "vpc_compute_dns_zone_id" {
  value       = module.compute_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}

output "vpc_storage_cluster_dns_service_id" {
  value       = module.dns_service.resource_guid
  description = "IBM Cloud DNS storage cluster resource instance server ID."
}

output "vpc_storage_dns_zone_id" {
  value       = module.storage_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}
