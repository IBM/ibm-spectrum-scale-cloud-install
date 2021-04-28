/*
    This nested module creates;
    1. Bastion security group/rule(s)
    2. Bastion instance
    3. Reserve floating ip
*/

module "bastion_security_group" {
  source           = "../../../resources/ibmcloud/security/security_group"
  total_sec_groups = 1
  sec_group_name   = ["${var.stack_name}-bastion-sg"]
  vpc_id           = var.vpc_id
  resource_grp_id  = var.resource_grp_id
}

module "bastion_sg_tcp_rule" {
  source            = "../../../resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.bastion_security_group.sec_group_id[0]
  sg_direction      = "inbound"
  remote_ip_addr    = var.bastion_incoming_remote
}

module "bastion_sg_icmp_rule" {
  source            = "../../../resources/ibmcloud/security/security_icmp_rule"
  security_group_id = module.bastion_security_group.sec_group_id[0]
  sg_direction      = "inbound"
  remote_ip_addr    = var.bastion_incoming_remote
}

module "bastion_sg_outbound_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  security_group_ids = module.bastion_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

data "ibm_is_ssh_key" "bastion_ssh_key" {
  name = var.bastion_ssh_key
}

data "ibm_is_image" "bastion_image" {
  name = var.bastion_osimage_name
}

module "bastion_vsi" {
  source              = "../../../resources/ibmcloud/compute/bastion_vsi"
  total_vsis          = 1
  vsi_name_prefix     = format("%s-bastion", var.stack_name)
  vpc_id              = var.vpc_id
  zones               = var.zones
  resource_grp_id     = var.resource_grp_id
  vsi_subnet_id       = var.bastion_subnet_id
  vsi_security_group  = [module.bastion_security_group.sec_group_id[0]]
  vsi_profile         = var.bastion_vsi_profile
  vsi_image_id        = data.ibm_is_image.bastion_image.id
  vsi_user_public_key = [data.ibm_is_ssh_key.bastion_ssh_key.id]
}

module "bastion_attach_fip" {
  source           = "../../../resources/ibmcloud/network/floating_ip"
  floating_ip_name = "bastion-fip"
  vsi_nw_id        = module.bastion_vsi.vsi_nw_ids[0].id
  resource_grp_id  = var.resource_grp_id
}
