output "ansible_jump_host_id" {
  value       = try(module.ansible_jump_host.instance_ids[0], "")
  description = "Ansible jump host instance ids."
}

output "ansible_jump_host_public_ip" {
  value       = try(module.ansible_jump_host.instance_public_ips[0], "")
  description = "Ansible jump host instance public ip address."
}

output "ansible_jump_host_private_ip" {
  value       = try(module.ansible_jump_host.instance_private_ips[0], "")
  description = "Ansible jump host instance private ip address."
}
