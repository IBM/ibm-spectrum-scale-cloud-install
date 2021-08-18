output "bastion_security_group_id" {
  value       = module.bastion_security_group.sec_group_id[0]
  description = "Bastion security group id."
}

output "bastion_vsi_id" {
  value       = module.bastion_vsi.vsi_id
  description = "Bastion instance id."
}

output "bastion_instance_public_ip" {
  value       = module.bastion_attach_fip.floating_ip_addr
  description = "Bastion instance public ip addresses."
}

output "bastion_instance_private_ip" {
  value       = module.bastion_vsi.vsi_private_ip
  description = "Bastion instance private ip addresses."
}
