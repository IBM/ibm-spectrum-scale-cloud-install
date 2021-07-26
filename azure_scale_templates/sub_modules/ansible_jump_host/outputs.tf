output "ansible_jump_host_id" {
  value       = module.ansible_jump_host.instance_ids
  description = "Ansible jump host instance ids."
}

output "ansible_jump_host_public_ip" {
  value       = module.ansible_jump_host.instance_public_ips
  description = "Ansible jump host instance public ip address."
}

output "ansible_jump_host_private_ip" {
  value       = module.ansible_jump_host.instance_private_ips
  description = "Ansible jump host instance private ip address."
}
