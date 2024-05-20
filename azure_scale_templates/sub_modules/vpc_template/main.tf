/*
    Creates VNET for IBM storage scale cloud deployment with below resources.

    1. Resource group
    2. Vnet
    3. PublicSubnet
    4. NAT GW with Public IP
    5. Storage and compute PrivateSubnets
*/

# Create resource group
module "resource_group" {
  count               = var.create_resource_group ? 1 : 0
  source              = "../../../resources/azure/resource_group"
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Create virtual network
module "vnet" {
  source              = "../../../resources/azure/network/vpc"
  vnet_name           = var.resource_prefix
  vnet_location       = var.vpc_region
  resource_group_name = var.resource_group_name
  vnet_address_space  = [var.vpc_cidr_block]
  vnet_tags           = var.vpc_tags
}

# One Public subnet (as subnet is global to all zones)
module "public_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = var.vpc_public_subnets_cidr_blocks != null ? true : false
  resource_group_name = var.resource_group_name
  subnet_name_prefix  = format("%s-%s", var.resource_prefix, "public")
  address_prefixes    = var.vpc_public_subnets_cidr_blocks
  vnet_name           = module.vnet.vnet_name
  service_endpoints   = []
}

# Create nat gateway public ip for compute subnet
module "compute_public_ip" {
  source              = "../../../resources/azure/network/public_ip"
  turn_on             = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  public_ip_name      = format("%s-comp-nat-pubip", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
}

# Create a NAT associated to compute subnet
# NAT is zone specific resource, whereas subnets are global
module "compute_nat_gateway" {
  source              = "../../../resources/azure/network/nat_gateway"
  turn_on             = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  name                = format("%s-comp-pvt-%s", var.resource_prefix, "nat")
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Associate public ip to compute nat gateway
module "compute_nat_public_pip_association" {
  source               = "../../../resources/azure/network/nat_gw_publicip_association"
  turn_on             = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  public_ip_address_id = module.compute_public_ip.id
  nat_gateway_id       = module.compute_nat_gateway.nat_gateway_id
}

# One compute private subnet
module "compute_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  resource_group_name = var.resource_group_name
  subnet_name_prefix  = format("%s-%s", var.resource_prefix, "comp-pvt")
  address_prefixes    = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vnet_name           = module.vnet.vnet_name
  service_endpoints   = ["Microsoft.Storage"]
}

# Associate nat gateway to compute subnet
module "nat_comp_private_snet_association" {
  source         = "../../../resources/azure/network/nat_gw_subnet_association"
  turn_on        = (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  subnet_id      = module.compute_private_subnet.subnet_id
  nat_gateway_id = module.compute_nat_gateway.nat_gateway_id
}

# Create nat gateway public ip for storage subnet
module "storage_public_ip" {
  source              = "../../../resources/azure/network/public_ip"
  turn_on             = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  public_ip_name      = format("%s-strg-nat-pubip", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
}

# Create a NAT associated to storage subnet
module "storage_nat_gateway" {
  source              = "../../../resources/azure/network/nat_gateway"
  turn_on             = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  name                = format("%s-strg-pvt-%s", var.resource_prefix, "nat")
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Associate public ip to storage nat gateway
module "strg_nat_public_pip_association" {
  source               = "../../../resources/azure/network/nat_gw_publicip_association"
  turn_on             = ((var.vpc_public_subnets_cidr_blocks != null) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage")) ? true : false
  public_ip_address_id = module.storage_public_ip.id
  nat_gateway_id       = module.storage_nat_gateway.nat_gateway_id
}

# One storage private subnet
module "storage_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  resource_group_name = var.resource_group_name
  subnet_name_prefix  = format("%s-%s", var.resource_prefix, "strg-pvt")
  address_prefixes    = var.vpc_storage_cluster_private_subnets_cidr_blocks
  vnet_name           = module.vnet.vnet_name
  service_endpoints   = ["Microsoft.Storage"]
}

# Associate nat gateway to storage subnet
module "nat_strg_private_snet_association" {
  source         = "../../../resources/azure/network/nat_gw_subnet_association"
  turn_on        = (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  subnet_id      = module.storage_private_subnet.subnet_id
  nat_gateway_id = module.storage_nat_gateway.nat_gateway_id
}

# Public subnet for azure fully managed Bastion service
module "public_subnet_bastion_service" {
  count               = var.vpc_bastion_service_subnets_cidr_blocks != null ? length(var.vpc_bastion_service_subnets_cidr_blocks) : 0
  source              = "../../../resources/azure/network/subnet_bastion"
  resource_group_name = var.resource_group_name
  address_prefixes    = var.vpc_bastion_service_subnets_cidr_blocks
  vnet_name           = module.vnet.vnet_name
}

# Create Network Security Group (NSG) for VNet
module "vnet_network_security_group" {
  source              = "../../../resources/azure/security/network_security_group"
  security_group_name = format("%s-nsg", var.resource_prefix)
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Associate NSG to all the subnets of the VNet
module "associate_nsg_wth_subnet" {
  source                    = "../../../resources/azure/security/network_security_group_association"
  subnet_ids                = concat(module.public_subnet.subnet_id, module.storage_private_subnet.subnet_id, module.compute_private_subnet.subnet_id)
  network_security_group_id = module.vnet_network_security_group.sec_group_id
}
