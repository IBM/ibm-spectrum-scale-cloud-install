/*
    Creates new IBM Cloud security group.
*/

variable "total_sec_groups" {}
variable "sec_group_name" {}
variable "vpc_id" {}


resource "ibm_is_security_group" "new_sec_grp" {
  count = var.total_sec_groups
  name  = "${var.sec_group_name}-${count.index + 1}"
  vpc   = var.vpc_id
}

output "sec_group_id" {
  value = ibm_is_security_group.new_sec_grp.*.id
}
