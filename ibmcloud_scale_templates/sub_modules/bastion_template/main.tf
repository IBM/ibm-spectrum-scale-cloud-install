/*
    Bastion Template Module for IBM Storage Scale Cloud Deployment

    This module creates a bastion host (jump server) infrastructure with:

    1. Bastion security group with configurable rules
    2. Security rules for SSH, ICMP, and outbound traffic
    3. Bastion instance template for auto-scaling
    4. Auto-scaling group for bastion instances
*/

module "bastion_security_group" {
  count             = local.create_count
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = local.bastion_sg_name
  vpc_id            = var.vpc_ref
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

module "bastion_sg_inbound_rule" {
  count             = local.create_count
  source            = "../../../resources/ibmcloud/security/security_rule"
  enable_rule       = true
  security_group_id = module.bastion_security_group[0].sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks
  rules = [
    {
      protocol = "tcp"
      port_min = var.bastion_public_ssh_port
      port_max = var.bastion_public_ssh_port
    },
    {
      protocol = "icmp"
    }
  ]
}

module "bastion_sg_outbound_rule" {
  count              = local.create_count
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  enable_rule        = true
  security_group_ids = module.bastion_security_group[0].sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = var.remote_cidr_blocks
}

# Create ssh key to access the bastion instance
resource "ibm_is_ssh_key" "bastion_ssh_key" {
  count          = local.create_count
  name           = "${var.resource_prefix}-bastion-ssh-key"
  public_key     = trimspace(var.bastion_public_key)
  resource_group = var.resource_group_id
}

module "bastion_autoscaling_launch_template" {
  count                = local.create_count
  source               = "../../../resources/ibmcloud/asg/instance_template"
  launch_template_name = local.bastion_launch_tmpl_name
  resource_group_id    = var.resource_group_id
  instance_type        = var.bastion_instance_type
  image_id             = var.bastion_image_ref
  vpc                  = var.vpc_ref
  zone                 = local.selected_zone
  subnet               = local.selected_subnet
  security_groups      = [module.bastion_security_group[0].sec_group_id]
  key_name             = [ibm_is_ssh_key.bastion_ssh_key[0].id]
}

module "bastion_autoscaling_group" {
  count                  = local.create_count
  source                 = "../../../resources/ibmcloud/asg/instance_group"
  asg_name               = local.bastion_asg_name
  launch_template_id     = module.bastion_autoscaling_launch_template[0].instance_template_id
  desired_instance_count = var.desired_instance_count
  subnets                = var.vpc_auto_scaling_group_subnets
  resource_group_id      = var.resource_group_id
}
