/*
    IBM Spectrum scale cloud deployment requires 1 VPC with below resources.

    1.  VPC options
    2.  VPC address prefix
    3.  Public subnet / Gateway
    4.  PrivateSubnet {1, 2 ..3}
    5.  DNS service
*/

module "vpc" {
  source                        = "../../../resources/ibmcloud/network/vpc"
  vpc_name                      = format("%s-vpc", var.resource_prefix)
  vpc_address_prefix_management = "manual"
  vpc_sg_name                   = format("%s-vpc-sg", var.resource_prefix)
  vpc_rt_name                   = format("%s-vpc-rt", var.resource_prefix)
  vpc_nw_acl_name               = format("%s-vpc-nwacl", var.resource_prefix)
  resource_group_id             = var.resource_group_id
}

module "vpc_address_prefix" {
  source       = "../../../resources/ibmcloud/network/vpc_address_prefix"
  vpc_id       = module.vpc.vpc_id
  address_name = format("%s-addr", var.resource_prefix)
  zones        = var.vpc_availability_zones
  cidr_block   = var.vpc_cidr_block
}

module "common_public_gw" {
  source            = "../../../resources/ibmcloud/network/public_gw"
  public_gw_name    = format("%s-gw", var.resource_prefix)
  resource_group_id = var.resource_group_id
  vpc_id            = module.vpc.vpc_id
  zones             = var.vpc_availability_zones
}

module "storage_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  vpc_id            = module.vpc.vpc_id
  resource_group_id = var.resource_group_id
  zones             = var.vpc_availability_zones
  subnet_name       = format("%s-strg-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_storage_cluster_private_subnets_cidr_blocks
  public_gateway    = module.common_public_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
}

module "compute_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  vpc_id            = module.vpc.vpc_id
  resource_group_id = var.resource_group_id
  zones             = var.vpc_create_separate_subnets == true ? [var.vpc_availability_zones[0]] : []
  subnet_name       = format("%s-comp-pvt", var.resource_prefix)
  subnet_cidr_block = var.vpc_compute_cluster_private_subnets_cidr_blocks
  public_gateway    = module.common_public_gw.public_gw_id
  depends_on        = [module.vpc_address_prefix]
}

module "dns_service" {
  source        = "../../../resources/ibmcloud/resource_instance"
  service_count = var.vpc_create_separate_subnets == true ? 2 : 1
  resource_instance_name = var.vpc_create_separate_subnets == true ? [format("%s-strgdns", var.resource_prefix), format("%s-compdns",
  var.resource_prefix)] : [format("%s-scaledns", var.resource_prefix)]
  resource_group_id = var.resource_group_id
  target_location   = "global"
  service_name      = "dns-svcs"
  plan_type         = "standard-dns"
}

module "storage_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_storage_cluster_dns_domain
  dns_service_id = module.dns_service.resource_guid[0]
  description    = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
  dns_label      = var.resource_prefix
}

module "storage_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = 1
  instance_id     = module.dns_service.resource_guid[0]
  zone_id         = module.storage_dns_zone.dns_zone_id
  vpc_crn         = module.vpc.vpc_crn
}

module "compute_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  dns_zone_count = 1
  dns_domain     = var.vpc_compute_cluster_dns_domain
  dns_service_id = var.vpc_create_separate_subnets == true ? module.dns_service.resource_guid[1] : module.dns_service.resource_guid[0]
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

module "compute_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = 1
  instance_id     = var.vpc_create_separate_subnets == true ? module.dns_service.resource_guid[1] : module.dns_service.resource_guid[0]
  zone_id         = module.compute_dns_zone.dns_zone_id
  vpc_crn         = module.vpc.vpc_crn
  depends_on      = [module.storage_dns_permitted_network]
}

#FIXME: Multi-az
module "custom_resolver" {
  source                 = "../../../resources/ibmcloud/network/dns_custom_resolver"
  customer_resolver_name = format("%s-vpc-resolver", var.resource_prefix)
  instance_guid          = module.dns_service.resource_guid[0]
  subnet_crn             = module.storage_private_subnet.subnet_crn[0]
  description            = "Private DNS custom resolver for Spectrum Scale VPC DNS communication."
}
