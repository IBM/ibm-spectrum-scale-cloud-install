output "airgap" {
  value       = var.airgap
  description = "Air gap environment"
}

output "bastion_user" {
  value       = var.bastion_user
  description = "Bastion OS Login username."
}

output "ces_nic_ids" {
  value       = [for nic in module.protocol_enis : nic.eni_ids]
  description = "CES/Protocol ENI (secondary nic) ids."
}

output "ces_private_ips" {
  value       = local.separate_nic ? [] : var.ces_private_ips
  description = "CES/Protocol ENI (secondary private) ips."
}

output "cluster_sns_arn" {
  value = module.email_notification.topic_arn
}

output "compute_cluster_instance_cidrs" {
  value = [for subnet in data.aws_subnet.vpc_compute_cluster_private_subnet_cidrs : subnet.cidr_block]
}

output "compute_cluster_instance_details" {
  value       = [for instance in module.compute_cluster_instances : instance.instance_details]
  description = "Compute cluster instance details (map of id, private_ip, dns)"
}

output "compute_cluster_security_group_id" {
  value       = module.compute_cluster_security_group.sec_group_id
  description = "Compute cluster security group id."
}

output "gateway_instance_details" {
  value       = [for instance in module.gateway_instances : instance.instance_details]
  description = "Gateway instance details (map of id, private_ip, dns)"
}

output "instance_iam_profile" {
  value = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
}

output "placement_group_id" {
  value       = local.create_placement_group == true ? aws_placement_group.itself[0].id : null
  description = "Placement group id."
}

output "protocol_instance_details" {
  value       = [for instance in module.protocol_instances : instance.instance_details]
  description = "Protocol instance details (map of id, private_ip, dns)"
}

output "protocol_cluster_security_group_id" {
  value       = module.protocol_security_group.sec_group_id
  description = "Protocol cluster security group id."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = local.storage_instance_desc_ip_with_disk_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "storage_cluster_dec_instance_details" {
  value       = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
  description = "Storage cluster desc instance details (map of id, private_ip, dns)"
}

output "storage_cluster_instance_cidrs" {
  value = [for subnet in data.aws_subnet.vpc_storage_cluster_private_subnet_cidrs : subnet.cidr_block]
}

output "storage_cluster_instance_details" {
  value       = [for instance in module.storage_cluster_instances : instance.instance_details]
  description = "Protocol instance details (map of id, private_ip, dns)"
}

output "storage_cluster_security_group_id" {
  value       = module.storage_cluster_security_group.sec_group_id
  description = "Storage cluster security group id."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = local.storage_instance_ips_with_disk_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}
