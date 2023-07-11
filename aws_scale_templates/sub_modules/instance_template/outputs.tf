output "airgap" {
  value       = var.airgap
  description = "Air gap environment"
}

output "bastion_user" {
  value       = var.bastion_user
  description = "Bastion OS Login username."
}

output "placement_group_id" {
  value       = local.create_placement_group == true ? aws_placement_group.itself[0].id : null
  description = "Placement group id."
}

output "instance_iam_profile" {
  value = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
}

output "compute_cluster_instance_ids" {
  value       = module.compute_cluster_instances.instance_ids
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = module.compute_cluster_instances.instance_private_ips
  description = "Private IP address of compute cluster instances."
}

output "compute_instance_memory_size" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? data.aws_ec2_instance_type.compute_profile[0].memory_size : null
  description = "Compute instance profile memory size."
}

output "storage_cluster_instance_ids" {
  value       = module.storage_cluster_instances.instance_ids
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = module.storage_cluster_instances.instance_private_ips
  description = "Private IP address of storage cluster instances."
}

output "storage_instance_memory_size" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? data.aws_ec2_instance_type.storage_profile[0].memory_size : null
  description = "Storage instance profile memory size."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = module.storage_cluster_instances.instance_ips_with_ebs_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}

output "storage_cluster_desc_instance_ids" {
  value       = module.storage_cluster_tie_breaker_instance.instance_ids
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = module.storage_cluster_tie_breaker_instance.instance_private_ips
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = module.storage_cluster_tie_breaker_instance.instance_ips_with_ebs_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "storage_cluster_security_group_id" {
  value       = module.storage_cluster_security_group.sec_group_id
  description = "Storage cluster security group id."
}

output "compute_cluster_security_group_id" {
  value       = module.compute_cluster_security_group.sec_group_id
  description = "Compute cluster security group id."
}

output "gateway_instance_autoscaling_group_id" {
  value       = module.gateway_autoscaling_group.asg_id
  description = "Gateway instances autoscaling group id."
}

output "storage_cluster_instance_cidrs" {
  value = [for subnet in data.aws_subnet.vpc_storage_cluster_private_subnet_cidrs : subnet.cidr_block]
}

output "compute_cluster_instance_cidrs" {
  value = [for subnet in data.aws_subnet.vpc_compute_cluster_private_subnet_cidrs : subnet.cidr_block]
}
