/*
    This nested module creates;
    1. Instance security group/rule(s)
    2. {Compute, Storage} instance(s)
    3. Reserve floating ip
*/

module "instances_security_group" {
  source           = "../../../resources/ibmcloud/security/security_group"
  total_sec_groups = 1
  sec_group_name   = "${var.stack_name}-instances-sg"
  vpc_id           = var.vpc_id
}

module "instances_sg_cidr_rule" {
  source            = "../../../resources/ibmcloud/security/security_cidr_rule"
  security_group_id = module.instances_security_group.sec_group_id[0]
  sg_direction      = "inbound"
  remote_cidr       = length(var.secondary_private_subnet_ids) == 0 ? (length(var.zones) >= 3 ? var.primary_cidr_block : [var.primary_cidr_block[0]]) : (length(var.zones) >= 3 ? concat(var.primary_cidr_block, var.secondary_cidr_block) : concat([var.primary_cidr_block[0]], [var.secondary_cidr_block[0]]))
}

module "instances_sg_outbound_rule" {
  source            = "../../../resources/ibmcloud/security/security_allow_all"
  security_group_id = module.instances_security_group.sec_group_id[0]
  sg_direction      = "outbound"
  remote_ip_addr    = "0.0.0.0/0"
}

data "ibm_is_ssh_key" "instance_ssh_key" {
  name = var.instance_ssh_key
}

data "ibm_is_image" "compute_instance_image" {
  name = var.compute_vsi_osimage_name
}

data "ibm_is_image" "storage_instance_image" {
  name = var.storage_vsi_osimage_name
}

module "generate_keys" {
  source       = "../../../resources/common/generate_keys"
  tf_data_path = var.tf_data_path
}

module "compute_vsis" {
  source                  = "../../../resources/ibmcloud/compute/scale_vsi_0_vol"
  total_vsis              = var.total_compute_instances
  vsi_name_prefix         = format("%s-compute", var.stack_name)
  vpc_id                  = var.vpc_id
  zones                   = var.zones
  dns_service_id          = var.dns_service_id
  dns_zone_id             = var.dns_zone_id
  vsi_primary_subnet_id   = var.primary_private_subnet_ids
  vsi_secondary_subnet_id = length(var.secondary_private_subnet_ids) == 0 ? null : var.secondary_private_subnet_ids
  vsi_security_group      = [module.instances_security_group.sec_group_id[0]]
  vsi_profile             = var.compute_vsi_profile
  vsi_image_id            = data.ibm_is_image.compute_instance_image.id
  vsi_user_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_meta_private_key    = module.generate_keys.private_key
  vsi_meta_public_key     = module.generate_keys.public_key
}

module "create_desc_disk" {
  source             = "../../../resources/ibmcloud/storage"
  total_volumes      = var.block_volumes_per_instance == 0 ? 0 : length(var.zones) >= 3 ? 1 : 0
  zone               = length(var.zones) >= 3 ? var.zones.2 : var.zones.0
  volume_name_prefix = format("%s-desc", var.stack_name)
  volume_profile     = var.volume_profile
  volume_iops        = var.volume_iops
  volume_capacity    = var.volume_capacity
}

module "desc_compute_vsi" {
  source                  = "../../../resources/ibmcloud/compute/scale_vsi_multiple_vol"
  total_vsis              = length(var.zones) >= 3 ? 1 : 0
  vsi_name_prefix         = format("%s-tiebreaker-desc", var.stack_name)
  vpc_id                  = var.vpc_id
  zone                    = length(var.zones) >= 3 ? var.zones.2 : var.zones.0
  vsi_primary_subnet_id   = length(var.zones) >= 3 ? var.primary_private_subnet_ids.2 : var.primary_private_subnet_ids.0
  vsi_secondary_subnet_id = length(var.secondary_private_subnet_ids) == 0 ? false : (length(var.zones) >= 3 ? var.secondary_private_subnet_ids.2 : var.secondary_private_subnet_ids.0)
  dns_service_id          = var.dns_service_id
  dns_zone_id             = var.dns_zone_id
  vsi_security_group      = [module.instances_security_group.sec_group_id[0]]
  vsi_profile             = var.compute_vsi_profile
  vsi_image_id            = data.ibm_is_image.compute_instance_image.id
  vsi_user_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_meta_private_key    = module.generate_keys.private_key
  vsi_meta_public_key     = module.generate_keys.public_key
  vsi_data_volumes_count  = 1
  vsi_volumes             = module.create_desc_disk.volume_id
}

locals {
  total_nsd_disks = var.block_volumes_per_instance * var.total_storage_instances
  user_name = can(regex("redhat|centos", var.compute_vsi_osimage_name))? "vpcuser" : "ubuntu"
}

module "create_data_disks_1A_zone" {
  source             = "../../../resources/ibmcloud/storage"
  total_volumes      = var.block_volumes_per_instance == 0 ? 0 : length(var.zones) == 1 ? local.total_nsd_disks : local.total_nsd_disks / 2
  zone               = var.zones.0
  volume_name_prefix = format("%s-1a", var.stack_name)
  volume_profile     = var.volume_profile
  volume_iops        = var.volume_iops
  volume_capacity    = var.volume_capacity
}

module "create_data_disks_2A_zone" {
  source             = "../../../resources/ibmcloud/storage"
  total_volumes      = var.block_volumes_per_instance == 0 ? 0 : length(var.zones) == 1 ? 0 : local.total_nsd_disks / 2
  zone               = length(var.zones) == 1 ? var.zones.0 : var.zones.1
  volume_name_prefix = format("%s-2a", var.stack_name)
  volume_profile     = var.volume_profile
  volume_iops        = var.volume_iops
  volume_capacity    = var.volume_capacity
}

module "storage_vsis_1A_zone" {
  source                  = "../../../resources/ibmcloud/compute/scale_vsi_multiple_vol"
  total_vsis              = length(var.zones) > 1 ? var.total_storage_instances / 2 : var.total_storage_instances
  zone                    = var.zones.0
  vsi_name_prefix         = format("%s-storage-1a", var.stack_name)
  vpc_id                  = var.vpc_id
  dns_service_id          = var.dns_service_id
  dns_zone_id             = var.dns_zone_id
  vsi_primary_subnet_id   = var.primary_private_subnet_ids.0
  vsi_secondary_subnet_id = length(var.secondary_private_subnet_ids) == 0 ? false : var.secondary_private_subnet_ids.0
  vsi_security_group      = [module.instances_security_group.sec_group_id[0]]
  vsi_profile             = var.storage_vsi_profile
  vsi_image_id            = data.ibm_is_image.storage_instance_image.id
  vsi_user_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_meta_private_key    = module.generate_keys.private_key
  vsi_meta_public_key     = module.generate_keys.public_key
  vsi_volumes             = module.create_data_disks_1A_zone.volume_id
  vsi_data_volumes_count  = var.block_volumes_per_instance
}

module "storage_vsis_2A_zone" {
  source                  = "../../../resources/ibmcloud/compute/scale_vsi_multiple_vol"
  total_vsis              = length(var.zones) > 1 ? var.total_storage_instances / 2 : 0
  zone                    = length(var.zones) == 1 ? var.zones.0 : var.zones.1
  vsi_name_prefix         = format("%s-storage-2a", var.stack_name)
  vpc_id                  = var.vpc_id
  dns_service_id          = var.dns_service_id
  dns_zone_id             = var.dns_zone_id
  vsi_primary_subnet_id   = length(var.zones) >= 3 ? var.primary_private_subnet_ids.1 : var.primary_private_subnet_ids.0
  vsi_secondary_subnet_id = length(var.secondary_private_subnet_ids) == 0 ? false : (length(var.zones) > 1 ? var.secondary_private_subnet_ids.1 : var.secondary_private_subnet_ids.0)
  vsi_security_group      = [module.instances_security_group.sec_group_id[0]]
  vsi_profile             = var.storage_vsi_profile
  vsi_image_id            = data.ibm_is_image.storage_instance_image.id
  vsi_user_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_meta_private_key    = module.generate_keys.private_key
  vsi_meta_public_key     = module.generate_keys.public_key
  vsi_volumes             = module.create_data_disks_2A_zone.volume_id
  vsi_data_volumes_count  = var.block_volumes_per_instance
}

locals {
  compute_vsi_by_ip      = length(var.secondary_private_subnet_ids) == 0 ? module.compute_vsis.vsi_primary_ips : module.compute_vsis.vsi_secondary_ips
  desc_compute_vsi_by_ip = length(var.zones) == 1 ? (length(var.secondary_private_subnet_ids) == 0 ? module.desc_compute_vsi.vsi_primary_ips : module.desc_compute_vsi.vsi_secondary_ips) : []
  compute_vsi_desc_map = {
    for instance in local.desc_compute_vsi_by_ip :
    instance => module.create_desc_disk.volume_id
  }
  storage_vsis_1A_by_ip = length(var.secondary_private_subnet_ids) == 0 ? module.storage_vsis_1A_zone.vsi_primary_ips : module.storage_vsis_1A_zone.vsi_secondary_ips
  storage_vsis_2A_by_ip = length(var.secondary_private_subnet_ids) == 0 ? module.storage_vsis_2A_zone.vsi_primary_ips : module.storage_vsis_2A_zone.vsi_secondary_ips

  /* Block volumes per instance = 0, defaults to instance storage */
  storage_vsi_ips_with_0_datadisks  = var.block_volumes_per_instance == 0 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_1_datadisks  = var.block_volumes_per_instance == 1 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_2_datadisks  = var.block_volumes_per_instance == 2 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_3_datadisks  = var.block_volumes_per_instance == 3 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_4_datadisks  = var.block_volumes_per_instance == 4 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_5_datadisks  = var.block_volumes_per_instance == 5 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_6_datadisks  = var.block_volumes_per_instance == 6 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_7_datadisks  = var.block_volumes_per_instance == 7 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_8_datadisks  = var.block_volumes_per_instance == 8 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_9_datadisks  = var.block_volumes_per_instance == 9 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_10_datadisks = var.block_volumes_per_instance == 10 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_11_datadisks = var.block_volumes_per_instance == 11 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_12_datadisks = var.block_volumes_per_instance == 12 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_13_datadisks = var.block_volumes_per_instance == 13 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_14_datadisks = var.block_volumes_per_instance == 14 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null
  storage_vsi_ips_with_15_datadisks = var.block_volumes_per_instance == 15 ? (length(var.zones) == 1 ? local.storage_vsis_1A_by_ip : concat(local.storage_vsis_1A_by_ip, local.storage_vsis_2A_by_ip)) : null

  /* Block volumes per instance = 0, defaults to instance storage */
  storage_vsi_ids_with_0_datadisks  = var.block_volumes_per_instance == 0 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_1_datadisks  = var.block_volumes_per_instance == 1 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_2_datadisks  = var.block_volumes_per_instance == 2 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_3_datadisks  = var.block_volumes_per_instance == 3 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_4_datadisks  = var.block_volumes_per_instance == 4 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_5_datadisks  = var.block_volumes_per_instance == 5 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_6_datadisks  = var.block_volumes_per_instance == 6 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_7_datadisks  = var.block_volumes_per_instance == 7 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_8_datadisks  = var.block_volumes_per_instance == 8 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_9_datadisks  = var.block_volumes_per_instance == 9 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_10_datadisks = var.block_volumes_per_instance == 10 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_11_datadisks = var.block_volumes_per_instance == 11 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_12_datadisks = var.block_volumes_per_instance == 12 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_13_datadisks = var.block_volumes_per_instance == 13 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_14_datadisks = var.block_volumes_per_instance == 14 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null
  storage_vsi_ids_with_15_datadisks = var.block_volumes_per_instance == 15 ? (length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_ids : concat(module.storage_vsis_1A_zone.vsi_ids, module.storage_vsis_2A_zone.vsi_ids)) : null

  /* Block volumes per instance = 0, defaults to instance storage */
  storage_vsi_ips_0_datadisks_device_names_map = var.block_volumes_per_instance == 0 ? {
    for instance in local.storage_vsi_ips_with_0_datadisks :
    instance => length(var.zones) == 1 ? module.storage_vsis_1A_zone.vsi_instance_storage_volumes : concat(module.storage_vsis_1A_zone.vsi_instance_storage_volumes, module.storage_vsis_2A_zone.vsi_instance_storage_volumes)
  } : null
  storage_vsi_ips_1_datadisks_device_names_map = var.block_volumes_per_instance == 1 ? {
    for instance in local.storage_vsi_ips_with_1_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_2_datadisks_device_names_map = var.block_volumes_per_instance == 2 ? {
    for instance in local.storage_vsi_ips_with_2_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_3_datadisks_device_names_map = var.block_volumes_per_instance == 3 ? {
    for instance in local.storage_vsi_ips_with_3_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_4_datadisks_device_names_map = var.block_volumes_per_instance == 4 ? {
    for instance in local.storage_vsi_ips_with_4_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_5_datadisks_device_names_map = var.block_volumes_per_instance == 5 ? {
    for instance in local.storage_vsi_ips_with_5_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_6_datadisks_device_names_map = var.block_volumes_per_instance == 6 ? {
    for instance in local.storage_vsi_ips_with_6_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_7_datadisks_device_names_map = var.block_volumes_per_instance == 7 ? {
    for instance in local.storage_vsi_ips_with_7_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_8_datadisks_device_names_map = var.block_volumes_per_instance == 8 ? {
    for instance in local.storage_vsi_ips_with_8_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_9_datadisks_device_names_map = var.block_volumes_per_instance == 9 ? {
    for instance in local.storage_vsi_ips_with_9_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_10_datadisks_device_names_map = var.block_volumes_per_instance == 10 ? {
    for instance in local.storage_vsi_ips_with_10_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_11_datadisks_device_names_map = var.block_volumes_per_instance == 11 ? {
    for instance in local.storage_vsi_ips_with_11_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_12_datadisks_device_names_map = var.block_volumes_per_instance == 12 ? {
    for instance in local.storage_vsi_ips_with_12_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_13_datadisks_device_names_map = var.block_volumes_per_instance == 13 ? {
    for instance in local.storage_vsi_ips_with_13_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_14_datadisks_device_names_map = var.block_volumes_per_instance == 14 ? {
    for instance in local.storage_vsi_ips_with_14_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
  storage_vsi_ips_15_datadisks_device_names_map = var.block_volumes_per_instance == 15 ? {
    for instance in local.storage_vsi_ips_with_15_datadisks :
    instance => length(var.zones) == 1 ? module.create_data_disks_1A_zone.volume_id : concat(module.create_data_disks_1A_zone.volume_id, module.create_data_disks_2A_zone)
  } : null
}


module "invoke_scale_playbook" {
  source     = "../../../resources/common/ansible_scale_playbook"
  region     = var.region
  stack_name = var.stack_name

  tf_data_path            = var.tf_data_path
  tf_input_json_root_path = var.tf_input_json_root_path == null ? abspath(path.cwd) : var.tf_input_json_root_path
  tf_input_json_file_name = var.tf_input_json_file_name == null ? join(", ", fileset(abspath(path.cwd), "*.tfvars*")) : var.tf_input_json_file_name

  bucket_name               = var.bucket_name
  scale_version             = var.scale_version
  bastion_public_ip         = var.bastion_public_ip
  instances_ssh_private_key = var.instances_ssh_private_key

  instances_ssh_user_name =  local.user_name
  private_subnet_cidr     = length(var.secondary_private_subnet_ids) == 0 ? var.primary_cidr_block[0] : var.secondary_cidr_block[0]

  scale_infra_repo_clone_path = var.scale_infra_repo_clone_path
  filesystem_mountpoint       = var.filesystem_mountpoint
  filesystem_block_size       = var.filesystem_block_size

  create_scale_cluster         = var.create_scale_cluster
  generate_ansible_inv         = var.generate_ansible_inv
  generate_jumphost_ssh_config = var.generate_jumphost_ssh_config

  cloud_platform   = "IBMCloud"
  avail_zones      = jsonencode(var.zones)
  notification_arn = "None"

  compute_instances_by_id   = module.compute_vsis.vsi_ids == null ? "[]" : jsonencode(module.compute_vsis.vsi_ids)
  compute_instances_by_ip   = local.compute_vsi_by_ip == null ? "[]" : jsonencode(local.compute_vsi_by_ip)
  compute_instance_desc_map = jsonencode(local.compute_vsi_desc_map)
  compute_instance_desc_id  = jsonencode(module.desc_compute_vsi.vsi_ids)

  storage_instance_ids_with_0_datadisks  = local.storage_vsi_ids_with_0_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_0_datadisks)
  storage_instance_ids_with_1_datadisks  = local.storage_vsi_ids_with_1_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_1_datadisks)
  storage_instance_ids_with_2_datadisks  = local.storage_vsi_ids_with_2_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_2_datadisks)
  storage_instance_ids_with_3_datadisks  = local.storage_vsi_ids_with_3_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_3_datadisks)
  storage_instance_ids_with_4_datadisks  = local.storage_vsi_ids_with_4_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_4_datadisks)
  storage_instance_ids_with_5_datadisks  = local.storage_vsi_ids_with_5_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_5_datadisks)
  storage_instance_ids_with_6_datadisks  = local.storage_vsi_ids_with_6_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_6_datadisks)
  storage_instance_ids_with_7_datadisks  = local.storage_vsi_ids_with_7_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_7_datadisks)
  storage_instance_ids_with_8_datadisks  = local.storage_vsi_ids_with_8_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_8_datadisks)
  storage_instance_ids_with_9_datadisks  = local.storage_vsi_ids_with_9_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_9_datadisks)
  storage_instance_ids_with_10_datadisks = local.storage_vsi_ids_with_10_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_10_datadisks)
  storage_instance_ids_with_11_datadisks = local.storage_vsi_ids_with_11_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_11_datadisks)
  storage_instance_ids_with_12_datadisks = local.storage_vsi_ids_with_12_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_12_datadisks)
  storage_instance_ids_with_13_datadisks = local.storage_vsi_ids_with_13_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_13_datadisks)
  storage_instance_ids_with_14_datadisks = local.storage_vsi_ids_with_14_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_14_datadisks)
  storage_instance_ids_with_15_datadisks = local.storage_vsi_ids_with_15_datadisks == null ? "[]" : jsonencode(local.storage_vsi_ids_with_15_datadisks)

  storage_instance_ips_with_0_datadisks_device_names_map  = local.storage_vsi_ips_0_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_0_datadisks_device_names_map)
  storage_instance_ips_with_1_datadisks_device_names_map  = local.storage_vsi_ips_1_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_1_datadisks_device_names_map)
  storage_instance_ips_with_2_datadisks_device_names_map  = local.storage_vsi_ips_2_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_2_datadisks_device_names_map)
  storage_instance_ips_with_3_datadisks_device_names_map  = local.storage_vsi_ips_3_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_3_datadisks_device_names_map)
  storage_instance_ips_with_4_datadisks_device_names_map  = local.storage_vsi_ips_4_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_4_datadisks_device_names_map)
  storage_instance_ips_with_5_datadisks_device_names_map  = local.storage_vsi_ips_5_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_5_datadisks_device_names_map)
  storage_instance_ips_with_6_datadisks_device_names_map  = local.storage_vsi_ips_6_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_6_datadisks_device_names_map)
  storage_instance_ips_with_7_datadisks_device_names_map  = local.storage_vsi_ips_7_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_7_datadisks_device_names_map)
  storage_instance_ips_with_8_datadisks_device_names_map  = local.storage_vsi_ips_8_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_8_datadisks_device_names_map)
  storage_instance_ips_with_9_datadisks_device_names_map  = local.storage_vsi_ips_9_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_9_datadisks_device_names_map)
  storage_instance_ips_with_10_datadisks_device_names_map = local.storage_vsi_ips_10_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_10_datadisks_device_names_map)
  storage_instance_ips_with_11_datadisks_device_names_map = local.storage_vsi_ips_11_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_11_datadisks_device_names_map)
  storage_instance_ips_with_12_datadisks_device_names_map = local.storage_vsi_ips_12_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_12_datadisks_device_names_map)
  storage_instance_ips_with_13_datadisks_device_names_map = local.storage_vsi_ips_13_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_13_datadisks_device_names_map)
  storage_instance_ips_with_14_datadisks_device_names_map = local.storage_vsi_ips_14_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_14_datadisks_device_names_map)
  storage_instance_ips_with_15_datadisks_device_names_map = local.storage_vsi_ips_15_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_vsi_ips_15_datadisks_device_names_map)
}
