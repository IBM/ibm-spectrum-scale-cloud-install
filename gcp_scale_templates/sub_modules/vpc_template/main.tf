/*
    IBM Storage Scale cloud deployment requires 1 VPC with below resources.

    1.  VPC
    2.  PublicSubnet
    3.  PrivateSubnet
    4.  Router
    5.  Cloud NAT
*/

# VPC with no subnets
module "vpc" {
  source           = "../../../resources/gcp/vpc"
  turn_on          = var.vpc_cidr_block != null ? true : false
  vpc_name_prefix  = var.resource_prefix
  vpc_routing_mode = var.vpc_routing_mode
  vpc_description  = var.vpc_description
}

# Public subnet (as subnet is global to all zones)
module "public_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = var.vpc_public_subnets_cidr_blocks != null ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-public", var.resource_prefix)
  subnet_description    = format("This public subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_public_subnets_cidr_blocks
  private_google_access = false
}

# Compute private subnet
module "compute_private_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-comp-pvt", var.resource_prefix)
  subnet_description    = format("This private compute subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_compute_cluster_private_subnets_cidr_blocks
  private_google_access = true
}

# Storage private subnet
module "storage_private_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-strg-pvt", var.resource_prefix)
  subnet_description    = format("This private storage subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_storage_cluster_private_subnets_cidr_blocks
  private_google_access = true
}

# Protocol private subnet
module "protocol_private_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.vpc_protocol_private_subnets_cidr_blocks != null ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-protocol-pvt", var.resource_prefix)
  subnet_description    = format("This private storage subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_protocol_private_subnets_cidr_blocks
  private_google_access = true
}

# Create a router associated to vpc
module "router" {
  source      = "../../../resources/gcp/network/router"
  turn_on     = var.vpc_cidr_block != null ? true : false
  router_name = format("%s-router", var.resource_prefix)
  vpc_name    = module.vpc.vpc_self_link
}

# Create a NAT associated to compute subnet
module "compute_cloud_nat" {
  source            = "../../../resources/gcp/network/cloud_nat"
  turn_on           = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  nat_name          = format("%s-cmp-nat", var.resource_prefix)
  router_name       = module.router.router_name
  private_subnet_id = module.compute_private_subnet.subnet_id
}

# Create a NAT associated to storage subnet
module "storage_cloud_nat" {
  source            = "../../../resources/gcp/network/cloud_nat"
  turn_on           = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  nat_name          = format("%s-strg-nat", var.resource_prefix)
  router_name       = module.router.router_name
  private_subnet_id = module.storage_private_subnet.subnet_id
}

# Create a NAT associated to protocol subnet
module "protocol_cloud_nat" {
  source            = "../../../resources/gcp/network/cloud_nat"
  turn_on           = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  nat_name          = format("%s-protocol-nat", var.resource_prefix)
  router_name       = module.router.router_name
  private_subnet_id = module.protocol_private_subnet.subnet_id
}
