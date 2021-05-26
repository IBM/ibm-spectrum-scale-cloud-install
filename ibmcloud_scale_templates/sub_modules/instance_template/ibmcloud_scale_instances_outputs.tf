output "stack_name" {
  value = var.stack_name
}

output "vpc_id" {
  value = var.vpc_id
}

output "compute_vsi_primary_ips" {
  value = module.compute_vsis.vsi_primary_ips
}

output "compute_vsi_secondary_ips" {
  value = module.compute_vsis.vsi_secondary_ips
}

output "desc_compute_vsi_primary_ip" {
  value = module.desc_compute_vsi.vsi_primary_ips
}

output "desc_compute_vsi_secondary_ip" {
  value = module.desc_compute_vsi.vsi_secondary_ips
}

output "desc_compute_vsi_volume_id" {
  value = module.create_desc_disk.volume_id
}

output "storage_vsi_1A_primary_ips" {
  value = module.storage_vsis_1A_zone.vsi_primary_ips
}

output "storage_vsi_2A_primary_ips" {
  value = module.storage_vsis_2A_zone.vsi_primary_ips
}

output "storage_vsi_1A_secondary_ips" {
  value = module.storage_vsis_1A_zone.vsi_secondary_ips
}

output "storage_vsi_2A_secondary_ips" {
  value = module.storage_vsis_2A_zone.vsi_secondary_ips
}

output "volume_1A_ids" {
  value = var.block_volumes_per_instance == 0 && length(var.vpc_zones) == 1 ? module.storage_vsis_1A_zone.vsi_instance_storage_volumes : module.create_data_disks_1A_zone.volume_id
}

output "volume_2A_ids" {
  value = var.block_volumes_per_instance == 0 && length(var.vpc_zones) >= 3 ? module.storage_vsis_2A_zone.vsi_instance_storage_volumes : module.create_data_disks_2A_zone.volume_id
}
