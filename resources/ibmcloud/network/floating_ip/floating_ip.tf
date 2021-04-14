/*
    Creates IBM Cloud DNAT/floating ip.
*/

variable "floating_ip_name" {}
variable "vsi_nw_id" {}
variable "resource_grp_id" {}


resource "ibm_is_floating_ip" "floating_ip" {
  name           = var.floating_ip_name
  target         = var.vsi_nw_id
  resource_group = var.resource_grp_id
}

output "floating_ip_id" {
  value = ibm_is_floating_ip.floating_ip.id
}

output "floating_ip_addr" {
  value = ibm_is_floating_ip.floating_ip.address
}
