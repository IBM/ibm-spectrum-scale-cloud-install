output "vpc_compute_cluster_dns_zone" {
  value       = var.vpc_compute_cluster_dns_zone
  description = "Route53 DNS zone name/id."
}

output "vpc_compute_dns_zone_id" {
  value       = module.compute_dns_zone.zone_id
  description = "Route53 zone id."
}

output "vpc_reverse_dns_zone" {
  value       = var.vpc_reverse_dns_zone
  description = "Route53 DNS zone name/id."
}

output "vpc_reverse_dns_zone_id" {
  value       = module.reverse_dns_zone.zone_id
  description = "Route53 zone id."
}

output "vpc_storage_cluster_dns_zone" {
  value       = var.vpc_storage_cluster_dns_zone
  description = "Route53 DNS zone name/id."
}

output "vpc_storage_dns_zone_id" {
  value       = module.storage_dns_zone.zone_id
  description = "Route53 zone id."
}
