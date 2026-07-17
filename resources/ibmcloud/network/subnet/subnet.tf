/*
   Creates IBM Cloud new Subnet(s).
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "turn_on" {}
variable "vpc_id" {}
variable "zones" {}
variable "subnet_name" {}
variable "subnets_cidr" {}
variable "public_gateway" {}
variable "resource_group_id" {}
variable "tags" {
  type    = list(string)
  default = []
}

resource "ibm_is_subnet" "itself" {
  count           = var.turn_on && length(var.subnets_cidr) > 0 ? length(var.zones) : 0
  name            = "${var.subnet_name}-${count.index + 1}"
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  zone            = element(var.zones, count.index)
  ipv4_cidr_block = element(var.subnets_cidr, count.index)
  public_gateway  = length(var.public_gateway) > 0 ? element(var.public_gateway, count.index) : null
  tags            = var.tags
}

output "subnet_id" {
  value = ibm_is_subnet.itself[*].id
}

output "subnet_name" {
  value = ibm_is_subnet.itself[*].name
}

output "subnet_crn" {
  value = ibm_is_subnet.itself[*].crn
}
