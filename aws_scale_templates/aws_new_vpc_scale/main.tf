module "vpc" {
  source                                          = "../sub_modules/vpc_template"
  vpc_region                                      = var.vpc_region
  vpc_availability_zones                          = var.vpc_availability_zones
  resource_prefix                                 = var.resource_prefix
  vpc_cidr_block                                  = var.vpc_cidr_block
  vpc_public_subnets_cidr_blocks                  = var.vpc_public_subnets_cidr_blocks
  vpc_storage_cluster_private_subnets_cidr_blocks = var.vpc_storage_cluster_private_subnets_cidr_blocks
  vpc_create_separate_subnets                     = var.vpc_create_separate_subnets
  vpc_compute_cluster_private_subnets_cidr_blocks = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_tags                                        = var.vpc_tags
}

module "bastion" {
  source                         = "../sub_modules/bastion_template"
  vpc_region                     = var.vpc_region
  vpc_id                         = module.vpc.vpc_id
  resource_prefix                = var.resource_prefix
  bastion_public_ssh_port        = var.bastion_public_ssh_port
  remote_cidr_blocks             = var.remote_cidr_blocks
  bastion_ami_name               = var.bastion_ami_name
  bastion_instance_type          = var.bastion_instance_type
  bastion_key_pair               = var.bastion_key_pair
  vpc_auto_scaling_group_subnets = module.vpc.vpc_public_subnets
}
