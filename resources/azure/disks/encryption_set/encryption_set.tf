/*
    Create Azure Disk encryption set
*/

variable "encryption_type" {}
variable "filesystem_key_vault_key_ref" {}
variable "location" {}
variable "name_prefix" {}
variable "resource_group_name" {}
variable "filesystem_key_vault_ref" {}
variable "turn_on" {}

data "azurerm_key_vault" "itself" {
  count               = var.turn_on ? 1 : 0
  name                = var.filesystem_key_vault_ref
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_key" "itself" {
  count        = var.turn_on ? 1 : 0
  name         = var.filesystem_key_vault_key_ref
  key_vault_id = data.azurerm_key_vault.itself[0].id
}

resource "azurerm_disk_encryption_set" "itself" {
  count               = var.turn_on ? 1 : 0
  name                = var.name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  encryption_type     = var.encryption_type
  key_vault_key_id    = data.azurerm_key_vault_key.itself[0].id
  identity {
    type = "SystemAssigned"
  }
}

output "enc_set_id" {
  value = try(azurerm_disk_encryption_set.itself[0].id, null)
}
