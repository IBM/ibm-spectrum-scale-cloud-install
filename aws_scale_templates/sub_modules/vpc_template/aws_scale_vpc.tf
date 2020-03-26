/*
    For Scale deployment, we need 1 VPC (creates a new one).

    AWS VPC Blueprint;
    1.  DHCP options
    2.  VPC
    3.  DHCP options association
    4.  Internet Gateway
    5.  Route tables (1 rt seperate for each AZ private, 1rt for all AZ public)
    6.  PublicSubnet{1, 2 ..3}
    7.  NAT{1, 2..3}EIP
    8.  PrivateSubnet{1, 2 ..3}
    9.  NAT gateway attachment
    10. VPC s3 endpoint
*/

module "vpc" {
  source       = "../../../resources/aws/vpc"
  vpc_name_tag = var.stack_name
  cidr_block   = var.cidr_block
}

module "vpc_dhcp_options" {
  source                    = "../../../resources/aws/network/dhcp_options"
  domain_name               = var.region == "us-east-1" ? "ec2.internal" : "${var.region}.compute.internal"
  vpc_dhcp_options_name_tag = var.stack_name
}

module "vpc_dhcp_option_associations" {
  source              = "../../../resources/aws/network/dhcp_options_associations"
  vpc_id              = module.vpc.vpc_id
  vpc_dhcp_options_id = module.vpc_dhcp_options.vpc_dhcp_options_id
}

/*
    For Scale deployment, we need only 1 internet gateway and that will be
    attached to route table of public subnet for any given number of AZ's.
*/
module "internet_gw" {
  source                    = "../../../resources/aws/network/internet_gw"
  vpc_id                    = module.vpc.vpc_id
  internet_gateway_name_tag = var.stack_name
}

/*
    For Scale deployment, we need 1 public subnet per provided AZ.
*/
module "public_subnet" {
  source          = "../../../resources/aws/network/subnet"
  vpc_id          = module.vpc.vpc_id
  total_subnets   = length(var.availability_zones)
  subnets_cidr    = var.public_subnets_cidr
  avail_zones     = var.availability_zones
  subnet_name_tag = "Public-${var.stack_name}"
}

/*
    For Scale deployment, we need only 1 public route table for any given
    number of AZ's.
*/
module "public_route_table" {
  source               = "../../../resources/aws/network/route_table"
  total_rt             = 1
  vpc_id               = module.vpc.vpc_id
  route_table_name_tag = "Public-${var.stack_name}"
}

/*
    For Scale deployment, we need only internet gateway attachment to
    public route table.
*/
module "public_route" {
  source          = "../../../resources/aws/network/route"
  total_routes    = 1
  route_table_id  = [module.public_route_table.table_id[0]]
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = [module.internet_gw.internet_gw_id]
}

/*
    For Scale deployment, we need to associate all public subnets to one route table
    for any given number of AZ's.
*/
module "public_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  total_associations = length(var.availability_zones)
  subnet_id          = module.public_subnet.subnet_id
  route_table_id     = module.public_route_table.table_id
}



/*
    For Scale deployment, we need 1 EIP per provided AZ.
*/
module "eip" {
  source     = "../../../resources/aws/network/eip"
  total_eips = length(var.availability_zones)
}

/*
    For Scale deployment, we need public subnet id registred to NAT gateway.
*/
module "nat_gateway" {
  source           = "../../../resources/aws/network/nat_gw"
  total_nat_gws    = length(var.availability_zones)
  eip_id           = module.eip.eip_id
  target_subnet_id = module.public_subnet.subnet_id
  nat_gw_name_tag  = "NAT-${var.stack_name}"
}

/*
    For Scale deployment, we need s3 vpc endpoint.
*/
module "vpc_endpoint" {
  source              = "../../../resources/aws/network/vpc_endpoint"
  total_vpc_endpoints = length(var.availability_zones)
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.s3"
}

/*
    For Scale deployment, we need s3 vpc end point association with
    all private route tables.
*/
module "vpc_endpoint_association" {
  source                  = "../../../resources/aws/network/vpc_endpoint_association"
  total_vpce_associations = length(var.availability_zones)
  route_table_id          = module.private_route_table.*.table_id
  vpce_id                 = module.vpc_endpoint.*.vpce_id
}

/*
    For Scale deployment, we need 1 private subnet per provided AZ.
*/
module "private_subnet" {
  source          = "../../../resources/aws/network/subnet"
  total_subnets   = length(var.availability_zones)
  vpc_id          = module.vpc.vpc_id
  subnets_cidr    = var.private_subnets_cidr
  avail_zones     = var.availability_zones
  subnet_name_tag = "Private-${var.stack_name}"
}

/*
    For Scale deployment, we need private route tables equal to number of
    provided AZ's.
*/
module "private_route_table" {
  source               = "../../../resources/aws/network/route_table"
  total_rt             = length(var.availability_zones)
  vpc_id               = module.vpc.vpc_id
  route_table_name_tag = "Private-${var.stack_name}"
}

/*
    For Scale deployment, we need NAT gateways attached to all private routes.
*/

module "private_route" {
  source          = "../../../resources/aws/network/route"
  total_routes    = length(var.availability_zones)
  route_table_id  = module.private_route_table.table_id
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = module.nat_gateway.nat_gw_id
}

/*
    For Scale deployment, we need to associate each private subnet to one
    private route table.
*/
module "private_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  total_associations = length(var.availability_zones)
  subnet_id          = module.private_subnet.subnet_id
  route_table_id     = module.private_route_table.table_id
}
