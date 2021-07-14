output "bastion_security_group_id" {
  value       = module.bastion_network_security_group.sec_group_id
  description = "Bastion security group id."
}

output "bastion_instance_public_ip" {
  value       = module.bastion_public_ip.public_ip
  description = "Bastion instance public ip address."
}

output "bastion_instance_fqdn" {
  value       = module.bastion_host.bastion_dns_name
  description = "Bastion instance fqdn."
}
