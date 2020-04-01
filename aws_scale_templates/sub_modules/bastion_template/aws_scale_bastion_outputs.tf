output "bastion_sec_group_id" {
  value       = module.bastion_security_group.sec_group_id[0]
  description = "Bastion security group id."
}
