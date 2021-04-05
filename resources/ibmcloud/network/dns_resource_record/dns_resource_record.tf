/*
    Creates a DNS records for provided VSI ip address.
*/

variable "total_dns_entires" {}
variable "dns_service_id" {}
variable "dns_zone_id" {}
variable "vsi_dns_name_prefix" {}
variable "vsi_ips" {}


resource "ibm_dns_resource_record" "a_records" {
  count       = var.total_dns_entires
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = "${var.vsi_dns_name_prefix}-${count.index + 1}"
  rdata       = element(var.vsi_ips, count.index)
  ttl         = 3600
}

output "dns_record_id" {
  value = ibm_dns_resource_record.a_records[*].id
}
