/*
    Create proximity placement group for VM's.
 */

variable "turn_on" {}
variable "proximity_group_name" {}
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_proximity_placement_group" "itself" {
  count               = var.turn_on ? 1 : 0
  name                = var.proximity_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "proximity_group_id" {
  value = try(azurerm_proximity_placement_group.itself[0].id, null)
}
