output "managed_ad_access_url" {
  value       = module.managed_ad.ad_access_url
  description = "Managed AD access url."
}

output "managed_ad_dns_ip_addresses" {
  value       = module.managed_ad.ad_dns_ip_addresses
  description = "Managed AD DNS ip addresses."
}

output "managed_ad_security_group_ref" {
  value       = module.managed_ad.ad_security_group_id
  description = "Managed AD security group reference."
}
