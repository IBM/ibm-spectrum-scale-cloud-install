/*
    Manages a bastion network security group.
*/

variable "security_group_name" {}
variable "location" {}
variable "resource_group_name" {}

# tfsec:ignore:azure-network-no-public-egress
resource "azurerm_network_security_group" "itself" {
  name                = var.security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "AllowHttpsInBound"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "AllowGatewayManagerInBound"
    priority                   = 110
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "AllowLoadBalancerInBound"
    priority                   = 120
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "AllowBastionHostCommunicationInBound"
    priority                   = 130
    access                     = "Allow"
    protocol                   = "*"
    direction                  = "Inbound"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_range     = "5701-8080"
  }
  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 1000
    access                     = "Deny"
    protocol                   = "*"
    direction                  = "Inbound"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "AllowSshRdpOutBound"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_range     = "22-3389"
  }
  security_rule {
    name                       = "AllowSshRdpOutBound"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_range     = "22-3389"
  }
  security_rule {
    name                       = "AllowAzureCloudCommunicationOutBound"
    priority                   = 110
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    source_port_range          = "*"
    destination_port_range     = "443"
  }
  security_rule {
    name                       = "AllowBastionHostCommunicationOutBound"
    priority                   = 120
    access                     = "Allow"
    protocol                   = "*"
    direction                  = "Outbound"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_range     = "5701-8080"
  }
  security_rule {
    name                       = "AllowGetSessionInformationOutBound"
    priority                   = 130
    access                     = "Allow"
    protocol                   = "*"
    direction                  = "Outbound"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "80-443"
  }
  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 1000
    access                     = "Deny"
    protocol                   = "*"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
}

output "sec_group_name" {
  value = azurerm_network_security_group.itself.name
}

output "sec_group_id" {
  value = azurerm_network_security_group.itself.id
}
