/*
    This nested module creates;
    1. New AWS VPC
    2. Bastion Instance
    3. (Compute, Storage) Instances along with Instance store attachments to storage instances
*/

module "vpc" {
  source                                          = "../sub_modules/vpc_template"
  vpc_region                                      = var.vpc_region
  vpc_availability_zones                          = var.vpc_availability_zones
  resource_prefix                                 = var.resource_prefix
  resource_group_name                             = var.resource_group != null ? var.resource_group : "${var.resource_prefix}-rg"
  create_resource_group                           = var.resource_group == null ? true : false
  cluster_type                                    = var.cluster_type
  vpc_cidr_block                                  = var.vpc_cidr_block
  vpc_storage_cluster_private_subnets_cidr_blocks = var.vpc_storage_cluster_private_subnets_cidr_blocks
  vpc_compute_cluster_private_subnets_cidr_blocks = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_protocol_private_subnets_cidr_blocks        = var.vpc_protocol_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks                  = var.vpc_public_subnets_cidr_blocks
  ibmcloud_api_key                                = var.ibmcloud_api_key
}

module "dns" {
  source                          = "../sub_modules/dns_template"
  vpc_region                      = var.vpc_region
  vpc_ref                         = module.vpc.vpc_ref
  resource_prefix                 = var.resource_prefix
  resource_group_id               = module.vpc.resource_group_id
  cluster_type                    = var.cluster_type
  create_dns_zone                 = var.create_dns_zone
  dns_service_instance_id         = var.dns_service_instance_id
  vpc_storage_cluster_dns_domain  = var.vpc_storage_cluster_dns_domain
  vpc_compute_cluster_dns_domain  = var.vpc_compute_cluster_dns_domain
  vpc_protocol_cluster_dns_domain = var.vpc_protocol_cluster_dns_domain
  vpc_reverse_dns_domain          = var.vpc_reverse_dns_zone
  ibmcloud_api_key                = var.ibmcloud_api_key
}

module "bastion" {
  source                         = "../sub_modules/bastion_template"
  enable_bastion                 = var.enable_bastion
  vpc_region                     = var.vpc_region
  vpc_availability_zones         = var.vpc_availability_zones
  vpc_ref                        = module.vpc.vpc_ref
  resource_prefix                = var.resource_prefix
  resource_group_id              = module.vpc.resource_group_id
  bastion_image_ref              = var.bastion_osimage_name
  remote_cidr_blocks             = var.remote_cidr_blocks
  bastion_instance_type          = var.bastion_vsi_profile
  bastion_key_pair               = var.bastion_key_pair
  vpc_auto_scaling_group_subnets = module.vpc.vpc_storage_cluster_private_subnets
  bastion_public_ssh_port        = 22
  desired_instance_count         = 1
  ibmcloud_api_key               = var.ibmcloud_api_key
}

module "vpc_peering" {
  source                         = "../sub_modules/vpc_peering_template"
  enable_transit_gateway         = var.enable_transit_gateway
  vpc_region                     = var.vpc_region
  vpc_crn                        = module.vpc.vpc_crn
  peer_vpc_crn                   = var.peer_vpc_crn
  resource_prefix                = var.resource_prefix
  resource_group_id              = module.vpc.resource_group_id
  transit_gateway_id             = var.transit_gateway_id
  transit_gateway_name           = var.transit_gateway_name
  transit_gateway_global_routing = var.transit_gateway_global_routing
  ibmcloud_api_key               = var.ibmcloud_api_key
}
/*
module "scale_instances" {
  source                                   = "../sub_modules/instance_template"
  vpc_region                               = var.vpc_region
  vpc_availability_zones                   = var.vpc_availability_zones
  resource_prefix                          = var.resource_prefix
  resource_group_name                      = var.resource_group
  vpc_ref                                  = module.vpc.vpc_ref
  vpc_storage_cluster_private_subnets      = module.vpc.vpc_storage_cluster_private_subnets
  vpc_compute_cluster_private_subnets      = length(var.vpc_compute_cluster_private_subnets_cidr_blocks) > 0 ? module.vpc.vpc_compute_cluster_private_subnets : module.vpc.vpc_storage_cluster_private_subnets
  vpc_compute_cluster_dns_domain           = var.vpc_compute_cluster_dns_domain
  vpc_storage_cluster_dns_domain           = var.vpc_storage_cluster_dns_domain
  dns_service_instance_id                  = var.dns_service_instance_id
  total_compute_cluster_instances          = var.total_compute_cluster_instances
  compute_cluster_image_ref                = var.compute_vsi_osimage_name
  compute_cluster_instance_type            = var.compute_vsi_profile
  compute_cluster_gui_username             = var.compute_cluster_gui_username
  compute_cluster_gui_password             = var.compute_cluster_gui_password
  compute_cluster_boot_disk_type           = null
  compute_cluster_tags                     = null
  compute_cluster_volume_tags              = null
  compute_cluster_public_key_path          = var.compute_cluster_key_pair
  total_storage_cluster_instances          = var.total_storage_cluster_instances
  storage_cluster_image_ref                = var.storage_vsi_osimage_name
  storage_cluster_instance_type            = var.storage_vsi_profile
  storage_cluster_gui_username             = var.storage_cluster_gui_username
  storage_cluster_gui_password             = var.storage_cluster_gui_password
  storage_cluster_boot_disk_type           = null
  storage_cluster_tags                     = null
  storage_cluster_volume_tags              = null
  storage_cluster_public_key_path          = var.storage_cluster_key_pair
  storage_cluster_tiebreaker_instance_type = null
  filesystem_parameters                    = []
  compute_cluster_filesystem_mountpoint    = var.compute_cluster_filesystem_mountpoint
  cluster_type                             = "Combined-compute-storage"
  bastion_instance_ref                     = module.bastion.bastion_instance_autoscaling_group_ref
  bastion_instance_public_ip               = null
  bastion_security_group_ref               = module.bastion.bastion_security_group_ref
  bastion_ssh_private_key                  = var.bastion_ssh_private_key
  bastion_user                             = "root"
  using_jumphost_connection                = true
  instances_ssh_user_name                  = null
  airgap                                   = false
  root_device_encrypted                    = false
  root_device_kms_key_ref                  = null
  root_device_kms_key_ref_name             = null
  inventory_format                         = "ini"
  enable_placement_group                   = var.enable_placement_group
  marked_vm_names_to_attach_disks          = []
  total_gateway_instances                  = 0
  gateway_instance_type                    = null
  gateway_tags                             = null
  gateway_volume_tags                      = null
  total_protocol_instances                 = 0
  protocol_instance_type                   = null
  protocol_tags                            = null
  protocol_volume_tags                     = null
  ces_ip_address                           = []
  ibmcloud_api_key                         = var.ibmcloud_api_key
}
*/
