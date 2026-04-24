locals {
  # Simplified count value for all resources
  create_count = var.enable_bastion ? 1 : 0

  # Resource naming patterns
  bastion_sg_name          = "${var.resource_prefix}-bastion-sg"
  bastion_launch_tmpl_name = "${var.resource_prefix}-bastion-launch-tmpl"
  bastion_asg_name         = "${var.resource_prefix}-bastion-asg"

  # Validate that required arrays are not empty
  has_availability_zones = length(var.vpc_availability_zones) > 0
  has_subnets            = length(var.vpc_auto_scaling_group_subnets) > 0

  # Select first zone and subnet (with validation)
  selected_zone   = local.has_availability_zones ? var.vpc_availability_zones[0] : null
  selected_subnet = local.has_subnets ? var.vpc_auto_scaling_group_subnets[0] : null
}
