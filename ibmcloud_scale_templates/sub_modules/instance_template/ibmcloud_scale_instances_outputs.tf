output "stack_name" {
  value = var.stack_name
}

output "vpc_id" {
  value = var.vpc_id
}

output "volume_1A_ids" {
  value = module.create_data_disks_1A_zone.volume_id
}

output "volume_2A_ids" {
  value = module.create_data_disks_2A_zone.volume_id
}
