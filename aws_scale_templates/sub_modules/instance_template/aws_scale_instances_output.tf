output "compute_instance_ids" {
  value = module.compute_instances.instance_ids_with_0_datadisks
}

output "compute_instance_ips" {
  value = module.compute_instances.instance_ips_with_0_datadisks
}

output "compute_instance_ip_by_id" {
  value = module.compute_instances.instance_ip_by_id_with_0_datadisks
}

output "compute_instance_desc_map" {
  value = {
    for instance in module.desc_compute_instance.instance_ips_with_1_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 1)
  }
}

output "storage_instance_ids_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = module.storage_instances.instance_ids_with_0_datadisks
}

output "storage_instance_ids_with_1_datadisks" {
  value = module.storage_instances.instance_ids_with_1_datadisks
}

output "storage_instance_ids_with_2_datadisks" {
  value = module.storage_instances.instance_ids_with_2_datadisks
}

output "storage_instance_ids_with_3_datadisks" {
  value = module.storage_instances.instance_ids_with_3_datadisks
}

output "storage_instance_ids_with_4_datadisks" {
  value = module.storage_instances.instance_ids_with_4_datadisks
}

output "storage_instance_ids_with_5_datadisks" {
  value = module.storage_instances.instance_ids_with_5_datadisks
}

output "storage_instance_ids_with_6_datadisks" {
  value = module.storage_instances.instance_ids_with_6_datadisks
}

output "storage_instance_ids_with_7_datadisks" {
  value = module.storage_instances.instance_ids_with_7_datadisks
}

output "storage_instance_ids_with_8_datadisks" {
  value = module.storage_instances.instance_ids_with_8_datadisks
}

output "storage_instance_ids_with_9_datadisks" {
  value = module.storage_instances.instance_ids_with_9_datadisks
}

output "storage_instance_ids_with_10_datadisks" {
  value = module.storage_instances.instance_ids_with_10_datadisks
}

output "storage_instance_ids_with_11_datadisks" {
  value = module.storage_instances.instance_ids_with_11_datadisks
}

output "storage_instance_ids_with_12_datadisks" {
  value = module.storage_instances.instance_ids_with_12_datadisks
}

output "storage_instance_ids_with_13_datadisks" {
  value = module.storage_instances.instance_ids_with_13_datadisks
}

output "storage_instance_ids_with_14_datadisks" {
  value = module.storage_instances.instance_ids_with_14_datadisks
}

output "storage_instance_ids_with_15_datadisks" {
  value = module.storage_instances.instance_ids_with_15_datadisks
}

output "storage_instance_ips_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = module.storage_instances.instance_ips_with_0_datadisks
}

output "storage_instance_ips_with_1_datadisks" {
  value = module.storage_instances.instance_ips_with_1_datadisks
}

output "storage_instance_ips_with_2_datadisks" {
  value = module.storage_instances.instance_ips_with_2_datadisks
}

output "storage_instance_ips_with_3_datadisks" {
  value = module.storage_instances.instance_ips_with_3_datadisks
}

output "storage_instance_ips_with_4_datadisks" {
  value = module.storage_instances.instance_ips_with_4_datadisks
}

output "storage_instance_ips_with_5_datadisks" {
  value = module.storage_instances.instance_ips_with_5_datadisks
}

output "storage_instance_ips_with_6_datadisks" {
  value = module.storage_instances.instance_ips_with_6_datadisks
}

output "storage_instance_ips_with_7_datadisks" {
  value = module.storage_instances.instance_ips_with_7_datadisks
}

output "storage_instance_ips_with_8_datadisks" {
  value = module.storage_instances.instance_ips_with_8_datadisks
}

output "storage_instance_ips_with_9_datadisks" {
  value = module.storage_instances.instance_ips_with_9_datadisks
}

output "storage_instance_ips_with_10_datadisks" {
  value = module.storage_instances.instance_ips_with_10_datadisks
}

output "storage_instance_ips_with_11_datadisks" {
  value = module.storage_instances.instance_ips_with_11_datadisks
}

output "storage_instance_ips_with_12_datadisks" {
  value = module.storage_instances.instance_ips_with_12_datadisks
}

output "storage_instance_ips_with_13_datadisks" {
  value = module.storage_instances.instance_ips_with_13_datadisks
}

output "storage_instance_ips_with_14_datadisks" {
  value = module.storage_instances.instance_ips_with_14_datadisks
}

output "storage_instance_ips_with_15_datadisks" {
  value = module.storage_instances.instance_ips_with_15_datadisks
}

output "storage_instance_ip_by_id_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = module.storage_instances.instance_ip_by_id_with_0_datadisks
}

output "storage_instance_ip_by_id_with_1_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_1_datadisks
}

output "storage_instances_ip_by_id_with_2_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_2_datadisks
}

output "storage_instance_ip_by_id_with_3_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_3_datadisks
}

output "storage_instance_ip_by_id_with_4_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_4_datadisks
}

output "storage_instance_ip_by_id_with_5_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_5_datadisks
}

output "storage_instance_ip_by_id_with_6_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_6_datadisks
}

output "storage_instance_ip_by_id_with_7_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_7_datadisks
}

output "storage_instance_ip_by_id_with_8_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_8_datadisks
}

output "storage_instance_ip_by_id_with_9_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_9_datadisks
}

output "storage_instance_ip_by_id_with_10_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_10_datadisks
}

output "storage_instance_ip_by_id_with_11_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_11_datadisks
}

output "storage_instance_ip_by_id_with_12_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_12_datadisks
}

output "storage_instance_ip_by_id_with_13_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_13_datadisks
}

output "storage_instance_ip_by_id_with_14_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_14_datadisks
}

output "storage_instance_ip_by_id_with_15_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_15_datadisks
}

output "instance_ips_with_0_datadisks_ebs_device_names" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = tonumber(var.ebs_volumes_per_instance) == 0 ? {
    for instance in module.storage_instances.instance_ips_with_0_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 0)
  } : null
}

output "instance_ips_with_1_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 1 ? {
    for instance in module.storage_instances.instance_ips_with_1_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 1)
  } : null
}

output "instance_ips_with_2_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 2 ? {
    for instance in module.storage_instances.instance_ips_with_2_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 2)
  } : null
}

output "instance_ips_with_3_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 3 ? {
    for instance in module.storage_instances.instance_ips_with_3_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 3)
  } : null
}

output "instance_ips_with_4_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 4 ? {
    for instance in module.storage_instances.instance_ips_with_4_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 4)
  } : null
}

output "instance_ips_with_5_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 5 ? {
    for instance in module.storage_instances.instance_ips_with_5_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 5)
  } : null
}

output "instance_ips_with_6_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 6 ? {
    for instance in module.storage_instances.instance_ips_with_6_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 6)
  } : null
}

output "instance_ips_with_7_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 7 ? {
    for instance in module.storage_instances.instance_ips_with_7_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 7)
  } : null
}
output "instance_ips_with_8_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 8 ? {
    for instance in module.storage_instances.instance_ips_with_8_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 8)
  } : null
}


output "instance_ips_with_9_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 9 ? {
    for instance in module.storage_instances.instance_ips_with_9_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 9)
  } : null
}

output "instance_ips_with_10_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 10 ? {
    for instance in module.storage_instances.instance_ips_with_10_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 10)
  } : null
}

output "instance_ips_with_11_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 11 ? {
    for instance in module.storage_instances.instance_ips_with_11_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 11)
  } : null
}

output "instance_ips_with_12_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 12 ? {
    for instance in module.storage_instances.instance_ips_with_12_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 12)
  } : null
}

output "instance_ips_with_13_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 13 ? {
    for instance in module.storage_instances.instance_ips_with_13_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 13)
  } : null
}

output "instance_ips_with_14_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 14 ? {
    for instance in module.storage_instances.instance_ips_with_14_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 14)
  } : null
}

output "instance_ips_with_15_datadisks_ebs_device_names" {
  value = tonumber(var.ebs_volumes_per_instance) == 15 ? {
    for instance in module.storage_instances.instance_ips_with_15_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 15)
  } : null
}
