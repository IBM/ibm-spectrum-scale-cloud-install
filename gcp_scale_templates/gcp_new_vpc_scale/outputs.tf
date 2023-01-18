
output "vpc_details" {
  value       = module.vpc_module
  description = "VPC details."
}

output "bastion_instances_details" {
  value       = module.bastion_module
  description = "Bastion instances details."
}

output "scale_instances_details" {
  value       = module.instance_modules
  description = "Scale instances details."
}
