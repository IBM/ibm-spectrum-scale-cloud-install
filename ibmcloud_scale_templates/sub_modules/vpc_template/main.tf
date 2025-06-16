/*
    IBM Storage scale cloud deployment requires 1 VPC with below resources.

    1.  Resource group
    2.  VPC options
    3.  VPC address prefix
    4.  Public subnet / Gateway
    5.  PrivateSubnet {1, 2 ..3}
*/

# Create resource group
module "resource_group" {
  count               = var.create_resource_group ? 1 : 0
  source              = "../../../resources/ibmcloud/resource_group"
  resource_group_name = var.resource_group_name
}

data "ibm_resource_group" "itself" {
  name       = var.resource_group_name
  depends_on = [module.resource_group]
}

module "vpc" {
  source                        = "../../../resources/ibmcloud/network/vpc"
  vpc_name                      = var.resource_prefix
  vpc_address_prefix_management = "manual" # Setting it to auto, can create address prefixes non-aligned with subnet cidrs
  vpc_sg_name                   = format("%s-vpc-sg", var.resource_prefix)
  vpc_rt_name                   = format("%s-vpc-rt", var.resource_prefix)
  vpc_nw_acl_name               = format("%s-vpc-nwacl", var.resource_prefix)
  resource_group_id             = data.ibm_resource_group.itself.id
}

# Dynamically generate the address prefix based on the Calculate the number of new bits needed to split the VPC CIDR
locals {
  newbits              = ceil(log(max(length(var.vpc_availability_zones), 1), 2))
  address_prefix_cidrs = [for idx in range(length(var.vpc_availability_zones)) : cidrsubnet(var.vpc_cidr_block, local.newbits, idx)]
}

module "vpc_address_prefix" {
  source       = "../../../resources/ibmcloud/network/vpc_address_prefix"
  vpc_id       = module.vpc.vpc_id
  address_name = format("%s-addr", var.resource_prefix)
  zones        = var.vpc_availability_zones
  cidr_block   = local.address_prefix_cidrs
}

# IBM Cloud does not offer native NAT (attaching public gateway handles outbound connectivity)
# Create one internet gateway per subnet (public, private) in given number of AZ's.
module "vpc_internet_gw" {
  source            = "../../../resources/ibmcloud/network/public_gw"
  turn_on           = var.vpc_public_subnets_cidr_blocks != null ? true : false
  public_gw_name    = format("%s-gw", var.resource_prefix)
  resource_group_id = data.ibm_resource_group.itself.id
  vpc_id            = module.vpc.vpc_id
  zones             = var.vpc_availability_zones
}

# One public subnet per provided AZ.
module "public_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = var.vpc_public_subnets_cidr_blocks != null ? true : false
  subnets_cidr      = var.vpc_public_subnets_cidr_blocks
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-public", var.resource_prefix)
  public_gateway    = module.vpc_internet_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
}

module "storage_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-strg-pvt", var.resource_prefix)
  subnets_cidr      = var.vpc_storage_cluster_private_subnets_cidr_blocks
  public_gateway    = module.vpc_internet_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
}

module "compute_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-comp-pvt", var.resource_prefix)
  subnets_cidr      = var.vpc_compute_cluster_private_subnets_cidr_blocks
  public_gateway    = module.vpc_internet_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
}

module "protocol_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  turn_on           = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.vpc_protocol_private_subnets_cidr_blocks != null ? true : false
  vpc_id            = module.vpc.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-protocol-pvt", var.resource_prefix)
  subnets_cidr      = var.vpc_protocol_private_subnets_cidr_blocks
  public_gateway    = module.vpc_internet_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
}
