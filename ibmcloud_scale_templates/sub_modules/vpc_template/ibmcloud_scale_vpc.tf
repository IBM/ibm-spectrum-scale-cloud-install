/*
    For Scale deployment, we need 1 VPC (creates a new one).

    IBM Cloud VPC Blueprint;
    1.  VPC options
    2.  VPC address prefix
    3.  Public subnet / Gateway
    4.  PrivateSubnet {1, 2 ..3}
    5.  DNS service
*/

module "vpc" {
  source          = "../../../resources/ibmcloud/network/vpc"
  resource_grp_id = var.resource_grp_id
  vpc_name_prefix = var.stack_name
}

module "vpc_addr_prefix" {
  source              = "../../../resources/ibmcloud/network/vpc_addr_prefix"
  vpc_id              = module.vpc.vpc_id
  address_name_prefix = var.stack_name
  zones               = var.zones
  cidr_block          = var.addr_prefixes
}

module "common_public_gw" {
  source          = "../../../resources/ibmcloud/network/public_gw"
  public_gw_name  = format("%s-gw", var.stack_name)
  resource_grp_id = var.resource_grp_id
  vpc_id          = module.vpc.vpc_id
  zones           = var.zones
}

module "storage_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  vpc_id            = module.vpc.vpc_id
  resource_grp_id   = var.resource_grp_id
  zones             = var.zones
  subnet_name       = format("%s-strg-pvt", var.stack_name)
  subnet_cidr_block = var.storage_cidr_block
  public_gateway    = module.common_public_gw.public_gw_id

  depends_on = [module.vpc_addr_prefix]
}

module "compute_private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  count             = var.create_seperate_subnets == true ? 1 : 0
  vpc_id            = module.vpc.vpc_id
  resource_grp_id   = var.resource_grp_id
  zones             = var.zones
  subnet_name       = format("%s-comp-pvt", var.stack_name)
  subnet_cidr_block = var.compute_cidr_block
  public_gateway    = module.common_public_gw.public_gw_id

  depends_on = [module.vpc_addr_prefix]
}

module "dns_service" {
  source                 = "../../../resources/ibmcloud/resource_instance"
  service_count          = var.create_seperate_subnets == true ? 2 : 1
  resource_instance_name = [format("%s-strgdns", var.stack_name), format("%s-compdns", var.stack_name)]
  resource_grp_id        = var.resource_grp_id
  target_location        = "global"
  service_name           = "dns-svcs"
  plan_type              = "standard-dns"
}

module "dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  dns_zone_count = var.create_seperate_subnets == true ? 2 : 1
  dns_domain     = var.dns_domains
  dns_service_id = module.dns_service.resource_guid
  dns_label      = var.stack_name
  vpc_crn        = module.vpc.vpc_crn
}
