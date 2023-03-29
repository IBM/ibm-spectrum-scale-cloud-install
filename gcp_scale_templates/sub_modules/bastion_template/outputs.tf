output "bastion_firewall_id" {
  value       = module.bastion_firewall.firewall_id
  description = "Bastion firewall id."
}

output "bastion_firewall_name" {
  value       = module.bastion_firewall.firewall_name
  description = "Bastion firewall name."
}
