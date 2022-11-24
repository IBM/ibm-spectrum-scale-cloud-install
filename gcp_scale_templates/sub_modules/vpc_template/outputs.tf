output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "VPC name."
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC."
}

output "private_subnet_name" {
  value       = module.private_subnet.subnet_name
  description = "The name of Private subnet."
}

output "public_subnet_name" {
  value       = module.public_subnet.subnet_name
  description = "The name of Public subnet."
}

output "public_subnet_id" {
  value       = module.public_subnet.subnet_id
  description = "The ID of public subnet."
}

output "private_subnet_id" {
  value       = module.private_subnet.subnet_id
  description = "The ID of Private subnet."
}
