output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "VPC name."
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_id
  description = "List of IDs of public subnets."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.compute_private_subnet.subnet_id
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_compute_cluster_nat" {
  value       = module.compute_cloud_nat.cloud_nat_id
  description = "List of IDs of compute cluster nat."
}

output "vpc_storage_cluster_nat" {
  value       = module.storage_cloud_nat.cloud_nat_id
  description = "List of IDs of storage cluster nat."
}
