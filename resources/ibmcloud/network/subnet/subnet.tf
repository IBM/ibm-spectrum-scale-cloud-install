/*
    Creates IBM Cloud new Subnet(s).
*/

variable "vpc_id" {}
variable "zones" {}
variable "subnet_name" {}
variable "subnet_cidr_block" {}
variable "public_gateway" {}
variable "resource_grp_id" {}


resource "ibm_is_subnet" "subnet" {
  count           = length(var.zones)
  name            = "${var.subnet_name}-${count.index + 1}"
  vpc             = var.vpc_id
  resource_group  = var.resource_grp_id
  zone            = element(var.zones, count.index)
  ipv4_cidr_block = element(var.subnet_cidr_block, count.index)
  public_gateway  = element(var.public_gateway, count.index)
}

output "subnet_id" {
  value = ibm_is_subnet.subnet.*.id
}
