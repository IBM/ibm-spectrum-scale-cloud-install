output "dns_service_instance_id" {
  value       = local.dns_instance_id
  description = "IBM Cloud DNS Service Instance ID (either provided or newly created)."
}

output "vpc_compute_dns_zone_id" {
  value       = module.compute_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}

output "vpc_storage_dns_zone_id" {
  value       = module.storage_dns_zone.dns_zone_id
  description = "IBM Cloud DNS storage cluster zone ID."
}

output "vpc_compute_cluster_dns_zone" {
  value       = var.vpc_compute_cluster_dns_domain
  description = "IBM Cloud DNS compute cluster zone name."
}

output "vpc_reverse_dns_zone" {
  value       = var.vpc_reverse_dns_domain
  description = "IBM Cloud DNS reverse zone name."
}

output "vpc_storage_cluster_dns_zone" {
  value       = var.vpc_storage_cluster_dns_domain
  description = "IBM Cloud DNS storage cluster zone name."
}

output "vpc_protocol_dns_zone_id" {
  value       = module.protocol_dns_zone.dns_zone_id
  description = "IBM Cloud DNS protocol cluster zone ID."
}

output "vpc_protocol_cluster_dns_zone" {
  value       = var.vpc_protocol_cluster_dns_domain
  description = "IBM Cloud DNS protocol cluster zone name."
}
