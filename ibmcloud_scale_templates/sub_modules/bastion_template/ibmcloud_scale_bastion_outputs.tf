output "stack_name" {
  value = var.stack_name
}

output "bastion_sec_grp_id" {
  value = module.bastion_security_group.sec_group_id[0]
}

output "bastion_vsi_id" {
  value = module.bastion_vsi.vsi_ids[0]
}

output "bastion_fip" {
  value = module.bastion_attach_fip.floating_ip_addr
}
