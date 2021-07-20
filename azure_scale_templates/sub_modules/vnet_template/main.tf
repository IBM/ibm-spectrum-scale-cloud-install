/*
    IBM Spectrum scale cloud deployment requires 1 VNET with below resources.

    1. Resource group
    2. VNET
    3. DNS (seperate zone for compute and storage)
    4. PublicSubnet {1, 2 ..3}
    5. NAT {1, 2..3} EIP
    6. PrivateSubnet {1, 2 ..3}
    7. NAT gateway attachment
    8. VPC s3 endpoint
*/

module "resource_group" {
  source              = "../../../resources/azure/resource_group"
  location            = var.vnet_location
  resource_group_name = format("%s-rg", var.resource_group_name)
}

module "vnet" {
  source              = "../../../resources/azure/network/vnet"
  vnet_name           = format("%s-vnet", var.resource_prefix)
  vnet_location       = var.vnet_location
  resource_group_name = module.resource_group.resource_group_name
  vnet_address_space  = var.vnet_address_space
  vnet_tags           = var.vnet_tags
}

module "storage_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = true
  dns_domain_name     = format("%s.%s", var.vnet_location, var.vnet_storage_cluster_dns_domain)
  resource_group_name = module.resource_group.resource_group_name
}

module "link_storage_dns_zone_vnet" {
  source                = "../../../resources/azure/network/private_dns_zone_vnet_link"
  turn_on               = true
  private_dns_zone_name = module.storage_private_dns_zone.private_dns_zone_name
  resource_group_name   = module.resource_group.resource_group_name
  vnet_id               = module.vnet.vnet_id
  vnet_zone_link_name   = format("%s-strg-link", var.resource_group_name)
}

module "compute_private_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = tobool(var.vnet_create_separate_subnets) == true ? true : false
  dns_domain_name     = format("%s.%s", var.vnet_location, var.vnet_compute_cluster_dns_domain)
  resource_group_name = module.resource_group.resource_group_name
}

module "link_compute_dns_zone_vnet" {
  source                = "../../../resources/azure/network/private_dns_zone_vnet_link"
  turn_on               = tobool(var.vnet_create_separate_subnets) == true ? true : false
  private_dns_zone_name = module.compute_private_dns_zone.private_dns_zone_name
  resource_group_name   = module.resource_group.resource_group_name
  vnet_id               = module.vnet.vnet_id
  vnet_zone_link_name   = format("%s-comp-link", var.resource_group_name)
}

module "create_subnet" {
  source              = "../../../resources/azure/network/subnet"
  total_subnets       = tobool(var.vnet_create_separate_subnets) == true ? 3 : 2
  resource_group_name = module.resource_group.resource_group_name
  subnet_name         = tobool(var.vnet_create_separate_subnets) == true ? ["AzureBastionSubnet", format("%s-strg-snet", var.resource_prefix), format("%s-comp-snet", var.resource_prefix)] : ["AzureBastionSubnet", format("%s-strg-snet", var.resource_prefix)]
  address_prefixes    = concat(var.vnet_public_subnets_address_space, var.vnet_storage_cluster_private_subnets_address_space, var.vnet_compute_cluster_private_subnets_address_space)
  vnet_name           = module.vnet.vnet_name
}
