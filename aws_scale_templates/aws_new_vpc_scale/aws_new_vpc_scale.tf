/*
    This nested module creates;
    1. New AWS VPC
    2. Bastion Instance (via autoscaling group)
    3. (Compute, Storage) Instances along with EBS attachments to storage instances
*/

terraform {
  backend "s3" {}
}

module "vpc_module" {
  source             = "../sub_modules/vpc_template"
  region             = var.region
  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  stack_name         = var.stack_name
}

module "bastion_module" {
  source                     = "../sub_modules/bastion_template"
  region                     = var.region
  stack_name                 = var.stack_name
  auto_scaling_group_subnets = module.vpc_module.public_subnets
  bastion_image_name         = var.bastion_image_name
  bastion_instance_type      = var.bastion_instance_type
  key_name                   = var.key_name
  vpc_id                     = module.vpc_module.vpc_id
}

locals {
  cloud_env      = true
  cloud_platform = "AWS"
}

module "instances_module" {
  source                                   = "../sub_modules/instance_template"
  region                                   = var.region
  bastion_sec_group_id                     = module.bastion_module.bastion_sec_group_id
  compute_ami_id                           = var.compute_ami_id
  compute_instance_type                    = var.compute_instance_type
  storage_ami_id                           = var.storage_ami_id
  storage_instance_type                    = var.storage_instance_type
  root_volume_enable_delete_on_termination = true
  ebs_volume_iops                          = var.ebs_volume_iops
  ebs_volume_size                          = var.ebs_volume_size
  ebs_volume_type                          = var.ebs_volume_type
  ebs_volumes_per_instance                 = var.ebs_volumes_per_instance
  ebs_enable_delete_on_termination         = var.ebs_enable_delete_on_termination
  key_name                                 = var.key_name
  private_instance_subnet_ids              = module.vpc_module.private_subnets
  total_compute_instances                  = var.total_compute_instances
  total_storage_instances                  = var.total_storage_instances
  vpc_id                                   = module.vpc_module.vpc_id
  deploy_container_sec_group_id            = null
  tf_data_path                             = var.tf_data_path
  tf_ansible_key                           = var.tf_ansible_key
  operator_email                           = var.operator_email
  cloud_env                                = local.cloud_env
  cloud_platform                           = local.cloud_platform
  bucket_name                              = var.bucket_name
  availability_zones                       = var.availability_zones
  create_scale_cluster                     = var.create_scale_cluster
  filesystem_mountpoint                    = var.filesystem_mountpoint
  filesystem_block_size                    = var.filesystem_block_size
  ansible_scale_repo_clone_path            = var.ansible_scale_repo_clone_path
}
