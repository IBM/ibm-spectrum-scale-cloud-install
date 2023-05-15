output "vpc_ref" {
  value       = module.vpc.vpc_self_link
  description = "VPC name."
}

output "cluster_type" {
  value       = local.cluster_type
  description = "Cluster type (Ex: storage, compute, combined)"
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_name
  description = "List of IDs of public subnets."
}

output "vpc_storage_cluster_private_subnets" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? module.storage_private_subnet.subnet_name : null
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? module.compute_private_subnet.subnet_name : null
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_compute_nat_gateways" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? module.compute_cloud_nat.cloud_nat_id : null
  description = "List of IDs of compute cluster nat gateway."
}

output "vpc_storage_nat_gateways" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? module.storage_cloud_nat.cloud_nat_id : null
  description = "List of IDs of storage cluster nat gateway."
}
