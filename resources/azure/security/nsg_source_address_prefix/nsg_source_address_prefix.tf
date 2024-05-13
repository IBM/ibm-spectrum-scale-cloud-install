/*
    Manages a network security rule for application security group(ASG) with NSG source address prefix
*/

variable "total_rules" {}
variable "rule_names_prefix" {}
variable "priority" {}
variable "direction" {}
variable "access" {}
variable "protocol" {}
variable "source_port_range" {}
variable "source_address_prefix" {}
variable "destination_port_range" {}
variable "destination_address_prefix" {}
variable "resource_group_name" {}
variable "network_security_group_name" {}
variable "description" {}

# Creates network security rule
resource "azurerm_network_security_rule" "itself" {
  count                       = var.total_rules
  name                        = format("%s-%s", var.rule_names_prefix, element(var.direction, count.index))
  priority                    = element(var.priority, count.index)
  direction                   = element(var.direction, count.index)
  access                      = element(var.access, count.index)
  protocol                    = element(var.protocol, count.index)
  source_port_range           = element(var.source_port_range, count.index)
  destination_port_range      = element(var.destination_port_range, count.index)
  source_address_prefix       = var.source_address_prefix
  destination_address_prefix  = var.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
  description                 = var.description
}

output "sec_rule_id" {
  value = azurerm_network_security_rule.itself[*].id
}
