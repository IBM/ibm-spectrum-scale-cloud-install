/*
    For Scale deployment, we need 1 VNet (creates a new one).

    Azure VNet Blueprint;
    1.  Resource group
    2.  DNS options
    3.  VNet
    4.  Private subnet
    5.  Bastion Public subnet
*/

module "create_resource_group" {
    source                 = "../../../resources/azure/resource_group"
    location               = var.location
    resource_group_name    = var.resource_group_name
}

module "create_private_dns_zone" {
    source              = "../../../resources/azure/network/private_dns_zone"
    dns_domain_name     = "${var.location}.${var.private_dns_domain_name}"
    resource_group_name = module.create_resource_group.resource_group_name
}

module "create_new_vnet" {
    source                 = "../../../resources/azure/vnet"
    location               = module.create_resource_group.resource_location
    resource_group_name    = module.create_resource_group.resource_group_name
    vnet_address_space     = var.vnet_address_space
    vnet_name              = var.vnet_name
}

module "create_zone_vnet_link" {
    source                = "../../../resources/azure/network/private_dns_zone_vnet_link"
    private_dns_zone_name = module.create_private_dns_zone.private_dns_zone_name
    resource_group_name   = module.create_resource_group.resource_group_name
    vnet_id               = module.create_new_vnet.vnet_id
    zone_vnet_link_name   = var.zone_vnet_link_name
}

module "create_private_subnet" {
    source                 = "../../../resources/azure/network/subnet"
    resource_group_name    = module.create_resource_group.resource_group_name
    subnet_name            = var.private_subnet_name
    subnet_address_prefix  = var.private_subnet_address_prefix
    vnet_name              = module.create_new_vnet.vnet_name
}

module "create_bastion_public_subnet" {
    source                 = "../../../resources/azure/network/subnet"
    resource_group_name    = module.create_resource_group.resource_group_name
    subnet_name            = var.bastion_subnet_name
    subnet_address_prefix  = var.public_subnet_address_prefix
    vnet_name              = module.create_new_vnet.vnet_name
}
