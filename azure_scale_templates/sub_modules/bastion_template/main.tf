/*
    Deploys Bastion/Jump Host for IBM Storage Scale cluster.

    Azure offers a Fully Managed RDP/SSH bastion service, which can be provisioned via azure_bastion_service variable.
*/

locals {
  allow_protocol         = ["Tcp", "Icmp"]
  tcp_port_allow_bastion = ["22", "*"]
  nsg_rule_description   = ["Allow SSH traffic from external cidr to bastion instances", "Allow ICMP traffic from external cidr to bastion instances"]
}

# Create bastion/jumphost Application Security Group (ASG)
module "bastion_app_security_grp" {
  source              = "../../../resources/azure/security/application_security_group"
  resource_prefix     = "${var.resource_prefix}-bastion-sec-group"
  location            = var.vpc_region
  resource_group_name = var.resource_group_name
}

# Add tcp inbound security rule for bastion
#tfsec:ignore:azure-network-ssh-blocked-from-internet
#tfsec:ignore:azure-network-no-public-ingress
module "bastion_tcp_inbound_security_rule" {
  source                                     = "../../../resources/azure/security/nsg_destination_app_sec_grp"
  total_rules                                = length(local.tcp_port_allow_bastion)
  rule_names_prefix                          = "${var.resource_prefix}-bastion-allow"
  direction                                  = ["Inbound"]
  access                                     = ["Allow"]
  protocol                                   = local.allow_protocol
  source_port_range                          = ["*"] # The recommended value for source port ranges is * (Any). Port filtering is mainly used with destination port.
  destination_port_range                     = local.tcp_port_allow_bastion
  priority                                   = [for i in range(length(local.tcp_port_allow_bastion)) : format("%s", i + var.nsg_rule_start_index)]
  source_address_prefix                      = var.remote_cidr_blocks
  destination_application_security_group_ids = [module.bastion_app_security_grp.asg_id]
  network_security_group_name                = var.vpc_network_security_group_ref
  resource_group_name                        = var.resource_group_name
  description                                = local.nsg_rule_description
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
  vm_name_prefix          = "${var.resource_prefix}-bastion-${count.index}"
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
  ssh_key_path            = var.bastion_ssh_key_path
  os_disk_caching         = var.os_disk_caching
  subnet_id               = var.vpc_auto_scaling_group_subnets[count.index]
  vnet_availability_zones = var.vpc_availability_zones
  bastion_asg_id          = [module.bastion_app_security_grp.asg_id]
  prefix_length           = 28
}
