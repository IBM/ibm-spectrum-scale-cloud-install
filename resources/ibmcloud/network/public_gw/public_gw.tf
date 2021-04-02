/*
    Creates IBM Cloud Public/internet gateway.
*/

variable "public_gw_name" {}
variable "vpc_id" {}
variable "zones" {}
variable "resource_grp_id" {}


resource "ibm_is_public_gateway" "public_gw" {
  count          = length(var.zones)
  name           = "${var.public_gw_name}-${count.index + 1}"
  vpc            = var.vpc_id
  resource_group = var.resource_grp_id
  zone           = element(var.zones, count.index)
}

output "public_gw_id" {
  value = ibm_is_public_gateway.public_gw.*.id
}
