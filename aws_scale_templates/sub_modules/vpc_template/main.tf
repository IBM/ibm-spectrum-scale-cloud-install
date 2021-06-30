/*
    IBM Spectrum scale cloud deployment requires 1 VPC with below resources.

    1. VPC
    2. Internet Gateway
    3. Route tables (1 rt seperate for each AZ private, 1rt for all AZ public)
    4. PublicSubnet {1, 2 ..3}
    5. NAT {1, 2..3} EIP
    6. PrivateSubnet {1, 2 ..3}
    7. NAT gateway attachment
    8. VPC s3 endpoint
*/

module "vpc" {
  source     = "../../../resources/aws/network/vpc"
  vpc_name   = var.resource_prefix
  cidr_block = var.vpc_cidr_block
  vpc_tags   = var.vpc_tags
}

# Internet gateway will be attached to route table of public subnet for any given number of AZ's.
module "vpc_internet_gw" {
  source   = "../../../resources/aws/network/internet_gw"
  vpc_id   = module.vpc.vpc_id
  vpc_name = var.resource_prefix
  vpc_tags = var.vpc_tags
}

# One public subnet per provided AZ.
module "public_subnet" {
  source       = "../../../resources/aws/network/subnet"
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_public_subnets_cidr_blocks
  avail_zones  = var.vpc_availability_zones
  vpc_name     = format("%s-public", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# One public route table for any given number of AZ's.
module "public_route_table" {
  source   = "../../../resources/aws/network/route_table"
  total_rt = 1
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-public", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# Internet gateway attachment to public route table.
module "public_route" {
  source          = "../../../resources/aws/network/route"
  total_routes    = 1
  route_table_id  = [module.public_route_table.table_id[0]]
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = [module.vpc_internet_gw.internet_gw_id]
  nat_gateway_id  = null
}

# Associate all public subnets to one route table for any given number of AZ's.
module "public_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  total_associations = length(var.vpc_availability_zones)
  subnet_id          = module.public_subnet.subnet_id
  route_table_id     = module.public_route_table.table_id
}

# One EIP per provided AZ.
module "eip" {
  source     = "../../../resources/aws/network/eip"
  total_eips = var.vpc_create_separate_subnets == true ? length(var.vpc_availability_zones) + 1 : length(var.vpc_availability_zones)
}

# Public subnet id registred to NAT gateway.
module "nat_gateway" {
  source           = "../../../resources/aws/network/nat_gw"
  total_nat_gws    = var.vpc_create_separate_subnets == true ? length(var.vpc_availability_zones) + 1 : length(var.vpc_availability_zones)
  eip_id           = module.eip.eip_id
  target_subnet_id = module.public_subnet.subnet_id
  vpc_name         = format("%s-nat", var.resource_prefix)
  vpc_tags         = var.vpc_tags
}

# We need s3 vpc endpoint.
module "vpc_endpoint" {
  source              = "../../../resources/aws/network/vpc_endpoint"
  total_vpc_endpoints = length(var.vpc_availability_zones)
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.vpc_region}.s3"
}

# s3 vpc end point association with all private route tables.
module "vpc_endpoint_association" {
  source                  = "../../../resources/aws/network/vpc_endpoint_association"
  total_vpce_associations = length(var.vpc_availability_zones)
  route_table_id          = module.storage_private_route_table.*.table_id
  vpce_id                 = module.vpc_endpoint.*.vpce_id
}

# One storage private subnet per provided AZ.
module "storage_private_subnet" {
  source       = "../../../resources/aws/network/subnet"
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_storage_cluster_private_subnets_cidr_blocks
  avail_zones  = var.vpc_availability_zones
  vpc_name     = format("%s-strg-pvt", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# One compute private subnet in first AZ element.
module "compute_private_subnet" {
  source       = "../../../resources/aws/network/subnet"
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_compute_cluster_private_subnets_cidr_blocks
  avail_zones  = var.vpc_create_separate_subnets == true ? [var.vpc_availability_zones[0]] : []
  vpc_name     = format("%s-comp-pvt", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# private route tables equal to number of provided AZ's.
module "storage_private_route_table" {
  source   = "../../../resources/aws/network/route_table"
  total_rt = length(var.vpc_availability_zones)
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-strg-pvt", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# Compute private route table will be provisioned in first AZ element.
module "compute_private_route_table" {
  source   = "../../../resources/aws/network/route_table"
  total_rt = var.vpc_create_separate_subnets == true ? 1 : 0
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-comp-pvt", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# NAT gateways attached to all storage private routes.
module "storage_private_route" {
  source          = "../../../resources/aws/network/route"
  total_routes    = length(var.vpc_availability_zones)
  route_table_id  = module.storage_private_route_table.table_id
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = null
  nat_gateway_id  = module.nat_gateway.nat_gw_id
}

# NAT gateways attached to compute private route.
module "compute_private_route" {
  source          = "../../../resources/aws/network/route"
  total_routes    = var.vpc_create_separate_subnets == true ? 1 : 0
  route_table_id  = module.compute_private_route_table.table_id
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = null
  nat_gateway_id  = [element(module.nat_gateway.nat_gw_id, length(var.vpc_availability_zones) - 1)]
}

# Associate each private subnet to one private route table.
module "storage_private_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  total_associations = length(var.vpc_availability_zones)
  subnet_id          = module.storage_private_subnet.subnet_id
  route_table_id     = module.storage_private_route_table.table_id
}

# Associate each private subnet to one private route table.
module "compute_private_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  total_associations = var.vpc_create_separate_subnets == true ? 1 : 0
  subnet_id          = module.compute_private_subnet.subnet_id
  route_table_id     = module.compute_private_route_table.table_id
}
