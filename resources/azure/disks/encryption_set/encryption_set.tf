/*
    Create Azure Disk encryption set
*/

variable "encryption_type" {}
variable "filesystem_key_vault_key_ref" {}
variable "location" {}
variable "name_prefix" {}
variable "resource_group_name" {}
variable "filesystem_key_vault_ref" {}

data "azurerm_key_vault" "itself" {
  name                = var.filesystem_key_vault_ref
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_key" "itself" {
  name         = var.filesystem_key_vault_key_ref
  key_vault_id = data.azurerm_key_vault.itself.id
}

resource "azurerm_disk_encryption_set" "itself" {
  name                = var.name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  encryption_type     = var.encryption_type
  key_vault_key_id    = data.azurerm_key_vault_key.itself.id
  identity {
    type = "SystemAssigned"
  }
}

output "enc_set_id" {
  value = azurerm_disk_encryption_set.itself.id
}
