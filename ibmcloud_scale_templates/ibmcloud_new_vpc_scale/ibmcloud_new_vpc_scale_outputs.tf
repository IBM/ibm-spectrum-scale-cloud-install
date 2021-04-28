output "cloud_platform" {
  value       = "IBMCloud"
  description = "Flag to represent IBM cloud."
}

output "stack_name" {
  value       = var.stack_name
  description = "IBM Cloud Stack name."
}

output "vpc_id" {
  value       = module.vpc_module.vpc_id
  description = "IBM Cloud VPC ID."
}
/*
output "primary_private_subnets" {
  value       = module.vpc_module.primary_private_subnets
  description = "IBM Cloud primary private subnet IDs."
}

output "secondary_private_subnets" {
  value       = module.vpc_module.secondary_private_subnets
  description = "IBM Cloud primary secondary subnet IDs."
}
*/
output "bastion_vsi_public_ip" {
  value       = module.bastion_module.bastion_fip
  description = "IBM Cloud bastion instance public IP addresses."
}

output "bastion_vsi_id" {
  value       = module.bastion_module.bastion_vsi_id
  description = "IBM Cloud bastion instance ID."
}
/*
output "volume_1A_ids" {
  value = module.instances_module.volume_1A_ids
}

output "volume_2A_ids" {
  value = module.instances_module.volume_2A_ids
}

output "compute_vsi_primary_ips" {
  value = module.instances_module.compute_vsi_primary_ips
}

output "compute_vsi_secondary_ips" {
  value = module.instances_module.compute_vsi_secondary_ips
}

output "desc_compute_vsi_primary_ip" {
  value = module.instances_module.desc_compute_vsi_primary_ip
}

output "desc_compute_vsi_secondary_ip" {
  value = module.instances_module.desc_compute_vsi_secondary_ip
}

output "storage_vsi_1A_primary_ips" {
  value = module.instances_module.storage_vsi_1A_primary_ips
}

output "storage_vsi_1A_secondary_ips" {
  value = module.instances_module.storage_vsi_1A_secondary_ips
}

output "storage_vsi_2A_primary_ips" {
  value = module.instances_module.storage_vsi_2A_primary_ips
}

output "storage_vsi_2A_secondary_ips" {
  value = module.instances_module.storage_vsi_2A_secondary_ips
}
*/
