output "stack_name" {
  value = var.stack_name
}

output "vpc_id" {
  value = var.vpc_id
}

output "compute_vsi_ips" {
  value = module.compute_vsis.vsi_ips
}

output "desc_compute_vsi_ip" {
  value = module.desc_compute_vsi.vsi_ips
}

output "storage_vsi_1A_ips" {
  value = module.storage_vsis_1A_zone.vsi_ips
}

output "storage_vsi_2A_ips" {
  value = module.storage_vsis_2A_zone.vsi_ips
}

output "volume_1A_ids" {
  value = module.create_data_disks_1A_zone.volume_id
}

output "volume_2A_ids" {
  value = module.create_data_disks_2A_zone.volume_id
}
