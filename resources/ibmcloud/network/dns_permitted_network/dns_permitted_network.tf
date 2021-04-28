/*
    Adds permitted network to IBM Cloud DNS.
*/

variable "dns_service_id" {}
variable "dns_permitted_count" {}
variable "dns_zone_id" {}
variable "vpc_crn" {}


resource "ibm_dns_permitted_network" "permitted_network" {
  count       = var.dns_permitted_count
  instance_id = element(var.dns_service_id, count.index)
  zone_id     = element(var.dns_zone_id, count.index)
  vpc_crn     = var.vpc_crn
  type        = "vpc"
}

output "dns_permitted_network_id" {
  value = ibm_dns_permitted_network.permitted_network.*.id
}
