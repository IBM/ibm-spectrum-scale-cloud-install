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
  remote_cidr       = var.cidr_block
}

module "instances_sg_outbound_rule" {
  source            = "../../../resources/ibmcloud/security/security_allow_all"
  security_group_id = module.instances_security_group.sec_group_id[0]
  sg_direction      = "outbound"
  remote_ip_addr    = "0.0.0.0/0"
}

data ibm_is_ssh_key "instance_ssh_key" {
  name = var.instance_key_name
}

data ibm_is_image "compute_instance_image" {
  name = var.compute_instance_osimage_name
}

data ibm_is_image "storage_instance_image" {
  name = var.storage_instance_osimage_name
}

module "generate_keys" {
  source       = "../../../resources/common/generate_keys"
  tf_data_path = var.tf_data_path
}

module "compute_vsis" {
  source                    = "../../../resources/ibmcloud/compute/scale_vsi_0_vol"
  total_vsis                = var.total_compute_instances
  vsi_name_prefix           = format("%s-compute", var.stack_name)
  vpc_id                    = var.vpc_id
  zones                     = var.zones
  vsi_subnet_id             = var.private_subnet_ids
  vsi_security_group        = [module.instances_security_group.sec_group_id[0]]
  vsi_profile               = var.compute_vsi_profile
  vsi_image_id              = data.ibm_is_image.compute_instance_image.id
  vsi_public_key            = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_user_private_key_path = module.generate_keys.private_key_path
  vsi_user_public_key_path  = module.generate_keys.public_key_path
}

module "create_desc_disk" {
  source             = "../../../resources/ibmcloud/storage"
  total_volumes      = 1
  zone               = length(var.zones) >= 3 ? var.zones.2 : var.zones.0
  volume_name_prefix = format("%s-desc", var.stack_name)
  volume_profile     = var.volume_profile
  volume_iops        = var.volume_iops
  volume_capacity    = var.volume_capacity
}

module "desc_compute_vsi" {
  source                    = "../../../resources/ibmcloud/compute/scale_vsi_multiple_vol"
  total_vsis                = length(var.zones) >= 3 ? 1 : 0
  vsi_name_prefix           = format("%s-tiebreaker-desc", var.stack_name)
  vpc_id                    = var.vpc_id
  zone                      = var.zones.2
  vsi_subnet_id             = var.private_subnet_ids.2
  vsi_security_group        = [module.instances_security_group.sec_group_id[0]]
  vsi_profile               = var.compute_vsi_profile
  vsi_image_id              = data.ibm_is_image.compute_instance_image.id
  vsi_public_key            = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_user_private_key_path = module.generate_keys.private_key_path
  vsi_user_public_key_path  = module.generate_keys.public_key_path
  vsi_volumes               = module.create_desc_disk.volume_id
  vsi_data_volumes_count    = 1
}

locals {
  total_nsd_disks = var.data_disks_per_instance * var.total_storage_instances
}

module "create_data_disks_1A_zone" {
  source             = "../../../resources/ibmcloud/storage"
  total_volumes      = length(var.zones) == 1 ? local.total_nsd_disks : local.total_nsd_disks / 2
  zone               = var.zones.0
  volume_name_prefix = format("%s-1a", var.stack_name)
  volume_profile     = var.volume_profile
  volume_iops        = var.volume_iops
  volume_capacity    = var.volume_capacity
}

module "create_data_disks_2A_zone" {
  source             = "../../../resources/ibmcloud/storage"
  total_volumes      = length(var.zones) == 1 ? 0 : local.total_nsd_disks / 2
  zone               = var.zones.1
  volume_name_prefix = format("%s-2a", var.stack_name)
  volume_profile     = var.volume_profile
  volume_iops        = var.volume_iops
  volume_capacity    = var.volume_capacity
}

module "storage_vsis_1A_zone" {
  source                    = "../../../resources/ibmcloud/compute/scale_vsi_multiple_vol"
  total_vsis                = length(var.zones) > 1 ? var.total_storage_instances / 2 : var.total_storage_instances
  zone                      = var.zones.0
  vsi_name_prefix           = format("%s-storage-1a", var.stack_name)
  vpc_id                    = var.vpc_id
  vsi_subnet_id             = var.private_subnet_ids.0
  vsi_security_group        = [module.instances_security_group.sec_group_id[0]]
  vsi_profile               = var.storage_vsi_profile
  vsi_image_id              = data.ibm_is_image.storage_instance_image.id
  vsi_public_key            = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_user_private_key_path = module.generate_keys.private_key_path
  vsi_user_public_key_path  = module.generate_keys.public_key_path
  vsi_volumes               = module.create_data_disks_1A_zone.volume_id
  vsi_data_volumes_count    = var.data_disks_per_instance
}

module "storage_vsis_2A_zone" {
  source                    = "../../../resources/ibmcloud/compute/scale_vsi_multiple_vol"
  total_vsis                = length(var.zones) > 1 ? var.total_storage_instances / 2 : 0
  zone                      = var.zones.1
  vsi_name_prefix           = format("%s-storage-2a", var.stack_name)
  vpc_id                    = var.vpc_id
  vsi_subnet_id             = var.private_subnet_ids.1
  vsi_security_group        = [module.instances_security_group.sec_group_id[0]]
  vsi_profile               = var.storage_vsi_profile
  vsi_image_id              = data.ibm_is_image.storage_instance_image.id
  vsi_public_key            = [data.ibm_is_ssh_key.instance_ssh_key.id]
  vsi_user_private_key_path = module.generate_keys.private_key_path
  vsi_user_public_key_path  = module.generate_keys.public_key_path
  vsi_volumes               = module.create_data_disks_2A_zone.volume_id
  vsi_data_volumes_count    = var.data_disks_per_instance
}
