/*
    VPC Template Module for IBM Storage Scale Cloud Deployment

    This module creates a complete VPC infrastructure with the following resources:

    1.  Resource group (optional - can use existing)
    2.  VPC with manual address prefix management
    3.  VPC address prefixes (dynamically calculated per availability zone)
    4.  Public gateway (for outbound internet connectivity)
    5.  Public subnets (optional - for bastion/jump hosts)
    6.  Storage cluster private subnets (for storage nodes)
    7.  Compute cluster private subnets (for compute nodes)
    8.  Protocol private subnets (optional - for protocol/CES nodes)

    The module supports three cluster types:
    - Storage-only: Creates storage and protocol subnets
    - Compute-only: Creates compute subnets
    - Combined-compute-storage: Creates all subnet types
*/

# Create resource group
module "resource_group" {
  count               = var.create_resource_group ? 1 : 0
  source              = "../../../resources/ibmcloud/resource_group"
  resource_group_name = var.resource_group_name
}

# Newly created resource groups can take time to propagate to the VPC ("is") API backend;
# without this delay, ibm_is_vpc/ibm_is_ssh_key intermittently fail right after creation with
# "Resource Group ID provided was not found".
resource "time_sleep" "wait_for_resource_group" {
  count           = var.create_resource_group ? 1 : 0
  depends_on      = [module.resource_group]
  create_duration = "30s"
}

data "ibm_resource_group" "itself" {
  name       = var.resource_group_name
  depends_on = [module.resource_group, time_sleep.wait_for_resource_group]
}

module "vpc" {
  source                        = "../../../resources/ibmcloud/network/vpc"
  vpc_name                      = var.resource_prefix
  vpc_address_prefix_management = "manual" # Setting it to auto, can create address prefixes non-aligned with subnet cidrs
  vpc_sg_name                   = local.vpc_sg_name
  vpc_rt_name                   = local.vpc_rt_name
  vpc_nw_acl_name               = local.vpc_nw_acl_name
  resource_group_id             = data.ibm_resource_group.itself.id
  tags                          = var.tags
}

module "vpc_address_prefix" {
  source       = "../../../resources/ibmcloud/network/vpc_address_prefix"
  vpc_id       = module.vpc.vpc_id
  address_name = local.address_name
  zones        = var.vpc_availability_zones
  cidr_block   = local.address_prefix_cidrs
}

# IBM Cloud does not offer native NAT (attaching public gateway handles outbound connectivity)
module "vpc_internet_gw" {
  source            = "../../../resources/ibmcloud/network/public_gw"
  turn_on           = true
  public_gw_name    = local.public_gw_name
  resource_group_id = data.ibm_resource_group.itself.id
  vpc_id            = module.vpc.vpc_id
  zones             = var.vpc_availability_zones
  tags              = var.tags
}

# One public subnet per provided AZ.
module "public_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = local.enable_public_subnets
  subnets_cidr      = var.vpc_public_subnets_cidr_blocks
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = local.public_subnet_name
  public_gateway    = module.vpc_internet_gw.public_gw_id
  tags              = var.tags
  depends_on        = [module.vpc_address_prefix]
}

module "storage_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = local.is_storage_cluster
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = local.storage_subnet_name
  subnets_cidr      = var.vpc_storage_cluster_private_subnets_cidr_blocks
  public_gateway    = module.vpc_internet_gw.public_gw_id
  tags              = var.tags
  depends_on        = [module.vpc_address_prefix]
}

module "compute_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = local.is_compute_cluster
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = local.compute_subnet_name
  subnets_cidr      = var.vpc_compute_cluster_private_subnets_cidr_blocks
  public_gateway    = module.vpc_internet_gw.public_gw_id
  tags              = var.tags
  depends_on        = [module.vpc_address_prefix]
}

module "protocol_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = local.enable_protocol_subnet
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = local.protocol_subnet_name
  subnets_cidr      = var.vpc_protocol_private_subnets_cidr_blocks
  public_gateway    = module.vpc_internet_gw.public_gw_id
  tags              = var.tags
  depends_on        = [module.vpc_address_prefix]
}
