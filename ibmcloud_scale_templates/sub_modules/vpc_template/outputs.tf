output "vpc_compute_cluster_private_subnets" {
  value       = module.compute_private_subnet.subnet_id
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_protocol_private_subnets" {
  value       = module.protocol_private_subnet.subnet_id
  description = "List of IDs of protocol cluster private subnets."
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_id
  description = "List of IDs of public subnets."
}

output "vpc_ref" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets."
}
