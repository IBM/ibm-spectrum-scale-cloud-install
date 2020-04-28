output "compute_instance_ids" {
  value = module.compute_instances.instance_ids_with_0_datadisks
  description = "AWS compute instance ids."
}

output "compute_instance_ips" {
  value = module.compute_instances.instance_ips_with_0_datadisks
  description = "Private IP address of AWS compute instances."
}

output "compute_instance_ip_by_id" {
  value = module.compute_instances.instance_ip_by_id_with_0_datadisks
  description = "Dictionary of compute instance ip vs. id."
}

output "compute_instance_desc_map" {
  value = local.compute_instance_desc_map
  description = "Dictionary of compute instance ip vs. descriptor EBS device path."
}

output "compute_instance_desc_by_id" {
  value = module.desc_compute_instance.instance_ids_with_1_datadisks
  description = "AWS compute desc instance id." 
}

output "storage_instance_ids_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = module.storage_instances.instance_ids_with_0_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_1_datadisks" {
  value = module.storage_instances.instance_ids_with_1_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_2_datadisks" {
  value = module.storage_instances.instance_ids_with_2_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_3_datadisks" {
  value = module.storage_instances.instance_ids_with_3_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_4_datadisks" {
  value = module.storage_instances.instance_ids_with_4_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_5_datadisks" {
  value = module.storage_instances.instance_ids_with_5_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_6_datadisks" {
  value = module.storage_instances.instance_ids_with_6_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_7_datadisks" {
  value = module.storage_instances.instance_ids_with_7_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_8_datadisks" {
  value = module.storage_instances.instance_ids_with_8_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_9_datadisks" {
  value = module.storage_instances.instance_ids_with_9_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_10_datadisks" {
  value = module.storage_instances.instance_ids_with_10_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_11_datadisks" {
  value = module.storage_instances.instance_ids_with_11_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_12_datadisks" {
  value = module.storage_instances.instance_ids_with_12_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_13_datadisks" {
  value = module.storage_instances.instance_ids_with_13_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_14_datadisks" {
  value = module.storage_instances.instance_ids_with_14_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ids_with_15_datadisks" {
  value = module.storage_instances.instance_ids_with_15_datadisks
  description = "AWS storage instance ids."
}

output "storage_instance_ips_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = module.storage_instances.instance_ips_with_0_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_1_datadisks" {
  value = module.storage_instances.instance_ips_with_1_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_2_datadisks" {
  value = module.storage_instances.instance_ips_with_2_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_3_datadisks" {
  value = module.storage_instances.instance_ips_with_3_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_4_datadisks" {
  value = module.storage_instances.instance_ips_with_4_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_5_datadisks" {
  value = module.storage_instances.instance_ips_with_5_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_6_datadisks" {
  value = module.storage_instances.instance_ips_with_6_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_7_datadisks" {
  value = module.storage_instances.instance_ips_with_7_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_8_datadisks" {
  value = module.storage_instances.instance_ips_with_8_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_9_datadisks" {
  value = module.storage_instances.instance_ips_with_9_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_10_datadisks" {
  value = module.storage_instances.instance_ips_with_10_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_11_datadisks" {
  value = module.storage_instances.instance_ips_with_11_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_12_datadisks" {
  value = module.storage_instances.instance_ips_with_12_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_13_datadisks" {
  value = module.storage_instances.instance_ips_with_13_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_14_datadisks" {
  value = module.storage_instances.instance_ips_with_14_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ips_with_15_datadisks" {
  value = module.storage_instances.instance_ips_with_15_datadisks
  description = "Private IP address of AWS storage instances."
}

output "storage_instance_ip_by_id_with_0_datadisks" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = module.storage_instances.instance_ip_by_id_with_0_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_1_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_1_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_2_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_2_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_3_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_3_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_4_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_4_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_5_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_5_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_6_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_6_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_7_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_7_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_8_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_8_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_9_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_9_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_10_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_10_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_11_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_11_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_12_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_12_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_13_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_13_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_14_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_14_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "storage_instance_ip_by_id_with_15_datadisks" {
  value = module.storage_instances.instance_ip_by_id_with_15_datadisks
  description = "Dictionary of storage instance ip vs. id."
}

output "instance_ips_with_0_datadisks_ebs_device_names" {
  # This output has no significance.
  # Keeping it support ephemeral disks.
  value = local.instance_ips_with_0_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_1_datadisks_ebs_device_names" {
  value = local.instance_ips_with_1_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_2_datadisks_ebs_device_names" {
  value = local.instance_ips_with_2_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_3_datadisks_ebs_device_names" {
  value = local.instance_ips_with_3_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_4_datadisks_ebs_device_names" {
  value = local.instance_ips_with_4_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_5_datadisks_ebs_device_names" {
  value = local.instance_ips_with_5_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_6_datadisks_ebs_device_names" {
  value = local.instance_ips_with_6_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_7_datadisks_ebs_device_names" {
  value = local.instance_ips_with_7_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_8_datadisks_ebs_device_names" {
  value = local.instance_ips_with_8_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_9_datadisks_ebs_device_names" {
  value = local.instance_ips_with_9_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_10_datadisks_ebs_device_names" {
  value = local.instance_ips_with_10_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_11_datadisks_ebs_device_names" {
  value = local.instance_ips_with_11_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_12_datadisks_ebs_device_names" {
  value = local.instance_ips_with_12_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_13_datadisks_ebs_device_names" {
  value = local.instance_ips_with_13_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_14_datadisks_ebs_device_names" {
  value = local.instance_ips_with_14_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}

output "instance_ips_with_15_datadisks_ebs_device_names" {
  value = local.instance_ips_with_15_datadisks_ebs_device_names
  description = "Dictionary of instance ip vs. EBS device path."
}
