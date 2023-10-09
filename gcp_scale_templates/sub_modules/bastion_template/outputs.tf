output "bastion_instance_autoscaling_group_ref" {
  value       = module.bastion_autoscaling_group.instance_group_manager_ref
  description = "Bastion instances autoscaling group (id/self-link)."
}

output "bastion_security_group_id" {
  value       = local.bastion_network_tag
  depends_on  = [module.allow_traffic_from_external_cidr_to_bastion]
  description = "Bastion firewall id."
}

output "bastion_instance_name" {
  value       = [for instance in module.bastion_autoscaling_group.instances : trimsuffix(element(split("/", instance), 10), "\"")]
  description = "Bastion instance names."
}

output "bastion_instance_ref" {
  value       = [for instance in module.bastion_autoscaling_group.instances : instance]
  description = "Bastion instance Ids."
}

output "bastion_instance_private_ip" {
  value       = data.google_compute_instance.itself[*].network_interface[0].network_ip
  description = "Bastion instance private ips."
  depends_on  = [data.google_compute_instance.itself]
}

output "bastion_instance_public_ip" {
  value       = data.google_compute_instance.itself[*].network_interface[0].access_config[0].nat_ip
  description = "Bastion instance public ips."
  depends_on  = [data.google_compute_instance.itself]
}
