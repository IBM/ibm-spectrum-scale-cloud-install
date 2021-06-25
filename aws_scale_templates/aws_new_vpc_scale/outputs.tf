output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_public_subnets" {
  value       = module.vpc.vpc_public_subnets
  description = "List of IDs of public subnets."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.vpc.vpc_storage_cluster_private_subnets
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.vpc.vpc_compute_cluster_private_subnets
  description = "List of IDs of compute cluster private subnets."
}

output "bastion_security_group_id" {
  value       = module.bastion.bastion_security_group_id
  description = "Bastion security group id."
}

output "bastion_instance_public_ip" {
  value       = module.bastion.bastion_instance_public_ip
  description = "Bastion instance public ip addresses."
}

output "bastion_instance_private_ip" {
  value       = module.bastion.bastion_instance_private_ip
  description = "Bastion instance private ip addresses."
}
