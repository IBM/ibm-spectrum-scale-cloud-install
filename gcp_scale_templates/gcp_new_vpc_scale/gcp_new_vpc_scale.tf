/*
    This nested module creates;
    1. New GCP VPC
    2. Bastion Instance
    3. (Compute, Storage) Instances
*/

terraform {
  backend "gcs" {}
}

module "vpc_module" {
  source                = "../sub_modules/vpc_template"
  stack_name            = var.stack_name
  region                = var.region
  vpc_routing_mode      = var.vpc_routing_mode
  vpc_description       = var.vpc_description
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_cidr   = var.private_subnet_cidr
  credentials_file_path = var.credentials_file_path
}

module "bastion_module" {
  source                       = "../sub_modules/bastion_template"
  bastion_zone                 = var.zones.0
  region                       = var.region
  stack_name                   = var.stack_name
  vpc_name                     = module.vpc_module.vpc_name
  bastion_machine_type         = var.bastion_machine_type
  bastion_instance_name_prefix = "bastion"
  bastion_boot_disk_size       = var.bastion_boot_disk_size
  bastion_boot_disk_type       = var.bastion_boot_disk_type
  bastion_boot_image           = var.bastion_boot_image
  bastion_network_tier         = var.bastion_network_tier
  bastion_instance_tags        = [module.vpc_module.public_subnet_name]
  public_subnet_name           = module.vpc_module.public_subnet_name
  operator_email               = var.operator_email
  scopes                       = var.scopes
  bastion_ssh_user_name        = var.instances_ssh_user_name
  bastion_ssh_key_path         = var.instances_ssh_key_path
  credentials_file_path        = var.credentials_file_path
}

module "instance_modules" {
  source                              = "../sub_modules/instance_template"
  zones                               = var.zones
  region                              = var.region
  stack_name                          = var.stack_name
  vpc_name                            = module.vpc_module.vpc_name
  total_compute_instances             = var.total_compute_instances
  total_storage_instances             = var.total_storage_instances
  compute_machine_type                = var.compute_machine_type
  compute_instance_name_prefix        = "compute"
  compute_boot_disk_size              = var.compute_boot_disk_size
  compute_boot_disk_type              = var.compute_boot_disk_type
  compute_boot_image                  = var.compute_boot_image
  compute_network_tier                = var.compute_network_tier
  storage_machine_type                = var.storage_machine_type
  storage_instance_name_prefix        = "storage"
  storage_boot_disk_size              = var.storage_boot_disk_size
  storage_boot_disk_type              = var.storage_boot_disk_type
  storage_boot_image                  = var.storage_boot_image
  storage_network_tier                = var.storage_network_tier
  compute_instance_tags               = [module.vpc_module.private_subnet_name]
  private_subnet_name                 = module.vpc_module.private_subnet_name
  instances_ssh_user_name             = var.instances_ssh_user_name
  instances_ssh_key_path              = var.instances_ssh_key_path
  data_disks_per_instance             = var.data_disks_per_instance
  data_disk_type                      = var.data_disk_type
  data_disk_size                      = var.data_disk_size
  data_disk_physical_block_size_bytes = var.data_disk_physical_block_size_bytes
  operator_email                      = var.operator_email
  scopes                              = var.scopes
  credentials_file_path               = var.credentials_file_path
}
