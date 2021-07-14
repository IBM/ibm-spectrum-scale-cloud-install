/*
    This nested module creates;
    1. Public ip
    2. Bastion NSG, rules
    3. Associates Bastion to Public subnet

    Note: Azure bastion cannot be treated as Jump Host, since one cannot do SSH
          via local machine. It can only accessed via Azure portal.
*/

module "bastion_network_security_group" {
  source              = "../../../resources/azure/security/network_security_group"
  security_group_name = format("%s-bastion-sg", var.resource_prefix)
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
}

module "bastion_security_rule" {
  source                      = "../../../resources/azure/security/network_security_group_rule"
  total_rules                 = 10
  rule_names                  = ["AllowHttpsInBound", "AllowGatewayManagerInBound", "AllowLoadBalancerInBound", "AllowBastionHostCommunicationInBound", "DenyAllInBound", "AllowSshRdpOutBound", "AllowAzureCloudCommunicationOutBound", "AllowBastionHostCommunicationOutBound", "AllowGetSessionInformationOutBound", "DenyAllOutBound"]
  protocol                    = ["Tcp", "Tcp", "Tcp", "*", "*", "Tcp", "Tcp", "*", "*", "*"]
  source_port_range           = ["*", "*", "*", "*", "*", "*", "*", "*", "*", "*"]
  source_address_prefix       = ["Internet", "GatewayManager", "AzureLoadBalancer", "VirtualNetwork", "*", "*", "*", "VirtualNetwork", "Internet", "*"]
  destination_port_range      = ["443", "443", "443", "5701-8080", "*", "22-3389", "443", "5701-8080", "80-443", "*"]
  destination_address_prefix  = ["*", "*", "*", "VirtualNetwork", "*", "VirtualNetwork", "AzureCloud", "VirtualNetwork", "*"]
  access                      = ["Allow", "Allow", "Allow", "Allow", "Deny", "Allow", "Allow", "Allow", "Allow", "Deny"]
  priority                    = ["100", "110", "120", "130", "1000", "100", "110", "120", "130", "1000"]
  direction                   = ["Inbound", "Inbound", "Inbound", "Inbound", "Inbound", "Outbound", "Outbound", "Outbound", "Outbound", "Outbound"]
  network_security_group_name = module.bastion_network_security_group.sec_group_name
  resource_group_name         = var.resource_group_name
}

module "associate_bastion_nsg_wth_subnet" {
  source                    = "../../../resources/azure/security/network_security_group_association"
  subnet_id                 = var.vnet_public_subnet_id
  network_security_group_id = module.bastion_network_security_group.sec_group_id
}

module "bastion_public_ip" {
  source              = "../../../resources/azure/network/public_ip"
  public_ip_name      = format("%s-public-ip", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vnet_location
}

module "bastion_host" {
  source              = "../../../resources/azure/compute/bastion_host"
  bastion_host_name   = format("%s-bastion", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vnet_location
  subnet_id           = var.vnet_public_subnet_id
  public_ip           = module.bastion_public_ip.id
}
