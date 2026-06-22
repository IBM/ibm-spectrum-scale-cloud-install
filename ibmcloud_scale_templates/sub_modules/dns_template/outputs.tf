output "dns_service_instance_id" {
  value       = local.dns_instance_id
  description = "IBM Cloud DNS Service Instance ID (either provided or newly created)."
}

output "dns_service_instance_crn" {
  value       = var.dns_service_instance_id != null ? null : one(ibm_resource_instance.dns_service[*].crn)
  description = "IBM Cloud DNS Service Instance CRN (only available if newly created)."
}

output "vpc_compute_dns_zone_id" {
  value       = try(module.dns_zone["compute"].dns_zone_id, null)
  description = "IBM Cloud DNS compute cluster zone ID."
}

output "vpc_compute_dns_domain" {
  value       = var.vpc_compute_cluster_dns_domain
  description = "IBM Cloud DNS compute cluster domain name."
}

output "vpc_storage_dns_zone_id" {
  value       = try(module.dns_zone["storage"].dns_zone_id, null)
  description = "IBM Cloud DNS storage cluster zone ID."
}

output "vpc_storage_dns_domain" {
  value       = var.vpc_storage_cluster_dns_domain
  description = "IBM Cloud DNS storage cluster domain name."
}

output "vpc_protocol_dns_zone_id" {
  value       = try(module.dns_zone["protocol"].dns_zone_id, null)
  description = "IBM Cloud DNS protocol cluster zone ID."
}
