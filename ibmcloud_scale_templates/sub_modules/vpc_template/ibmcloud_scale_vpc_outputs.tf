output "stack_name" {
  value = var.stack_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "compute_private_subnets" {
  value = var.create_seperate_subnets == true ? module.compute_private_subnet[0].subnet_id : []
}

output "storage_private_subnets" {
  value = module.storage_private_subnet.subnet_id
}

output "dns_service_ids" {
  value = module.dns_service.resource_guid
}

output "dns_zone_ids" {
  value = module.dns_zone.dns_zone_id
}
