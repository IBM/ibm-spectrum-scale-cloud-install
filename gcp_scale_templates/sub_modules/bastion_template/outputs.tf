output "bastion_firewall_id" {
  value       = module.bastion_firewall.firewall_id
  description = "Bastion firewall id."
}

output "bastion_firewall_name" {
  value       = module.bastion_firewall.firewall_name
  description = "Bastion firewall name."
}

output "bastion_instance_name" {
  value       = [for instance in module.bastion_autoscaling_group.instances : trimsuffix(element(split("/",instance),10),"\"")]
  description = "Bastion instance names."
}

output "bastion_instance_id" {
  value       = data.google_compute_instance.bastion_metadata[*].id
  description = "Bastion instance Ids."
}

output "bastion_instance_private_ip" {
  value       = data.google_compute_instance.bastion_metadata[*].network_interface.0.network_ip
  description = "Bastion instance ips."
  depends_on  = [data.google_compute_instance.bastion_metadata]
}

output "bastion_instance_public_ip" {
  value       = data.google_compute_instance.bastion_metadata[*].network_interface.0.access_config.0.nat_ip
  description = "Bastion instance ips."
  depends_on  = [data.google_compute_instance.bastion_metadata]
}