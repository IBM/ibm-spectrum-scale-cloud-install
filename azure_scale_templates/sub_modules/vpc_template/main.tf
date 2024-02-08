/*
    Creates VNET for IBM storage scale cloud deployment with below resources.

    1. Resource group
    2. Vnet
    3. PublicSubnet
    4. NAT GW with Public IP
    5. Storage and compute PrivateSubnets
*/

locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets_cidr_blocks != null && var.vpc_compute_cluster_private_subnets_cidr_blocks == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets_cidr_blocks == null && var.vpc_compute_cluster_private_subnets_cidr_blocks != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets_cidr_blocks != null && var.vpc_compute_cluster_private_subnets_cidr_blocks != null) ? "combined" : "none"
  )
}

# Create resource group
module "resource_group" {
  count               = var.create_resouce_group != null ? 1 : 0
  source              = "../../../resources/azure/resource_group"
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Create virtual network
module "vnet" {
  source              = "../../../resources/azure/network/vpc"
  vnet_name           = format("%s-vpc", var.resource_prefix)
  vnet_location       = var.vpc_region
  resource_group_name = var.resource_group_name
  vnet_address_space  = [var.vpc_cidr_block]
  vnet_tags           = var.vpc_tags
}

# Public subnet for deploying bastion host
module "public_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = var.vpc_public_subnets_cidr_blocks != null ? true : false
  resource_group_name = var.resource_group_name
  subnet_name         = format("%s-public", var.resource_prefix)
  address_prefixes    = var.vpc_public_subnets_cidr_blocks
  vnet_name           = module.vnet.vnet_name
}

# Create public Ip for nat gateway
module "public_ip" {
  source              = "../../../resources/azure/network/public_ip"
  public_ip_name      = format("%s-snet-pubip", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
}

# Create nat gateway
module "nat_gateway" {
  source              = "../../../resources/azure/network/nat_gateway"
  name                = format("%s-ngw", var.resource_prefix)
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Associate public ip to nat gateway
module "nat_gw_public_pip_association" {
  source               = "../../../resources/azure/network/nat_gw_publicip_association"
  public_ip_address_id = module.public_ip.id
  nat_gateway_id       = module.nat_gateway.nat_gateway_id
}

# Create storage private subnet
module "vnet_strg_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  subnet_name         = format("%s-strg-pvt", var.resource_prefix)
  resource_group_name = var.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = var.vpc_storage_cluster_private_subnets_cidr_blocks
}

# Associate nat gateway to storage subnet
module "nat_gw_strg_private_snet_association" {
  source         = "../../../resources/azure/network/nat_gw_subnet_association"
  subnet_id      = module.vnet_strg_private_subnet.subnet_id
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

# Create compute private subnet
module "vnet_comp_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (local.cluster_type == "compute" || local.cluster_type == "combined") == true ? true : false
  subnet_name         = format("%s-comp-pvt", var.resource_prefix)
  resource_group_name = var.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = var.vpc_compute_cluster_private_subnets_cidr_blocks
}

# Associate nat gateway to compute subnet
module "nat_gw_comp_private_snet_association" {
  source         = "../../../resources/azure/network/nat_gw_subnet_association"
  subnet_id      = module.vnet_comp_private_subnet.subnet_id
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

# Public subnet for Azure Fully Managed Bastion service
module "public_subnet_bastion_service" {
  count               = var.vpc_bastion_service_subnets_cidr_blocks != null ? length(vpc_bastion_service_subnets_cidr_blocks) : 0
  source              = "../../../resources/azure/network/subnet_bastion"
  resource_group_name = var.resource_group_name
  address_prefixes    = var.jumphost_subnets_cidr_block
  vnet_name           = var.vpc_ref
}