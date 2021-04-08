/*
    Creates specified number of IBM Cloud Volume(s).
*/

variable "total_volumes" {}
variable "volume_name_prefix" {}
variable "zone" {}
variable "volume_profile" {}
variable "volume_capacity" {}
variable "volume_iops" {}


resource "ibm_is_volume" "block_storage" {
  count    = var.total_volumes
  name     = "${var.volume_name_prefix}-vol-${count.index + 1}"
  profile  = var.volume_profile
  zone     = var.zone
  capacity = var.volume_capacity
  iops     = var.volume_iops
}

output "volume_id" {
  value = ibm_is_volume.block_storage.*.id
}
