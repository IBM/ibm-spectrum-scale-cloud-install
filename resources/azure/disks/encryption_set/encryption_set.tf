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

# Granting disk encryption set to Read Data from Key Vault
resource "azurerm_key_vault_access_policy" "itself" {
  count        = var.turn_on ? 1 : 0
  key_vault_id = data.azurerm_key_vault.itself[0].id
  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy",
  ]
  tenant_id = azurerm_disk_encryption_set.itself[0].identity[0].tenant_id
  object_id = azurerm_disk_encryption_set.itself[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "itself" {
  count                = var.turn_on ? 1 : 0
  scope                = data.azurerm_key_vault.itself[0].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.itself[0].identity[0].principal_id
}

output "enc_set_id" {
  value      = try(azurerm_disk_encryption_set.itself[0].id, null)
  depends_on = [azurerm_key_vault_access_policy.itself, azurerm_role_assignment.itself]
}
