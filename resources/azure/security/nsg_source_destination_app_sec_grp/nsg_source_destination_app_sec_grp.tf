/*
    Manages a network security rule for application security group(ASG).
*/

variable "access" {}
variable "description" {}
variable "destination_application_security_group_ids" {}
variable "destination_port_range" {}
variable "direction" {}
variable "network_security_group_name" {}
variable "priority" {}
variable "protocol" {}
variable "resource_group_name" {}
variable "rule_names_prefix" {}
variable "source_application_security_group_ids" {}
variable "source_port_range" {}
variable "total_rules" {}

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
  description                                = var.description
}

output "sec_rule_id" {
  value = azurerm_network_security_rule.itself[*].id
}
