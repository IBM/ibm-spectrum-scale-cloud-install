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
  value       = var.vpc_create_separate_subnets == true ? module.compute_private_subnet.subnet_id : []
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_nat_gateways" {
  value       = module.nat_gateway.nat_gw_id
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway."
}

output "vpc_internet_gateway" {
  value       = module.vpc_internet_gw.internet_gw_id
  description = "The ID of the Internet Gateway."
}

output "vpc_s3_endpoint" {
  value = module.vpc_endpoint.vpce_id
  description = "The ID of the vpc s3 endpoint."
}
