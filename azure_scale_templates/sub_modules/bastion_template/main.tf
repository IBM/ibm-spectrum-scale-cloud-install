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

# Create bastion ASG
module "bastion_cluster_asg" {
  source              = "../../../resources/azure/security/network_application_security_group"
  resource_prefix     = "${var.resource_prefix}-bastion"
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Add tcp inbound security rule for bastion
#tfsec:ignore:azure-network-ssh-blocked-from-internet
#tfsec:ignore:azure-network-no-public-ingress
module "bastion_tcp_inbound_security_rule" {
  source                      = "../../../resources/azure/security/network_security_group_rule"
  total_rules                 = length(local.tcp_port_allow_bastion)
  rule_names_prefix           = "${var.resource_prefix}-allow-ssh"
  direction                   = ["Inbound"]
  access                      = ["Allow"]
  protocol                    = [for i in range(length(local.tcp_port_allow_bastion)) : "Tcp"]
  source_port_range           = ["*"]
  destination_port_range      = local.tcp_port_allow_bastion
  priority                    = [for i in range(length(local.tcp_port_allow_bastion)) : format("%s", i + 100)]
  source_address_prefix       = var.remote_cidr_blocks
  destination_address_prefix  = ["*"]
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

# Azure Fully Managed Bastion service
module "azure_bastion_service" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/compute/bastion_host"
  bastion_host_name   = format("%s-bastion", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
  vpc_ref             = var.vpc_ref
  resource_prefix     = var.resource_prefix
}

# IBM Storage Scale managed jump host deployment with autoscaling group
module "bastion_autoscaling_group" {
  count                   = var.vpc_auto_scaling_group_subnets != null ? length(var.vpc_auto_scaling_group_subnets) : 0
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
  login_username          = var.bastion_ssh_user_name
  os_storage_account_type = var.bastion_boot_disk_type
  bastion_key_pair        = var.bastion_key_pair
  os_disk_caching         = var.os_disk_caching
  subnet_id               = var.vpc_auto_scaling_group_subnets[count.index]
  vnet_availability_zones = var.vpc_availability_zones
  bastion_asg_id          = [module.bastion_cluster_asg.asg_id]
  prefix_length           = 28
}
