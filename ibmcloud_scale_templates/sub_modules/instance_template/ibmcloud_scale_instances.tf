/*
    This nested module creates;
    1. Bastion security group/rule(s)
    2. Bastion instance
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

module "compute_vsis" {
  source             = "../../../resources/ibmcloud/compute"
  total_vsis         = var.total_compute_instances
  vsi_name_prefix    = format("%s-compute", var.stack_name)
  vpc_id             = var.vpc_id
  zones              = var.zones
  vsi_subnet_id      = var.private_subnet_ids
  vsi_security_group = [module.instances_security_group.sec_group_id[0]]
  vsi_profile        = var.compute_vsi_profile
  vsi_image_id       = data.ibm_is_image.compute_instance_image.id
  vsi_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
}

module "desc_compute_vsi" {
  source             = "../../../resources/ibmcloud/compute"
  total_vsis         = length(var.zones) > 1 ? 1 : 0
  vsi_name_prefix    = format("%s-tiebreaker-desc", var.stack_name)
  vpc_id             = var.vpc_id
  zones              = length(var.zones) >= 3 ? [var.zones[2]] : var.zones
  vsi_subnet_id      = length(var.zones) >= 3 ? [var.private_subnet_ids[2]] : var.private_subnet_ids
  vsi_security_group = [module.instances_security_group.sec_group_id[0]]
  vsi_profile        = var.compute_vsi_profile
  vsi_image_id       = data.ibm_is_image.compute_instance_image.id
  vsi_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
}

module "storage_vsis" {
  source             = "../../../resources/ibmcloud/compute"
  total_vsis         = var.total_storage_instances
  vsi_name_prefix    = format("%s-storage", var.stack_name)
  vpc_id             = var.vpc_id
  zones              = var.zones
  vsi_subnet_id      = var.private_subnet_ids
  vsi_security_group = [module.instances_security_group.sec_group_id[0]]
  vsi_profile        = var.storage_vsi_profile
  vsi_image_id       = data.ibm_is_image.storage_instance_image.id
  vsi_public_key     = [data.ibm_is_ssh_key.instance_ssh_key.id]
}
