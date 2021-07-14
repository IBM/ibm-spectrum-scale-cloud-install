/*
    Manages a network security rule.
*/

variable "total_rules" {}
variable "rule_names" {}
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

resource "azurerm_network_security_rule" "itself" {
  count                       = var.total_rules
  name                        = element(var.rule_names, count.index)
  priority                    = element(var.priority, count.index)
  direction                   = element(var.direction, count.index)
  access                      = element(var.access, count.index)
  protocol                    = element(var.protocol, count.index)
  source_port_range           = element(var.source_port_range, count.index)
  destination_port_range      = element(var.destination_port_range, count.index)
  source_address_prefix       = element(var.source_address_prefix, count.index)
  destination_address_prefix  = element(var.destination_address_prefix, count.index)
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

output "sec_rule_id" {
  value = azurerm_network_security_rule.itself.*.id
}
