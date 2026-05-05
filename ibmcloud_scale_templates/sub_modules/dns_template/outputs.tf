output "dns_service_instance_id" {
  value       = local.dns_instance_id
  description = "IBM Cloud DNS Service Instance ID (either provided or newly created)."
}

output "dns_service_instance_crn" {
  value       = var.dns_service_instance_id != null ? null : one(ibm_resource_instance.dns_service[*].crn)
  description = "IBM Cloud DNS Service Instance CRN (only available if newly created)."
}

output "vpc_compute_dns_zone_id" {
  value       = module.compute_dns_zone.dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}

output "vpc_storage_dns_zone_id" {
  value       = module.storage_dns_zone.dns_zone_id
  description = "IBM Cloud DNS storage cluster zone ID."
}

output "vpc_protocol_dns_zone_id" {
  value       = module.protocol_dns_zone.dns_zone_id
  description = "IBM Cloud DNS protocol cluster zone ID."
}
