/*
    Adds permitted network to IBM Cloud DNS.
*/

variable "dns_instance_id" {}
variable "dns_zone_id" {}
variable "vpc_crn" {}


resource "ibm_dns_permitted_network" "permitted_network" {
  instance_id = var.dns_instance_id
  zone_id     = var.dns_zone_id
  vpc_crn     = var.vpc_crn
  type        = "vpc"
}

output "dns_permitted_network_id" {
  value = ibm_dns_permitted_network.permitted_network.id
}
