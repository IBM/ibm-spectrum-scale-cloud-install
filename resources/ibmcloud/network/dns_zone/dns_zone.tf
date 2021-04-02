/*
    Creates IBM Cloud DNS Zone.
*/

variable "dns_domain" {}
variable "dns_instance_id" {}
variable "dns_label" {}


resource "ibm_dns_zone" "zone" {
  name        = var.dns_domain
  instance_id = var.dns_instance_id
  description = "Private DNS Zone for VPC DNS communication."
  label       = var.dns_label
}

output "dns_zone_id" {
  value = ibm_dns_zone.zone.zone_id
}
