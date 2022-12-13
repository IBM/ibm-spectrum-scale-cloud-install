/*
    IBM Spectrum scale cloud deployment requires 1 vnet with below resources.

    1. Resource group
    2. vnet
    3. DNS (seperate zone for compute and storage)
    4. PublicSubnet
    5. NAT GW with Public IP
    6. PrivateSubnet.
    7. Link DNS zone with vnet.
*/

module "resource_group" {
  source              = "../../../resources/azure/resource_group"
  location            = var.vnet_location
  resource_group_name = format("%s-rg", var.resource_prefix)
}

module "vnet" {
  source              = "../../../resources/azure/network/vpc"
  vnet_name           = format("%s-vnet", var.resource_prefix)
  vnet_location       = var.vnet_location
  resource_group_name = module.resource_group.resource_group_name
  vnet_address_space  = var.vnet_address_space
  vnet_tags           = var.vnet_tags
}

module "public_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = var.vnet_public_subnet_address_spaces != null ? true : false
  resource_group_name = module.resource_group.resource_group_name
  subnet_name         = "AzureBastionSubnet"
  address_prefixes    = var.vnet_public_subnet_address_spaces
  vnet_name           = module.vnet.vnet_name
}

module "public_ip" {
  source              = "../../../resources/azure/network/public_ip"
  public_ip_name      = format("%s-snet-pubip", var.resource_prefix)
  resource_group_name = module.resource_group.resource_group_name
  location            = var.vnet_location
}

module "nat_gateway" {
  source              = "../../../resources/azure/network/nat_gateway"
  name                = format("%s-ngw", var.resource_prefix)
  location            = var.vnet_location
  resource_group_name = module.resource_group.resource_group_name
}

module "nat_gw_public_pip_association" {
  source               = "../../../resources/azure/network/nat_gw_publicip_association"
  public_ip_address_id = module.public_ip.id
  nat_gateway_id       = module.nat_gateway.nat_gateway_id
}

module "nat_gw_public_snet_association" {
  source         = "../../../resources/azure/network/nat_gw_subnet_association"
  subnet_id      = module.public_subnet.sub_id[0]
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

module "vnet_strg_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  subnet_name         = format("%s-strg-priv-snet", var.resource_prefix)
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = var.vnet_strg_priv_subnet_address_spaces
}

module "vnet_comp_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (local.cluster_type == "compute" || local.cluster_type == "combined") == true ? true : false
  subnet_name         = format("%s-comp-priv-snet", var.resource_prefix)
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = var.vnet_comp_priv_subnet_address_spaces
}

module "storage_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  dns_domain_name     = format("%s.%s", var.vnet_location, var.strg_dns_domain)
  resource_group_name = module.resource_group.resource_group_name
}

module "compute_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = (local.cluster_type == "compute" || local.cluster_type == "combined") == true ? true : false
  dns_domain_name     = format("%s.%s", var.vnet_location, var.comp_dns_domain)
  resource_group_name = module.resource_group.resource_group_name
}

module "link_storage_dns_zone_vnet" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  private_dns_zone_name = module.storage_private_dns_zone.private_dns_zone_name
  resource_group_name   = module.resource_group.resource_group_name
  vnet_id               = module.vnet.vnet_id
  vnet_zone_link_name   = format("%s-strg-link", var.resource_prefix)
}

module "link_compute_dns_zone_vnet" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  private_dns_zone_name = module.compute_private_dns_zone.private_dns_zone_name
  resource_group_name   = module.resource_group.resource_group_name
  vnet_id               = module.vnet.vnet_id
  vnet_zone_link_name   = format("%s-comp-link", var.resource_prefix)
}
