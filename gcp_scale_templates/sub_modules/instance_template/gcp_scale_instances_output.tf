output "compute_instance_ids" {
  value       = module.compute_instances.instance_ids_with_0_datadisks
  description = "GCP compute instance ids."
}

output "compute_instance_ips" {
  value       = module.compute_instances.instance_ips_with_0_datadisks
  description = "Private IP address of GCP compute instances."
}

output "compute_instance_desc_ip" {
  value       = module.desc_compute_instance.instance_ips_with_1_datadisks
  description = "Private IP address of GCP desc compute instance."
}

output "compute_instance_desc_id" {
  value       = module.desc_compute_instance.instance_ids_with_1_datadisks
  description = "GCP compute desc instance id."
}

output "storage_instance_1A_zone_ids" {
  value       = module.storage_instances_1A_zone.instance_ids
  description = "GCP storage instance ids."
}

output "storage_instance_2A_zone_ids" {
  value       = module.storage_instances_2A_zone.instance_ids
  description = "GCP storage instance ids."
}

output "storage_instance_1A_zone_ips" {
  value       = module.storage_instances_1A_zone.instance_ips
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_2A_zone_ips" {
  value       = module.storage_instances_2A_zone.instance_ips
  description = "Private IP address of GCP storage instances."
}

output "compute_instance_desc_map" {
  value       = local.compute_instance_desc_map
  description = "Dictionary of compute desc instance ip vs. descriptor data disk device path."
}

output "storage_instance_1A_ips_device_names_map" {
  value       = local.storage_instance_1A_ips_device_names_map
  description = "GCP storage instance ids vs. data disk device path."
}

output "storage_instance_2A_ips_device_names_map" {
  value       = local.storage_instance_2A_ips_device_names_map
  description = "GCP storage instance ids vs. data disk device path."
}

output "storage_instance_ids_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value       = local.storage_instance_ids_with_0_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_1_datadisks" {
  value       = local.storage_instance_ids_with_1_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_2_datadisks" {
  value       = local.storage_instance_ids_with_2_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_3_datadisks" {
  value       = local.storage_instance_ids_with_3_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_4_datadisks" {
  value       = local.storage_instance_ids_with_4_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_5_datadisks" {
  value       = local.storage_instance_ids_with_5_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_6_datadisks" {
  value       = local.storage_instance_ids_with_6_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_7_datadisks" {
  value       = local.storage_instance_ids_with_7_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_8_datadisks" {
  value       = local.storage_instance_ids_with_8_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_9_datadisks" {
  value       = local.storage_instance_ids_with_9_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_10_datadisks" {
  value       = local.storage_instance_ids_with_10_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_11_datadisks" {
  value       = local.storage_instance_ids_with_11_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_12_datadisks" {
  value       = local.storage_instance_ids_with_12_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_13_datadisks" {
  value       = local.storage_instance_ids_with_13_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_14_datadisks" {
  value       = local.storage_instance_ids_with_14_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ids_with_15_datadisks" {
  value       = local.storage_instance_ids_with_15_datadisks
  description = "GCP storage instance ids."
}

output "storage_instance_ips_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value       = local.storage_instance_ips_with_0_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_1_datadisks" {
  value       = local.storage_instance_ips_with_1_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_2_datadisks" {
  value       = local.storage_instance_ips_with_2_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_3_datadisks" {
  value       = local.storage_instance_ips_with_3_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_4_datadisks" {
  value       = local.storage_instance_ips_with_4_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_5_datadisks" {
  value       = local.storage_instance_ips_with_5_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_6_datadisks" {
  value       = local.storage_instance_ips_with_6_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_7_datadisks" {
  value       = local.storage_instance_ips_with_7_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_8_datadisks" {
  value       = local.storage_instance_ips_with_8_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_9_datadisks" {
  value       = local.storage_instance_ips_with_9_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_10_datadisks" {
  value       = local.storage_instance_ips_with_10_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_11_datadisks" {
  value       = local.storage_instance_ips_with_11_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_12_datadisks" {
  value       = local.storage_instance_ips_with_12_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_13_datadisks" {
  value       = local.storage_instance_ips_with_13_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_14_datadisks" {
  value       = local.storage_instance_ips_with_14_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_with_15_datadisks" {
  value       = local.storage_instance_ips_with_15_datadisks
  description = "Private IP address of GCP storage instances."
}

output "storage_instance_ips_0_datadisks_device_names_map" {
  value       = local.storage_instance_ips_0_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_1_datadisks_device_names_map" {
  value       = local.storage_instance_ips_1_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_2_datadisks_device_names_map" {
  value       = local.storage_instance_ips_2_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_3_datadisks_device_names_map" {
  value       = local.storage_instance_ips_3_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_4_datadisks_device_names_map" {
  value       = local.storage_instance_ips_4_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_5_datadisks_device_names_map" {
  value       = local.storage_instance_ips_5_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_6_datadisks_device_names_map" {
  value       = local.storage_instance_ips_6_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_7_datadisks_device_names_map" {
  value       = local.storage_instance_ips_7_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_8_datadisks_device_names_map" {
  value       = local.storage_instance_ips_8_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_9_datadisks_device_names_map" {
  value       = local.storage_instance_ips_9_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_10_datadisks_device_names_map" {
  value       = local.storage_instance_ips_10_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_11_datadisks_device_names_map" {
  value       = local.storage_instance_ips_11_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_12_datadisks_device_names_map" {
  value       = local.storage_instance_ips_12_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_13_datadisks_device_names_map" {
  value       = local.storage_instance_ips_13_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_14_datadisks_device_names_map" {
  value       = local.storage_instance_ips_14_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}

output "storage_instance_ips_15_datadisks_device_names_map" {
  value       = local.storage_instance_ips_15_datadisks_device_names_map
  description = "Dictionary of storage instance ip vs. data disk device path."
}
