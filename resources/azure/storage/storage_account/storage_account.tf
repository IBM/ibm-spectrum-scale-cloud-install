/*
    Create storage account.
 */

variable "name" {}
variable "resource_group_name" {}
variable "location" {}

resource "azurerm_storage_account" "itself" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

}

output "storage_account_id" {
  value = azurerm_storage_account.itself.id
}
