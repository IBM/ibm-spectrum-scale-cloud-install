/*
    Creates IBM Cloud DNS Zone.
*/

variable "dns_domain" {}
variable "dns_zone_count" {}
variable "dns_service_id" {}
variable "dns_label" {}


resource "ibm_dns_zone" "zone" {
  count       = var.dns_zone_count
  name        = element(var.dns_domain, count.index)
  instance_id = element(var.dns_service_id, count.index)
  description = element(["Private DNS Zone for compute VPC DNS communication.", "Private DNS Zone for storage VPC DNS communication."], count.index)
  label       = var.dns_label
}

output "dns_zone_id" {
  value = ibm_dns_zone.zone.*.zone_id
}
