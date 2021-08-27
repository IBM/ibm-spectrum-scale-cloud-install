/*
    This nested module creates;
    1. New AWS VPC
    2. Bastion Instance
    3. (Compute, Storage) Instances along with Instance store attachments to storage instances
*/

data "ibm_resource_group" "itself" {
  name = var.resource_group
}

module "vpc" {
  source                                          = "../sub_modules/vpc_template"
  vpc_region                                      = var.vpc_region
  vpc_availability_zones                          = var.vpc_availability_zones
  resource_prefix                                 = var.resource_prefix
  resource_group_id                               = data.ibm_resource_group.itself.id
  vpc_cidr_block                                  = var.vpc_cidr_block
  vpc_storage_cluster_private_subnets_cidr_blocks = var.vpc_storage_cluster_private_subnets_cidr_blocks
  vpc_create_separate_subnets                     = var.vpc_create_separate_subnets
  vpc_compute_cluster_private_subnets_cidr_blocks = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_compute_cluster_dns_domain                  = var.vpc_compute_cluster_dns_domain
  vpc_storage_cluster_dns_domain                  = var.vpc_storage_cluster_dns_domain
}

module "bastion" {
  source                 = "../sub_modules/bastion_template"
  vpc_region             = var.vpc_region
  vpc_availability_zones = var.vpc_availability_zones
  vpc_id                 = module.vpc.vpc_id
  resource_prefix        = var.resource_prefix
  resource_group_id      = data.ibm_resource_group.itself.id
  bastion_osimage_name   = var.bastion_osimage_name
  remote_cidr_blocks     = var.remote_cidr_blocks
  bastion_vsi_profile    = var.bastion_vsi_profile
  bastion_key_pair       = var.bastion_key_pair
  bastion_subnet_id      = module.vpc.vpc_storage_cluster_private_subnets[0]
}

module "scale_instances" {
  source                                = "../sub_modules/instance_template"
  vpc_region                            = var.vpc_region
  vpc_availability_zones                = var.vpc_availability_zones
  resource_prefix                       = var.resource_prefix
  resource_group_id                     = data.ibm_resource_group.itself.id
  vpc_id                                = module.vpc.vpc_id
  vpc_storage_cluster_private_subnets   = module.vpc.vpc_storage_cluster_private_subnets
  vpc_compute_cluster_private_subnets   = module.vpc.vpc_compute_cluster_private_subnets
  total_compute_cluster_instances       = var.total_compute_cluster_instances
  compute_cluster_key_pair              = var.compute_cluster_key_pair
  compute_vsi_osimage_name              = var.compute_vsi_osimage_name
  compute_vsi_profile                   = var.compute_vsi_profile
  compute_cluster_gui_username          = var.compute_cluster_gui_username
  compute_cluster_gui_password          = var.compute_cluster_gui_password
  total_storage_cluster_instances       = var.total_storage_cluster_instances
  storage_cluster_key_pair              = var.storage_cluster_key_pair
  storage_vsi_osimage_name              = var.storage_vsi_osimage_name
  storage_vsi_profile                   = var.storage_vsi_profile
  storage_cluster_gui_username          = var.storage_cluster_gui_username
  storage_cluster_gui_password          = var.storage_cluster_gui_password
  using_packer_image                    = var.using_packer_image
  scale_ansible_repo_clone_path         = var.scale_ansible_repo_clone_path
  spectrumscale_rpms_path               = var.spectrumscale_rpms_path
  storage_cluster_filesystem_mountpoint = var.storage_cluster_filesystem_mountpoint
  compute_cluster_filesystem_mountpoint = var.compute_cluster_filesystem_mountpoint
  filesystem_block_size                 = var.filesystem_block_size
  scale_version                         = var.scale_version
  create_separate_namespaces            = var.create_separate_namespaces
  bastion_instance_id                   = module.bastion.bastion_instance_id
  bastion_instance_public_ip            = module.bastion.bastion_instance_public_ip
  bastion_security_group_id             = module.bastion.bastion_security_group_id
  bastion_ssh_private_key               = var.bastion_ssh_private_key
  vpc_compute_cluster_dns_service_id    = var.vpc_create_separate_subnets == true ? module.vpc.vpc_compute_cluster_dns_service_id : module.vpc.vpc_storage_cluster_dns_service_id
  vpc_storage_cluster_dns_service_id    = module.vpc.vpc_storage_cluster_dns_service_id
  vpc_compute_cluster_dns_zone_id       = module.vpc.vpc_compute_cluster_dns_zone_id
  vpc_storage_cluster_dns_zone_id       = module.vpc.vpc_storage_cluster_dns_zone_id
  vpc_compute_cluster_dns_domain        = var.vpc_compute_cluster_dns_domain
  vpc_storage_cluster_dns_domain        = var.vpc_storage_cluster_dns_domain
  vpc_custom_resolver_id                = module.vpc.vpc_custom_resolver_id
  vpc_create_activity_tracker           = var.vpc_create_activity_tracker
  activity_tracker_plan_type            = var.activity_tracker_plan_type
}
