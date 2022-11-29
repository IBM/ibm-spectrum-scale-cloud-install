output "cluster_type" {
  value       = local.cluster_type
  description = "Cluster type (Ex: storage, compute, combined)"
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
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? module.storage_private_subnet.subnet_id : null
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? module.compute_private_subnet.subnet_id : null
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_storage_nat_gateways" {
  value       = (local.cluster_type == "storage" || local.cluster_type == "combined") ? module.storage_nat_gateway.nat_gw_id : null
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway."
}

output "vpc_compute_nat_gateways" {
  value       = (local.cluster_type == "compute" || local.cluster_type == "combined") ? module.compute_nat_gateway.nat_gw_id : null
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway."
}

output "vpc_internet_gateway" {
  value       = module.vpc_internet_gw.internet_gw_id
  description = "The ID of the Internet Gateway."
}

output "vpc_s3_public_endpoint" {
  value       = module.vpc_public_endpoint.vpce_id
  description = "The ID of the vpc s3 endpoint associated with public subnets."
}

output "vpc_s3_private_endpoint" {
  value       = module.vpc_private_endpoint.vpce_id
  description = "The ID of the vpc s3 endpoint associated with private subnets."
}
