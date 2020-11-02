/*
    This nested module creates;
    1. New IBM Cloud VPC
    2. Bastion Instance/VSI
    3. (Compute, Storage) Instances/VSI along with volume attachments to storage instances
*/

module "vpc_module" {
  source           = "../sub_modules/vpc_template"
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  zones            = var.zones
  cidr_block       = var.cidr_block
  stack_name       = var.stack_name
  addr_prefixes    = var.addr_prefixes
}

module "bastion_module" {
  source                  = "../sub_modules/bastion_template"
  region                  = var.region
  ibmcloud_api_key        = var.ibmcloud_api_key
  zones                   = var.zones
  stack_name              = var.stack_name
  vpc_id                  = module.vpc_module.vpc_id
  bastion_incoming_remote = var.bastion_incoming_remote
  bastion_osimage_name    = var.bastion_osimage_name
  bastion_vsi_profile     = var.bastion_vsi_profile
  bastion_key_name        = var.bastion_key_name
  bastion_subnet_id       = module.vpc_module.private_subnets
}

module "instances_module" {
  source                        = "../sub_modules/instance_template"
  region                        = var.region
  ibmcloud_api_key              = var.ibmcloud_api_key
  zones                         = var.zones
  cidr_block                    = var.cidr_block
  stack_name                    = var.stack_name
  vpc_id                        = module.vpc_module.vpc_id
  total_compute_instances       = var.total_compute_instances
  total_storage_instances       = var.total_storage_instances
  compute_instance_osimage_name = var.compute_osimage_name
  storage_instance_osimage_name = var.storage_osimage_name
  compute_vsi_profile           = var.compute_vsi_profile
  storage_vsi_profile           = var.storage_vsi_profile
  instance_key_name             = var.instance_key_name
  private_subnet_ids            = module.vpc_module.private_subnets
  data_disks_per_instance       = var.data_disks_per_instance
  volume_profile                = var.volume_profile
  volume_iops                   = var.volume_iops
  volume_capacity               = var.volume_capacity
}
