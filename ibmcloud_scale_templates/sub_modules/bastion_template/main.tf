/*
    This nested module creates;
    1. Bastion security group/rule(s)
    2. Bastion instance group
    3. Reserve floating ip
*/

data "ibm_resource_group" "itself" {
  name = var.resource_group_name
}

module "bastion_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = format("%s-bastion-sg", var.resource_prefix)
  vpc_id            = var.vpc_ref
  resource_group_id = data.ibm_resource_group.itself.id
}

module "bastion_sg_tcp_rule" {
  source            = "../../../resources/ibmcloud/security/security_tcp_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  port              = var.bastion_public_ssh_port
  remote_ip_addr    = var.remote_cidr_blocks
}

module "bastion_sg_icmp_rule" {
  source            = "../../../resources/ibmcloud/security/security_icmp_rule"
  security_group_id = module.bastion_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.remote_cidr_blocks
}

module "bastion_sg_outbound_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  security_group_ids = module.bastion_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = var.remote_cidr_blocks
}

data "ibm_is_ssh_key" "itself" {
  name = var.bastion_key_pair
}

module "bastion_autoscaling_launch_template" {
  source               = "../../../resources/ibmcloud/asg/instance_template"
  launch_template_name = format("%s-%s", var.resource_prefix, "bastion-launch-tmpl")
  resource_group_id    = data.ibm_resource_group.itself.id
  instance_type        = var.bastion_instance_type
  image_id             = var.bastion_image_ref
  vpc                  = var.vpc_ref
  zone                 = var.vpc_availability_zones[0]         # Pick first zone to store the instance template
  subnet               = var.vpc_auto_scaling_group_subnets[0] # Pick first zone to store the instance template
  security_groups      = [module.bastion_security_group.sec_group_id]
  key_name             = [data.ibm_is_ssh_key.itself.id]
}

module "bastion_autoscaling_group" {
  source                 = "../../../resources/ibmcloud/asg/instance_group"
  asg_name               = format("%s-%s", var.resource_prefix, "bastion-asg")
  launch_template_id     = module.bastion_autoscaling_launch_template.instance_template_id
  desired_instance_count = var.desired_instance_count
  subnets                = var.vpc_auto_scaling_group_subnets
}
