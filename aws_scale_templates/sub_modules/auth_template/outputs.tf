output "ldap_instance_details" {
  value       = module.self_managed_ldap.instance_details
  description = "Self-managed ldap instance details (map of id, private_ip, dns)."
}

output "ldap_security_group_ref" {
  value       = module.ldap_security_group.sec_group_id
  description = "Self-managed ldap security group reference (id/self-link)."
}

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
