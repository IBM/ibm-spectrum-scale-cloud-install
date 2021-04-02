output "stack_name" {
  value = var.stack_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "primary_private_subnets" {
  value = module.primary_private_subnet.subnet_id
}

output "secondary_private_subnets" {
  value = module.secondary_private_subnet[0].subnet_id
}

output "dns_service_id" {
  value = module.dns_service.resource_guid
}

output "dns_zone_id" {
  value = module.dns_zone.dns_zone_id
}
