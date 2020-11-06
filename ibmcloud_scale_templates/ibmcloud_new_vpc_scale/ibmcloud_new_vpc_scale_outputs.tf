output "operating_env" {
  value       = var.operating_env
  description = "Operating environement (valid: local)."
}

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

output "private_subnets" {
  value       = module.vpc_module.private_subnets
  description = "IBM Cloud private subnet IDs."
}

output "bastion_instance_public_ip" {
  value       = module.bastion_module.bastion_fip
  description = "IBM Cloud bastion instance public IP addresses."
}

output "bastion_instance_id" {
  value       = module.bastion_module.bastion_vsi_id
  description = "IBM Cloud bastion instance ID."
}

output "volume_1A_ids" {
  value = module.instances_module.volume_1A_ids
}

output "volume_2A_ids" {
  value = module.instances_module.volume_2A_ids
}
