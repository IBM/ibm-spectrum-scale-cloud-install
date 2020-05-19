/*
  Attaches specified number of GCP data disks to instances per AZ.
*/

variable "total_disk_attachments" {}
variable "data_disk_ids" {}
variable "instance_ids" {}

resource "google_compute_attached_disk" "attach_data_disk" {
  count    = var.total_disk_attachments
  disk     = element(var.data_disk_ids, count.index)
  instance = element(var.instance_ids, count.index)
}

output "data_disk_attachment_id" {
  value = google_compute_attached_disk.attach_data_disk.*.id
}
