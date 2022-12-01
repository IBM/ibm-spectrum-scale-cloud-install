output "bastion_instance_public_ip" {
  value = module.bastion_instance.bastion_public_ip
}

output "bastion_instance_private_ip" {
  value = module.bastion_instance.bastion_private_ip
}