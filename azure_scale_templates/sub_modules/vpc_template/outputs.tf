output "vpc_compute_cluster_private_subnets" {
  value       = module.compute_private_subnet.subnet_id
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_compute_nat_gateways" {
  value       = module.compute_nat_gateway.nat_gateway_id
  description = "List of IDs of compute cluster nat gateway."
}

output "vpc_public_subnets" {
  value       = module.public_subnet.subnet_id
  description = "List of IDs of public subnets."
}

output "vpc_ref" {
  value       = module.vnet.vnet_id
  description = "The ID of the vpc."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.storage_private_subnet.subnet_id
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_storage_nat_gateways" {
  value       = module.storage_nat_gateway.nat_gateway_id
  description = "List of IDs of storage cluster nat gateway."
}

output "vpc_network_security_group_ref" {
  value       = module.vnet_network_security_group.sec_group_id
  description = "VNet network security group id/reference."
}
