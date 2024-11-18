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

    Notes:
    - Storage and compute are seperated and would require different subnets.
    - Public subnets are also enabled with vpc s3 endpoint.
*/

module "vpc" {
  source      = "../../../resources/aws/network/vpc"
  turn_on     = true
  vpc_name    = var.resource_prefix
  cidr_block  = var.vpc_cidr_block
  domain_name = var.vpc_region == "us-east-1" ? "ec2.internal" : "${var.vpc_region}.compute.internal"
  vpc_tags    = var.vpc_tags
}

# Internet gateway will be attached to route table of public subnet for any given number of AZ's.
module "vpc_internet_gw" {
  source   = "../../../resources/aws/network/internet_gw"
  turn_on  = var.vpc_public_subnets_cidr_blocks != null ? true : false
  vpc_id   = module.vpc.vpc_id
  vpc_name = var.resource_prefix
  vpc_tags = var.vpc_tags
}

# One public subnet per provided AZ.
module "public_subnet" {
  source       = "../../../resources/aws/network/subnet"
  turn_on      = var.vpc_public_subnets_cidr_blocks != null ? true : false
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_public_subnets_cidr_blocks
  avail_zones  = var.vpc_availability_zones
  vpc_name     = format("%s-public", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# One public route table for any given number of AZ's.
module "public_route_table" {
  source   = "../../../resources/aws/network/route_table"
  turn_on  = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_rt = 1
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-public", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# Internet gateway attachment to public route table.
module "public_route" {
  source          = "../../../resources/aws/network/route"
  turn_on         = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_routes    = 1
  route_table_id  = try([module.public_route_table.table_id[0]], null)
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = [module.vpc_internet_gw.internet_gw_id]
  nat_gateway_id  = null
}

# Associate all public subnets to one route table for any given number of AZ's.
module "public_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  turn_on            = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_associations = length(var.vpc_availability_zones)
  subnet_id          = module.public_subnet.subnet_id
  route_table_id     = module.public_route_table.table_id
}

# One storage EIP per provided AZ.
module "storage_eip" {
  source     = "../../../resources/aws/network/eip"
  turn_on    = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_eips = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? length(var.vpc_availability_zones) : 0
}

# One compute EIP per provided AZ.
module "compute_eip" {
  source     = "../../../resources/aws/network/eip"
  turn_on    = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_eips = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? length(var.vpc_availability_zones) : 0
}

# One protocol EIP per provided AZ.
module "protocol_eip" {
  source     = "../../../resources/aws/network/eip"
  turn_on    = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_eips = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? length(var.vpc_availability_zones) : 0
}

# Storage public subnet id registred to NAT gateway.
module "storage_nat_gateway" {
  source           = "../../../resources/aws/network/nat_gw"
  turn_on          = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_nat_gws    = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? length(var.vpc_availability_zones) : 0
  eip_id           = module.storage_eip.eip_id
  target_subnet_id = module.public_subnet.subnet_id
  vpc_name         = format("%s-strg-nat", var.resource_prefix)
  vpc_tags         = var.vpc_tags
}

# Compute public subnet id registred to NAT gateway.
module "compute_nat_gateway" {
  source           = "../../../resources/aws/network/nat_gw"
  turn_on          = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_nat_gws    = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? length(var.vpc_availability_zones) : 0
  eip_id           = module.compute_eip.eip_id
  target_subnet_id = module.public_subnet.subnet_id
  vpc_name         = format("%s-cmp-nat", var.resource_prefix)
  vpc_tags         = var.vpc_tags
}

# Protocol public subnet id registred to NAT gateway.
module "protocol_nat_gateway" {
  source           = "../../../resources/aws/network/nat_gw"
  turn_on          = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_nat_gws    = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? length(var.vpc_availability_zones) : 0
  eip_id           = module.protocol_eip.eip_id
  target_subnet_id = module.public_subnet.subnet_id
  vpc_name         = format("%s-protocol-nat", var.resource_prefix)
  vpc_tags         = var.vpc_tags
}

# s3 vpc endpoint to be associated with public subnets
module "vpc_public_endpoint" {
  source              = "../../../resources/aws/network/vpc_endpoint"
  turn_on             = true
  total_vpc_endpoints = 1
  resource_prefix     = var.resource_prefix
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.vpc_region}.s3"
}

# s3 vpc end point association with all public route tables.
module "vpc_endpoint_public_association" {
  source                  = "../../../resources/aws/network/vpc_endpoint_association"
  turn_on                 = var.vpc_public_subnets_cidr_blocks != null ? true : false
  total_vpce_associations = 1
  route_table_id          = try(module.public_route_table.table_id, null)
  vpce_id                 = try(module.vpc_public_endpoint.vpce_id, null)
}

# s3 vpc endpoint to be associated with private subnets.
module "vpc_private_endpoint" {
  source              = "../../../resources/aws/network/vpc_endpoint"
  turn_on             = true
  total_vpc_endpoints = length(var.vpc_availability_zones)
  resource_prefix     = var.resource_prefix
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.vpc_region}.s3"
}

# One storage private subnet per provided AZ.
module "storage_private_subnet" {
  source       = "../../../resources/aws/network/subnet"
  turn_on      = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_storage_cluster_private_subnets_cidr_blocks
  avail_zones  = var.vpc_availability_zones
  vpc_name     = format("%s-strg-pvt", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# One compute private subnet per provided AZ.
module "compute_private_subnet" {
  source       = "../../../resources/aws/network/subnet"
  turn_on      = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_compute_cluster_private_subnets_cidr_blocks
  avail_zones  = var.vpc_availability_zones
  vpc_name     = format("%s-comp-pvt", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# One protocol private subnet per provided AZ.
module "protocol_private_subnet" {
  source       = "../../../resources/aws/network/subnet"
  turn_on      = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.vpc_protocol_private_subnets_cidr_blocks != null ? true : false
  vpc_id       = module.vpc.vpc_id
  subnets_cidr = var.vpc_protocol_private_subnets_cidr_blocks
  avail_zones  = var.vpc_availability_zones
  vpc_name     = format("%s-protocol-pvt", var.resource_prefix)
  vpc_tags     = var.vpc_tags
}

# Storage private route tables equal to number of provided AZ's.
module "storage_private_route_table" {
  source   = "../../../resources/aws/network/route_table"
  turn_on  = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_rt = length(var.vpc_availability_zones)
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-strg-pvt", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# Compute private route tables equal to number of provided AZ's.
module "compute_private_route_table" {
  source   = "../../../resources/aws/network/route_table"
  turn_on  = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_rt = length(var.vpc_availability_zones)
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-comp-pvt", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# Protocol private route tables equal to number of provided AZ's.
module "protocol_private_route_table" {
  source   = "../../../resources/aws/network/route_table"
  turn_on  = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_rt = length(var.vpc_availability_zones)
  vpc_id   = module.vpc.vpc_id
  vpc_name = format("%s-protocol-pvt", var.resource_prefix)
  vpc_tags = var.vpc_tags
}

# NAT gateways attached to all storage private routes.
# This is not required in a private only mode
module "storage_private_route" {
  source          = "../../../resources/aws/network/route"
  turn_on         = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  total_routes    = length(var.vpc_availability_zones)
  route_table_id  = module.storage_private_route_table.table_id
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = null
  nat_gateway_id  = module.storage_nat_gateway.nat_gw_id
}

# NAT gateways attached to all compute private routes.
# This is not required in a private only mode
module "compute_private_route" {
  source          = "../../../resources/aws/network/route"
  turn_on         = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  total_routes    = length(var.vpc_availability_zones)
  route_table_id  = module.compute_private_route_table.table_id
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = null
  nat_gateway_id  = module.compute_nat_gateway.nat_gw_id
}

# NAT gateways attached to all protocol private routes.
# This is not required in a private only mode
module "protocol_private_route" {
  source          = "../../../resources/aws/network/route"
  turn_on         = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  total_routes    = length(var.vpc_availability_zones)
  route_table_id  = module.protocol_private_route_table.table_id
  dest_cidr_block = "0.0.0.0/0"
  gateway_id      = null
  nat_gateway_id  = module.protocol_nat_gateway.nat_gw_id
}

# s3 vpc end point association with all storage cluster private route tables.
module "vpc_endpoint_storage_private_association" {
  source                  = "../../../resources/aws/network/vpc_endpoint_association"
  turn_on                 = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_vpce_associations = length(var.vpc_availability_zones)
  route_table_id          = try(module.storage_private_route_table.table_id, null)
  vpce_id                 = try(module.vpc_private_endpoint.vpce_id, null)
}

# s3 vpc end point association with all compute private route tables.
module "vpc_endpoint_compute_private_association" {
  source                  = "../../../resources/aws/network/vpc_endpoint_association"
  turn_on                 = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_vpce_associations = length(var.vpc_availability_zones)
  route_table_id          = module.compute_private_route_table.table_id
  vpce_id                 = module.vpc_private_endpoint.vpce_id
}

# s3 vpc end point association with all protocol private route tables.
module "vpc_endpoint_protocol_private_association" {
  source                  = "../../../resources/aws/network/vpc_endpoint_association"
  turn_on                 = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_vpce_associations = length(var.vpc_availability_zones)
  route_table_id          = module.protocol_private_route_table.table_id
  vpce_id                 = module.vpc_private_endpoint.vpce_id
}

# Associate each storage private subnet to one private route table.
module "storage_private_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  turn_on            = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_associations = length(var.vpc_availability_zones)
  subnet_id          = module.storage_private_subnet.subnet_id
  route_table_id     = module.storage_private_route_table.table_id
}

# Associate each compute private subnet to one private route table.
module "compute_private_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  turn_on            = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  total_associations = length(var.vpc_availability_zones)
  subnet_id          = module.compute_private_subnet.subnet_id
  route_table_id     = module.compute_private_route_table.table_id
}

# Associate each protocol private subnet to one private route table.
module "protocol_private_route_table_association" {
  source             = "../../../resources/aws/network/route_table_association"
  turn_on            = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.vpc_protocol_private_subnets_cidr_blocks != null ? true : false
  total_associations = length(var.vpc_availability_zones)
  subnet_id          = module.protocol_private_subnet.subnet_id
  route_table_id     = module.protocol_private_route_table.table_id
}
