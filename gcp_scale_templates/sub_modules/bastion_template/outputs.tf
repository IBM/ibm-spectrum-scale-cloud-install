output "bastion_instance_autoscaling_group_ref" {
  value       = module.bastion_autoscaling_group.instance_group_manager_ref
  description = "Bastion instances autoscaling group (id/self-link)."
}

output "bastion_security_group_ref" {
  value       = local.bastion_network_tag
  depends_on  = [module.allow_traffic_from_external_cidr_to_bastion]
  description = "Bastion firewall id."
}
