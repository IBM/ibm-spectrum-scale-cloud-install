/*
    IBM Spectrum scale cloud deployment requires 1 VPC with below resources.

    1. Resource group
    2. VPC
    3. DNS (seperate zone for compute and storage)
    4. PublicSubnet
    5. NAT GW with Public IP
    6. PrivateSubnet.
    8. Link DNS zone with VPC.
*/

module "resource_group" {
  source              = "../../../resources/azure/resource_group"
  location            = var.vpc_location
  resource_group_name = format("%s-rg", var.resource_prefix)
}

module "vpc" {
  source              = "../../../resources/azure/network/vpc"
  vpc_name            = format("%s-vpc", var.resource_prefix)
  vpc_location        = var.vpc_location
  resource_group_name = module.resource_group.resource_group_name
  vpc_address_space   = var.vpc_address_space
  vpc_tags            = var.vpc_tags

  depends_on = [
    module.resource_group
  ]
}

module "public_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = var.vpc_public_subnet_address_spaces != null ? true : false
  resource_group_name = module.resource_group.resource_group_name
  subnet_name         = "AzureBastionSubnet"
  address_prefixes    = var.vpc_public_subnet_address_spaces
  vpc_name            = module.vpc.vpc_name

  depends_on = [
    module.resource_group,
    module.vpc
  ]
}

module "public_ip" {
  source              = "../../../resources/azure/network/public_ip"
  public_ip_name      = format("%s-snet-pubip", var.resource_prefix)
  resource_group_name = module.resource_group.resource_group_name
  location            = var.vpc_location

  depends_on = [
    module.resource_group
  ]
}

module "nat_gateway" {
  source              = "../../../resources/azure/network/nat_gateway"
  name                = format("%s-ngw", var.resource_prefix)
  location            = var.vpc_location
  resource_group_name = module.resource_group.resource_group_name

  depends_on = [
    module.resource_group
  ]
}

module "nat_gw_public_snet_association" {
  source         = "../../../resources/azure/network/nat_gw_subnet_association"
  subnet_id      = module.public_subnet.sub_id[0]
  nat_gateway_id = module.nat_gateway.nat_gateway_id

  depends_on = [
    module.public_subnet,
    module.nat_gateway
  ]
}

module "vpc_strg_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  subnet_name         = format("%s-strg-priv-snet", var.resource_prefix)
  resource_group_name = module.resource_group.resource_group_name
  vpc_name            = module.vpc.vpc_name
  address_prefixes    = var.vpc_strg_priv_subnet_address_spaces

  depends_on = [
    module.resource_group,
    module.vpc
  ]
}

module "vpc_comp_private_subnet" {
  source              = "../../../resources/azure/network/subnet"
  turn_on             = (local.cluster_type == "compute" || local.cluster_type == "combined") == true ? true : false
  subnet_name         = format("%s-comp-priv-snet", var.resource_prefix)
  resource_group_name = module.resource_group.resource_group_name
  vpc_name            = module.vpc.vpc_name
  address_prefixes    = var.vpc_comp_priv_subnet_address_spaces

  depends_on = [
    module.resource_group,
    module.vpc
  ]
}

# TODO:
# [ ] 1. Create Private DNS Zone each for strg and comp.
# [ ] 2. Create Virtual Network Links for strg and comp.
# [ ] 3. Create Storage account.
# [ ] 4. Create Storage Account Private Endpoint.
# [ ] 5. Create DNS A record.

module "strg_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  dns_domain_name     = format("%s.%s", var.vpc_location, var.strg_dns_domain)
  resource_group_name = module.resource_group.resource_group_name

  depends_on = [
    module.resource_group,
  ]
}

module "comp_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = (local.cluster_type == "compute" || local.cluster_type == "combined") == true ? true : false
  dns_domain_name     = format("%s.%s", var.vpc_location, var.comp_dns_domain)
  resource_group_name = module.resource_group.resource_group_name

  depends_on = [
    module.resource_group,
  ]
}

module "link_storage_dns_zone_vpc" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  private_dns_zone_name = module.strg_private_dns_zone.private_dns_zone_name
  resource_group_name   = module.resource_group.resource_group_name
  vpc_id                = module.vpc.vpc_id
  vpc_zone_link_name    = format("%s-strg-link", var.resource_prefix)

  depends_on = [
    module.resource_group,
    module.vpc,
    module.strg_private_dns_zone
  ]
}

module "link_compute_dns_zone_vpc" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = (local.cluster_type == "storage" || local.cluster_type == "combined") == true ? true : false
  private_dns_zone_name = module.comp_private_dns_zone.private_dns_zone_name
  resource_group_name   = module.resource_group.resource_group_name
  vpc_id                = module.vpc.vpc_id
  vpc_zone_link_name    = format("%s-comp-link", var.resource_prefix)

  depends_on = [
    module.resource_group,
    module.vpc,
    module.comp_private_dns_zone
  ]
}

module "create_storage_account" {
  source              = "../../../resources/azure/storage/storage_account"
  name                = var.storage_account_name
  location            = var.vpc_location
  resource_group_name = module.resource_group.resource_group_name
}

module "strg_private_endpoint" {
  source                         = "../../../resources/azure/network/endpoint"
  name                           = format("%s-endpoint", var.resource_prefix)
  location                       = var.vpc_location
  resource_prefix                = var.resource_prefix
  resource_group_name            = module.resource_group.resource_group_name
  subnet_id                      = module.vpc_strg_private_subnet.sub_id[0]
  private_connection_resource_id = module.create_storage_account.storage_account_id
}
