output "vpc_ref" {
  value       = module.vpc.vpc_self_link
  description = "VPC name."
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_uri
  description = "List of IDs of public subnets."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_uri
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.compute_private_subnet.subnet_uri
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_compute_nat_gateways" {
  value       = module.compute_cloud_nat.cloud_nat_id
  description = "List of IDs of compute cluster nat gateway."
}

output "vpc_storage_nat_gateways" {
  value       = module.storage_cloud_nat.cloud_nat_id
  description = "List of IDs of storage cluster nat gateway."
}
