/*
    For Scale deployment, we need 1 VPC (creates a new one).

    GCP VPC Blueprint;
    1.  VPC
    2.  PublicSubnet
    3.  PrivateSubnet
*/

module "vpc" {
  source           = "../../../resources/gcp/vpc"
  vpc_name_prefix  = var.stack_name
  vpc_routing_mode = var.vpc_routing_mode
  vpc_description  = var.vpc_description
}

module "public_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  vpc_name              = module.vpc.vpc_name
  subnet_name_prefix    = format("%s-%s", var.stack_name, "public")
  subnet_description    = format("This public subnet belongs to %s", module.vpc.vpc_name)
  subnet_cidr_range     = var.public_subnet_cidr
  private_google_access = false
}

module "private_subnet" {
  source                = "../../../resources/gcp/network/subnet"
  vpc_name              = module.vpc.vpc_name
  subnet_name_prefix    = format("%s-%s", var.stack_name, "private")
  subnet_description    = format("This private subnet belongs to %s", module.vpc.vpc_name)
  subnet_cidr_range     = var.private_subnet_cidr
  private_google_access = true
}

module "router" {
  source      = "../../../resources/gcp/network/router"
  router_name = format("%s-%s", var.stack_name, "router")
  vpc_name    = module.vpc.vpc_name
}

module "cloud_nat" {
  source              = "../../../resources/gcp/network/cloud_nat"
  nat_name            = format("%s-%s", var.stack_name, "nat")
  router_name         = module.router.router_name
  private_subnet_name = module.private_subnet.subnet_name
}
