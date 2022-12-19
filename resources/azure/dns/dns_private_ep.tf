/*
    Create A record entry in DNS for private endpoint.
 */

variable "name" {}
variable "zone_name" {}
variable "resource_group_name" {}
variable "records" {}

resource "azurerm_private_dns_a_record" "itself" {
  name                = var.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.records]
}

output "dns_a_record_id" {
  value = azurerm_private_dns_a_record.itself.id
}
