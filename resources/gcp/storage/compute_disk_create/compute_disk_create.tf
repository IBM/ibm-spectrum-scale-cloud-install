/*
  Creates specified number of GCP data/attached disks
*/

variable "zone" {}
variable "total_data_disks" {}
variable "data_disk_name_prefix" {}
variable "data_disk_description" {}
variable "physical_block_size_bytes" {}
variable "data_disk_type" {}
variable "data_disk_size" {}


resource "google_compute_disk" "data_disk" {
  count                     = var.total_data_disks
  zone                      = var.zone
  name                      = format("%s-%s", var.data_disk_name_prefix, count.index + 1)
  description               = var.data_disk_description
  physical_block_size_bytes = var.physical_block_size_bytes
  type                      = var.data_disk_type
  size                      = var.data_disk_size
}

output "data_disk_id" {
  value = google_compute_disk.data_disk.*.id
}

output "data_disk_uri" {
  value = google_compute_disk.data_disk.*.self_link
}
