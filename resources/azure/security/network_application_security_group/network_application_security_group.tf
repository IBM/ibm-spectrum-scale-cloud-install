
/*
  Creates Application Security Group.
*/

variable "resource_prefix" {}
variable "location" {}
variable "resource_group_name" {}

# Creates application security group.
resource "azurerm_application_security_group" "itself" {
  name                = var.resource_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "asg_id" {
  value = azurerm_application_security_group.itself.id
}