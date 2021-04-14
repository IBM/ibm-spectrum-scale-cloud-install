/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

variable "total_vsis" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zones" {}
variable "vsi_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "resource_grp_id" {}


resource "ibm_is_instance" "vsi" {
  count   = var.total_vsis
  name    = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = element(var.vsi_subnet_id, count.index)
    security_groups = var.vsi_security_group
  }

  vpc            = var.vpc_id
  zone           = element(var.zones, count.index)
  resource_group = var.resource_grp_id
  keys           = var.vsi_user_public_key

  boot_volume {
    name = "${var.vsi_name_prefix}-vsi-${count.index + 1}-vol"
  }
}

output "vsi_ids" {
  value = ibm_is_instance.vsi.*.id
}

output "vsi_nw_ids" {
  value = ibm_is_instance.vsi[*].primary_network_interface[0]
}
