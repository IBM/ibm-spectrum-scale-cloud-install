/*
    Create proximity placement group for VM's.
 */

variable "proximity_group_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "vnet_availability_zones" {}

resource "azurerm_proximity_placement_group" "itself" {
  for_each            = length(var.vnet_availability_zones) > 1 ? toset([]) : toset(["compute", "storage"])
  name                = format("%s-%s-ppg", var.proximity_group_name, each.key)
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "proximity_group_compute_id" {
  value = try(azurerm_proximity_placement_group.itself["compute"].id, null)
}

output "proximity_group_storage_id" {
  value = try(azurerm_proximity_placement_group.itself["storage"].id, null)
}
