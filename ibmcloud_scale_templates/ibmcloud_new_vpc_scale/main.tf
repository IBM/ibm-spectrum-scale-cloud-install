/*
    This nested module creates;
    1. New IBM Cloud VPC
    2. Bastion Instance
    3. (Compute, Storage) Instances along with Instance store attachments to storage instances
*/

module "vpc" {
  source                                          = "../sub_modules/vpc_template"
  vpc_region                                      = var.vpc_region
  vpc_availability_zones                          = var.vpc_availability_zones
  resource_prefix                                 = var.resource_prefix
  resource_group_name                             = var.resource_group != null ? var.resource_group : var.resource_prefix
  create_resource_group                           = var.resource_group == null ? true : false
  cluster_type                                    = var.cluster_type
  vpc_cidr_block                                  = var.vpc_cidr_block
  vpc_storage_cluster_private_subnets_cidr_blocks = var.vpc_storage_cluster_private_subnets_cidr_blocks
  vpc_compute_cluster_private_subnets_cidr_blocks = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_protocol_private_subnets_cidr_blocks        = var.vpc_protocol_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks                  = var.vpc_public_subnets_cidr_blocks
  ibmcloud_api_key                                = var.ibmcloud_api_key
  tags                                            = var.tags
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
  ibmcloud_api_key                = var.ibmcloud_api_key
  tags                            = var.tags
}

module "bastion" {
  source                         = "../sub_modules/bastion_template"
  enable_bastion                 = var.enable_bastion
  vpc_region                     = var.vpc_region
  vpc_availability_zones         = var.vpc_availability_zones
  vpc_ref                        = module.vpc.vpc_ref
  resource_prefix                = var.resource_prefix
  resource_group_id              = module.vpc.resource_group_id
  bastion_image_ref              = var.bastion_osimage_id
  remote_cidr_blocks             = var.remote_cidr_blocks
  bastion_instance_type          = var.bastion_vsi_profile
  bastion_public_key             = var.bastion_public_key
  vpc_auto_scaling_group_subnets = coalescelist(module.vpc.vpc_compute_cluster_private_subnets, module.vpc.vpc_storage_cluster_private_subnets)
  bastion_public_ssh_port        = 22
  desired_instance_count         = 1
  ibmcloud_api_key               = var.ibmcloud_api_key
  tags                           = var.tags
}

module "vpc_peering" {
  source                         = "../sub_modules/vpc_peering_template"
  enable_transit_gateway         = var.enable_transit_gateway
  vpc_region                     = var.vpc_region
  vpc_crn                        = module.vpc.vpc_crn
  peer_vpc_crn                   = var.peer_vpc_crn
  peer_security_group_id         = var.peer_security_group_id
  resource_prefix                = var.resource_prefix
  resource_group_id              = module.vpc.resource_group_id
  transit_gateway_name           = var.transit_gateway_name
  transit_gateway_global_routing = var.transit_gateway_global_routing
  vpc_cidr_block                 = var.vpc_cidr_block
  ibmcloud_api_key               = var.ibmcloud_api_key
  tags                           = var.tags
}

module "scale_instances" {
  source                                   = "../sub_modules/instance_template"
  vpc_region                               = var.vpc_region
  vpc_availability_zones                   = var.vpc_availability_zones
  resource_prefix                          = var.resource_prefix
  resource_group_id                        = module.vpc.resource_group_id
  cluster_type                             = var.cluster_type
  ibmcloud_api_key                         = var.ibmcloud_api_key
  vpc_id                                   = module.vpc.vpc_ref
  vpc_storage_cluster_private_subnets      = module.vpc.vpc_storage_cluster_private_subnets
  vpc_compute_cluster_private_subnets      = coalescelist(module.vpc.vpc_compute_cluster_private_subnets, module.vpc.vpc_storage_cluster_private_subnets)
  dns_service_instance_id                  = module.dns.dns_service_instance_id
  vpc_storage_cluster_dns_zone_id          = module.dns.vpc_storage_dns_zone_id
  vpc_storage_cluster_dns_domain           = module.dns.vpc_storage_dns_domain
  vpc_compute_cluster_dns_zone_id          = module.dns.vpc_compute_dns_zone_id
  vpc_compute_cluster_dns_domain           = module.dns.vpc_compute_dns_domain
  total_storage_cluster_instances          = var.total_storage_cluster_instances
  storage_cluster_image_id                 = var.storage_vsi_osimage_id
  storage_cluster_instance_type            = var.storage_vsi_profile
  storage_cluster_public_key               = var.storage_cluster_public_key
  boot_disk_type                           = var.boot_disk_type
  storage_cluster_tiebreaker_instance_type = var.storage_cluster_tiebreaker_instance_type
  total_storage_volumes                    = var.total_storage_volumes
  storage_volume_size                      = var.storage_volume_size
  storage_volume_profile                   = var.storage_volume_profile
  storage_volume_iops                      = var.storage_volume_iops
  total_compute_cluster_instances          = var.total_compute_cluster_instances
  compute_cluster_image_id                 = var.compute_vsi_osimage_id
  compute_cluster_instance_type            = var.compute_vsi_profile
  compute_cluster_public_key               = var.compute_cluster_public_key
  total_gateway_instances                  = var.total_gateway_instances
  gateway_instance_type                    = var.gateway_vsi_profile
  total_protocol_instances                 = var.total_protocol_instances
  protocol_instance_type                   = var.protocol_vsi_profile
  ces_ip_addresses                         = var.ces_ip_addresses
  client_ip_ranges                         = var.client_ip_ranges
  client_security_group_id                 = var.client_security_group_id
  using_cloud_connection                   = var.using_cloud_connection
  using_direct_connection                  = var.using_direct_connection
  bastion_security_group_id                = var.enable_bastion ? module.bastion.bastion_security_group_id : null
  using_jumphost_connection                = var.using_jumphost_connection != null ? var.using_jumphost_connection : var.enable_bastion
  root_device_kms_key_id                   = var.root_device_kms_key_id
  root_device_kms_key_name                 = var.root_device_kms_key_name
  airgap                                   = false
  enable_placement_group                   = var.enable_placement_group
  placement_group_strategy                 = var.placement_group_strategy
  orchestrator_server                      = var.orchestrator_server
  orchestrator_port                        = var.orchestrator_port
  orchestrator_ca_fingerprint              = var.orchestrator_ca_fingerprint
}
