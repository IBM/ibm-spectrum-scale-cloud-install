/*
    Deploys Bastion/Jump Host for IBM Storage Scale cluster.

    Azure offers a Fully Managed RDP/SSH bastion service, which can be provisioned via azure_bastion_service variable.
*/

locals {
  tcp_port_allow_bastion = ["22"]
}

# Create NSG for bastion
module "bastion_network_security_group" {
  source              = "../../../resources/azure/security/network_security_group"
  security_group_name = format("%s-bastion", var.resource_prefix)
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Add deny security rule for bastion
module "bastion_deny_inbound_security_rule" {
  source                      = "../../../resources/azure/security/network_security_group_rule"
  total_rules                 = 1
  rule_names                  = ["${var.resource_prefix}-DenyAllInBound"]
  direction                   = ["Inbound"]
  access                      = ["Deny"]
  protocol                    = ["*"]
  source_port_range           = ["*"]
  destination_port_range      = ["*"]
  priority                    = ["1000"]
  source_address_prefix       = ["*"]
  destination_address_prefix  = ["*"]
  network_security_group_name = module.bastion_network_security_group.sec_group_name
  resource_group_name         = var.resource_group_name
}

# Add tcp inbound security rule for bastion
module "bastion_tcp_inbound_security_rule" {
  source                      = "../../../resources/azure/security/network_security_group_rule"
  total_rules                 = length(local.tcp_port_allow_bastion)
  rule_names                  = ["${var.resource_prefix}-allow-ssh"]
  direction                   = ["Inbound"]
  access                      = ["Allow"]
  protocol                    = [for i in range(length(local.tcp_port_allow_bastion)) : "Tcp"]
  source_port_range           = ["*"]
  destination_port_range      = local.tcp_port_allow_bastion
  priority                    = [for i in range(length(local.tcp_port_allow_bastion)) : "${i + 100}"]
  source_address_prefix       = ["*"]
  destination_address_prefix  = var.remote_cidr_blocks
  network_security_group_name = module.bastion_network_security_group.sec_group_name
  resource_group_name         = var.resource_group_name
}

# Associates NSG with public bastion designated subnet
module "associate_bastion_nsg_wth_subnet" {
  count                     = length(var.vpc_auto_scaling_group_subnets)
  source                    = "../../../resources/azure/security/network_security_group_association"
  subnet_id                 = var.vpc_auto_scaling_group_subnets[count.index]
  network_security_group_id = module.bastion_network_security_group.sec_group_id
}

# Public subnet for Azure Fully Managed Bastion service
module "public_subnet_bastion_service" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/network/subnet_bastion"
  resource_group_name = var.resource_group_name
  address_prefixes    = var.vpc_bastion_service_subnets_cidr_blocks
  vnet_name           = var.vpc_ref
}

# Generate public ip for Azure Fully Managed Bastion service
module "bastion_public_ip" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/network/public_ip"
  public_ip_name      = format("%s-public-ip", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
}

# Azure Fully Managed Bastion service
module "azure_bastion_service" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/compute/bastion_host"
  bastion_host_name   = format("%s-bastion", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
  subnet_id           = module.public_subnet_bastion_service[0].subnet_id
  public_ip           = module.bastion_public_ip[0].id
}

# IBM Storage Scale managed jump host deployment with autoscaling group
module "bastion_autoscaling_group" {
  source                  = "../../../resources/azure/asg/asg_scaleset"
  vm_name_prefix          = "${var.resource_prefix}-bastion"
  image_publisher         = var.image_publisher
  image_offer             = var.image_offer
  image_sku               = var.image_sku
  image_version           = var.image_version
  resource_group_name     = var.resource_group_name
  location                = var.vpc_region
  vm_size                 = var.bastion_instance_type
  vm_count                = 1
  login_username          = var.bastion_login_username
  os_storage_account_type = var.bastion_boot_disk_type
  bastion_key_pair        = var.bastion_key_pair
  os_disk_caching         = var.os_disk_caching
  subnet_id               = var.vpc_auto_scaling_group_subnets[0]
}
