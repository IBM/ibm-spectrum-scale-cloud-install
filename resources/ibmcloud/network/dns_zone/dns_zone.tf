/*
    Creates IBM Cloud DNS Zone.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "dns_domain" {}
variable "dns_zone_count" {}
variable "dns_service_id" {}
variable "description" {}
variable "dns_label" {}

resource "ibm_dns_zone" "itself" {
  count       = var.dns_zone_count
  name        = var.dns_domain
  instance_id = var.dns_service_id
  description = var.description
  label       = var.dns_label
}

output "dns_zone_id" {
  value = try(ibm_dns_zone.itself[0].zone_id, null)
}
