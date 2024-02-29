/*
    Manages a network security rule for application security group(ASG).
*/

variable "total_rules" {}
variable "rule_names_prefix" {}
variable "priority" {}
variable "direction" {}
variable "access" {}
variable "protocol" {}
variable "source_port_range" {}
variable "source_application_security_group_ids" {}
variable "destination_port_range" {}
variable "destination_application_security_group_ids" {}
variable "resource_group_name" {}
variable "network_security_group_name" {}

# Creates network security rule
resource "azurerm_network_security_rule" "itself" {
  count                                      = var.total_rules
  name                                       = format("%s-%s%s-%s", var.rule_names_prefix, var.protocol[count.index], var.direction[0], var.destination_port_range[count.index])
  priority                                   = element(var.priority, count.index)
  direction                                  = element(var.direction, count.index)
  access                                     = element(var.access, count.index)
  protocol                                   = element(var.protocol, count.index)
  source_port_range                          = element(var.source_port_range, count.index)
  destination_port_range                     = element(var.destination_port_range, count.index)
  source_application_security_group_ids      = var.source_application_security_group_ids
  destination_application_security_group_ids = var.destination_application_security_group_ids
  resource_group_name                        = var.resource_group_name
  network_security_group_name                = var.network_security_group_name
}

output "sec_rule_id" {
  value = azurerm_network_security_rule.itself.*.id
}
