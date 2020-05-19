/*
  Creates specified number of GCP VM instance(s).
*/

variable "zones" {}
variable "total_instances" {}
variable "machine_type" {}
variable "subnet_name" {}
variable "instance_name_prefix" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "network_tier" {}
variable "ssh_user_name" {}
variable "ssh_key_path" {}
variable "vm_instance_tags" {}
variable "operator_email" {}
variable "scopes" {}


resource "google_compute_instance" "main_with_0_data" {
  count        = var.total_instances
  name         = format("%s-%s-%s", var.instance_name_prefix, "instance", count.index + 1)
  machine_type = var.machine_type
  zone         = element(var.zones, count.index)

  allow_stopping_for_update = true
  tags = var.vm_instance_tags

  boot_disk {
    auto_delete = true
    mode        = "READ_WRITE"
    initialize_params {
      size  = var.boot_disk_size
      type  = var.boot_disk_type
      image = var.boot_image
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    network_ip = null
  }

  metadata = {
    ssh-keys = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
  }

  service_account {
    email  = var.operator_email
    scopes = var.scopes
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}


output "instance_ids_with_0_datadisks" {
  value = google_compute_instance.main_with_0_data.*.id
}

output "instance_uris_with_0_datadisks" {
  value = google_compute_instance.main_with_0_data.*.self_link
}

output "instance_ips_with_0_datadisks" {
  value = google_compute_instance.main_with_0_data.*.network_interface.0.network_ip
}