
/*
  Creates Application Security Group.
*/

variable "resource_prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "turn_on" {}

# Creates application security group.
resource "azurerm_application_security_group" "itself" {
  count               = tobool(var.turn_on) == true ? 1 : 0
  name                = var.resource_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "asg_id" {
  value = try(azurerm_application_security_group.itself[0].id, null)
}
