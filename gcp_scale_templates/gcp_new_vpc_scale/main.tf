/*
    IBM Spectrum scale template for Google Cloud Platform(GCP) ,this nested module creates;
    1. New GCP VPC
    2. Bastion Instance
    3. (Compute, Storage) Instances
*/

terraform {
  backend "gcs" {}
}

module "vpc_module" {
  source                                          = "../sub_modules/vpc_template"
  resource_prefix                                 = var.resource_prefix
  vpc_region                                      = var.vpc_region
  gcp_project_id                                  = var.gcp_project_id
  credentials_file_path                           = var.credentials_file_path
  vpc_cidr_block                                  = var.vpc_cidr_block
  vpc_public_subnets_cidr_blocks                  = var.vpc_public_subnets_cidr_blocks
  vpc_compute_cluster_private_subnets_cidr_blocks = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_storage_cluster_private_subnets_cidr_blocks = var.vpc_storage_cluster_private_subnets_cidr_blocks
}

module "bastion_module" {
  source                = "../sub_modules/bastion_template"
  gcp_project_id        = var.gcp_project_id
  bastion_ssh_key_path  = var.bastion_ssh_key_path
  credentials_file_path = var.credentials_file_path
  public_subnet_name    = module.vpc_module.vpc_public_subnets[0]
  bastion_zone          = var.vpc_availability_zones[0]
  bastion_boot_image    = var.bastion_boot_image
}

module "instance_modules" {
  source                              = "../sub_modules/instance_template"
  resource_prefix                     = var.resource_prefix
  vpc_region                          = var.vpc_region
  gcp_project_id                      = var.gcp_project_id
  credentials_file_path               = var.credentials_file_path
  vpc_name                            = module.vpc_module.vpc_name
  operator_email                      = var.operator_email
  compute_cluster_public_key_path     = var.compute_cluster_public_key_path
  storage_cluster_public_key_path     = var.storage_cluster_public_key_path
  vpc_availability_zones              = var.vpc_availability_zones
  total_storage_cluster_instances     = var.total_storage_cluster_instances
  total_compute_cluster_instances     = var.total_compute_cluster_instances
  data_disks_per_instance             = var.data_disks_per_instance
  data_disk_size                      = var.data_disk_size
  data_disk_type                      = var.data_disk_type
  storage_boot_image                  = var.storage_boot_image
  compute_boot_image                  = var.compute_boot_image
  storage_boot_disk_size              = var.storage_boot_disk_size
  compute_boot_disk_size              = var.compute_boot_disk_size
  vpc_compute_cluster_private_subnets = module.vpc_module.vpc_compute_cluster_private_subnets
  vpc_storage_cluster_private_subnets = module.vpc_module.vpc_storage_cluster_private_subnets
  create_remote_mount_cluster         = var.create_remote_mount_cluster
  filesystem_block_size               = var.filesystem_block_size
  bastion_instance_public_ip          = module.bastion_module.bastion_instance_public_ip
}
