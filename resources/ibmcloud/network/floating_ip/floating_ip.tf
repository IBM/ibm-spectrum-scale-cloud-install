/*
    Creates IBM Cloud DNAT/floating ip.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "floating_ip_name" {}
variable "vsi_nw_id" {}
variable "resource_group_id" {}

resource "ibm_is_floating_ip" "itself" {
  name           = var.floating_ip_name
  target         = var.vsi_nw_id
  resource_group = var.resource_group_id
}

output "floating_ip_id" {
  value = ibm_is_floating_ip.itself.id
}

output "floating_ip_addr" {
  value = ibm_is_floating_ip.itself.address
}
