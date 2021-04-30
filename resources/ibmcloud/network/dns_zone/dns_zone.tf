/*
    Creates IBM Cloud DNS Zone.
*/

variable "dns_domain" {}
variable "dns_zone_count" {}
variable "dns_service_id" {}
variable "dns_label" {}
variable "vpc_crn" {}


resource "ibm_dns_zone" "zone" {
  count       = var.dns_zone_count
  name        = element(var.dns_domain, count.index)
  instance_id = element(var.dns_service_id, count.index)
  description = element(["Private DNS Zone for storage VPC DNS communication.", "Private DNS Zone for compute VPC DNS communication."], count.index)
  label       = var.dns_label
}

resource "ibm_dns_permitted_network" "permitted_nw1" {
  instance_id = var.dns_service_id.0
  zone_id     = element(ibm_dns_zone.zone.*.zone_id, 0)
  vpc_crn     = var.vpc_crn
  type        = "vpc"
}

resource "time_sleep" "wait_30_seconds" {
  count           = var.dns_zone_count == 2 ? 1 : 0
  depends_on      = [ibm_dns_permitted_network.permitted_nw1]
  create_duration = "30s"
}

resource "ibm_dns_permitted_network" "permitted_nw2" {
  count       = var.dns_zone_count == 2 ? 1 : 0
  instance_id = var.dns_service_id.1
  zone_id     = element(ibm_dns_zone.zone.*.zone_id, 1)
  vpc_crn     = var.vpc_crn
  type        = "vpc"
  depends_on  = [time_sleep.wait_30_seconds]
}

output "dns_zone_ids" {
  value = ibm_dns_zone.zone.*.zone_id
}
