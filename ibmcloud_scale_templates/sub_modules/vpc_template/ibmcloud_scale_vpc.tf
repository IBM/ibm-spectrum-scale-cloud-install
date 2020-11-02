/*
    For Scale deployment, we need 1 VPC (creates a new one).

    IBM Cloud VPC Blueprint;
    1.  DHCP options
    2.  VPC
    3.  DHCP options association
    4.  Internet Gateway
    5.  Route tables (1 rt seperate for each AZ private, 1rt for all AZ public)
    6.  PublicSubnet {1, 2 ..3}
    7.  NAT {1, 2..3} EIP
    8.  PrivateSubnet {1, 2 ..3}
    9.  NAT gateway attachment
    10. VPC s3 endpoint
*/

module "vpc" {
  source          = "../../../resources/ibmcloud/network/vpc"
  vpc_name_prefix = var.stack_name
}

module "vpc_addr_prefix" {
  source              = "../../../resources/ibmcloud/network/vpc_addr_prefix"
  vpc_id              = module.vpc.vpc_id
  address_name_prefix = var.stack_name
  zones               = var.zones
  cidr_block          = var.addr_prefixes
}

module "public_gw" {
  source         = "../../../resources/ibmcloud/network/public_gw"
  public_gw_name = format("%s-gw", var.stack_name)
  vpc_id         = module.vpc.vpc_id
  zones          = var.zones
}

/*
    For Scale deployment, we need 1 SNAT per provided Zone.
*/
module "private_subnet" {
  source            = "../../../resources/ibmcloud/network/subnet"
  vpc_id            = module.vpc.vpc_id
  zones             = var.zones
  subnet_name       = format("%s-private", var.stack_name)
  subnet_cidr_block = var.cidr_block
  public_gateway    = module.public_gw.public_gw_id
}
