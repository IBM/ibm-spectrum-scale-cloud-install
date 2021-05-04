/*
    This nested module creates;
    1. New IBM Cloud VPC
    2. Bastion Instance/VSI
    3. (Compute, Storage) Instances/VSI along with volume attachments to storage instances
*/

locals {
  tf_data_path                = "/tmp/.schematics/IBM/tf_data_path"
  scale_infra_repo_clone_path = "/tmp/.schematics/IBM/ibm-spectrumscale-cloud-deploy"
  block_volumes_per_instance  = 0
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

module "vpc_module" {
  source                  = "../sub_modules/vpc_template"
  region                  = var.region
  zones                   = var.zones
  compute_cidr_block      = var.compute_cidr_block
  storage_cidr_block      = var.storage_cidr_block
  create_seperate_subnets = var.create_seperate_subnets
  dns_domains             = var.dns_domains
  stack_name              = var.stack_name
  addr_prefixes           = var.addr_prefixes
  resource_grp_id         = data.ibm_resource_group.group.id
}

module "bastion_module" {
  source                  = "../sub_modules/bastion_template"
  region                  = var.region
  zones                   = var.zones
  stack_name              = var.stack_name
  vpc_id                  = module.vpc_module.vpc_id
  bastion_incoming_remote = var.bastion_incoming_remote
  bastion_osimage_name    = var.bastion_osimage_name
  bastion_vsi_profile     = var.bastion_vsi_profile
  bastion_ssh_key         = var.bastion_ssh_key
  bastion_subnet_id       = var.create_seperate_subnets == true ? module.vpc_module.compute_private_subnets : module.vpc_module.storage_private_subnets
  resource_grp_id         = data.ibm_resource_group.group.id
}

module "instances_module" {
  source                      = "../sub_modules/instance_template"
  region                      = var.region
  zones                       = var.zones
  dns_service_ids             = module.vpc_module.dns_service_ids
  dns_zone_ids                = module.vpc_module.dns_zone_ids
  compute_cidr_block          = var.compute_cidr_block
  storage_cidr_block          = var.storage_cidr_block
  compute_private_subnets     = module.vpc_module.compute_private_subnets
  storage_private_subnets     = module.vpc_module.storage_private_subnets
  stack_name                  = var.stack_name
  vpc_id                      = module.vpc_module.vpc_id
  total_compute_instances     = var.total_compute_instances
  total_storage_instances     = var.total_storage_instances
  compute_vsi_osimage_name    = var.compute_vsi_osimage_name
  storage_vsi_osimage_name    = var.storage_vsi_osimage_name
  compute_vsi_profile         = var.compute_vsi_profile
  storage_vsi_profile         = var.storage_vsi_profile
  instance_ssh_key            = var.instance_ssh_key
  block_volumes_per_instance  = local.block_volumes_per_instance
  volume_profile              = "10iops-tier"
  volume_iops                 = null
  volume_capacity             = 100
  tf_data_path                = local.tf_data_path
  scale_infra_repo_clone_path = local.scale_infra_repo_clone_path
  bastion_public_ip           = module.bastion_module.bastion_fip
  bastion_os_flavor           = module.bastion_module.bastion_os_flavor
  scale_version               = var.scale_version
  filesystem_mountpoint       = var.filesystem_mountpoint
  filesystem_block_size       = var.filesystem_block_size
  instances_ssh_private_key   = var.instances_ssh_private_key
  resource_grp_id             = data.ibm_resource_group.group.id
}
