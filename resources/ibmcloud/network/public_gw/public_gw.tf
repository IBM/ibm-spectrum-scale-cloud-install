/*
    Creates IBM Cloud Public/internet gateway.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "turn_on" {}
variable "public_gw_name" {}
variable "vpc_id" {}
variable "zones" {}
variable "resource_group_id" {}

resource "ibm_is_public_gateway" "itself" {
  count          = var.turn_on ? length(var.zones) : 0
  name           = "${var.public_gw_name}-${count.index + 1}"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  zone           = element(var.zones, count.index)
}

output "public_gw_id" {
  value = ibm_is_public_gateway.itself[*].id
}
