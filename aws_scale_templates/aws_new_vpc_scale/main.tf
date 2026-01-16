/*
    This nested module creates;
    1. New AWS VPC
    2. Bastion Instance (via autoscaling group)
    3. (Compute, Storage) Instances along with EBS/Instance store attachments to storage instances
*/

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

module "scale_instances" {
  source                                   = "../sub_modules/instance_template"
  vpc_region                               = var.vpc_region
  vpc_availability_zones                   = var.vpc_availability_zones
  resource_prefix                          = var.resource_prefix
  vpc_id                                   = module.vpc.vpc_id
  vpc_storage_cluster_private_subnets      = module.vpc.vpc_storage_cluster_private_subnets
  vpc_compute_cluster_private_subnets      = module.vpc.vpc_compute_cluster_private_subnets
  total_compute_cluster_instances          = var.total_compute_cluster_instances
  compute_cluster_key_pair                 = var.compute_cluster_key_pair
  compute_cluster_image_id                 = var.compute_cluster_image_id
  compute_cluster_instance_type            = var.compute_cluster_instance_type
  compute_cluster_root_volume_type         = var.compute_cluster_root_volume_type
  compute_cluster_volume_tags              = var.compute_cluster_volume_tags
  compute_cluster_gui_username             = var.compute_cluster_gui_username
  compute_cluster_gui_password             = var.compute_cluster_gui_password
  compute_cluster_tags                     = var.compute_cluster_tags
  total_storage_cluster_instances          = var.total_storage_cluster_instances
  storage_cluster_key_pair                 = var.storage_cluster_key_pair
  storage_cluster_image_id                 = var.storage_cluster_image_id
  storage_cluster_instance_type            = var.storage_cluster_instance_type
  storage_cluster_tags                     = var.storage_cluster_tags
  storage_cluster_tiebreaker_instance_type = var.storage_cluster_tiebreaker_instance_type
  storage_cluster_root_volume_type         = var.storage_cluster_root_volume_type
  storage_cluster_volume_tags              = var.storage_cluster_volume_tags
  storage_cluster_gui_username             = var.storage_cluster_gui_username
  storage_cluster_gui_password             = var.storage_cluster_gui_password
  using_packer_image                       = var.using_packer_image
  using_rest_api_remote_mount              = var.using_rest_api_remote_mount
  ebs_block_devices_per_storage_instance   = var.ebs_block_devices_per_storage_instance
  ebs_block_device_delete_on_termination   = var.ebs_block_device_delete_on_termination
  ebs_block_device_encrypted               = var.ebs_block_device_encrypted
  ebs_block_device_iops                    = var.ebs_block_device_iops
  ebs_block_device_throughput              = var.ebs_block_device_throughput
  ebs_block_device_kms_key_id              = var.ebs_block_device_kms_key_id
  ebs_block_device_volume_size             = var.ebs_block_device_volume_size
  ebs_block_device_volume_type             = var.ebs_block_device_volume_type
  scale_ansible_repo_clone_path            = var.scale_ansible_repo_clone_path
  spectrumscale_rpms_path                  = var.spectrumscale_rpms_path
  operator_email                           = var.operator_email
  storage_cluster_filesystem_mountpoint    = var.storage_cluster_filesystem_mountpoint
  compute_cluster_filesystem_mountpoint    = var.compute_cluster_filesystem_mountpoint
  filesystem_block_size                    = var.filesystem_block_size
  create_separate_namespaces               = var.create_separate_namespaces
  bastion_instance_id                      = module.bastion.bastion_instance_id[0]
  bastion_instance_public_ip               = module.bastion.bastion_instance_public_ip[0]
  bastion_security_group_id                = module.bastion.bastion_security_group_id
  bastion_ssh_private_key                  = var.bastion_ssh_private_key
}
