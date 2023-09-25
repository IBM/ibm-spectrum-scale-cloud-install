/*
    IBM Storage Scale cloud deployment requires one VPC with below resources.

    1.  VPC
    2.  PublicSubnet
    3.  PrivateSubnet
    4.  Router
    5.  Cloud NAT
*/

locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets_cidr_blocks != null && var.vpc_compute_cluster_private_subnets_cidr_blocks == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets_cidr_blocks == null && var.vpc_compute_cluster_private_subnets_cidr_blocks != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets_cidr_blocks != null && var.vpc_compute_cluster_private_subnets_cidr_blocks != null) ? "combined" : "none"
  )
}

module "vpc" {
  source           = "../../../resources/gcp/vpc"
  turn_on          = var.vpc_cidr_block != null ? true : false
  vpc_name_prefix  = var.resource_prefix
  vpc_routing_mode = var.vpc_routing_mode
  vpc_description  = var.vpc_description
}

module "public_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = var.vpc_public_subnets_cidr_blocks != null ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-%s", var.resource_prefix, "public")
  subnet_description    = format("This public subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_public_subnets_cidr_blocks
  private_google_access = false
}

module "compute_private_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-%s", var.resource_prefix, "comp-pvt")
  subnet_description    = format("This private compute subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_compute_cluster_private_subnets_cidr_blocks
  private_google_access = true
}

module "storage_private_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  turn_on               = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
  vpc_name              = module.vpc.vpc_self_link
  subnet_name_prefix    = format("%s-%s", var.resource_prefix, "strg-pvt")
  subnet_description    = format("This private storage subnet belongs to %s", var.resource_prefix)
  subnet_cidr_range     = var.vpc_storage_cluster_private_subnets_cidr_blocks
  private_google_access = true
}

module "router" {
  source      = "../../../resources/gcp/network/router"
  turn_on     = var.vpc_cidr_block != null ? true : false
  router_name = format("%s-%s", var.resource_prefix, "router")
  vpc_name    = module.vpc.vpc_self_link
}

module "compute_cloud_nat" {
  source            = "../../../resources/gcp/network/cloud_nat"
  turn_on           = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
  nat_name          = format("%s-comp-pvt-%s", var.resource_prefix, "nat")
  router_name       = module.router.router_name
  private_subnet_id = module.compute_private_subnet.subnet_id
}

module "storage_cloud_nat" {
  source            = "../../../resources/gcp/network/cloud_nat"
  turn_on           = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
  nat_name          = format("%s-strg-pvt-%s", var.resource_prefix, "nat")
  router_name       = module.router.router_name
  private_subnet_id = module.storage_private_subnet.subnet_id
}
