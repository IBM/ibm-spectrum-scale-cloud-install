/*
  Creates specified number of GCP VM instance(s).
*/

variable "zone" {}
variable "machine_type" {}
variable "subnet_name" {}
variable "instance_name_prefix" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "data_disk_description" {}
variable "data_disks_per_instance" {}
variable "data_disk_size" {}
variable "data_disk_type" {}
variable "data_disk_block_size" {}
variable "network_tier" {}
variable "ssh_user_name" {}
variable "ssh_key_path" {}
variable "vm_instance_tags" {}
variable "operator_email" {}
variable "scopes" {}


resource "google_compute_disk" "data_disk" {
  name                      = format("%s-%s", var.instance_name_prefix, "disk")
  description               = var.data_disk_description
  physical_block_size_bytes = var.data_disk_block_size
  type                      = var.data_disk_type
  zone                      = var.zone
  size                      = var.data_disk_size
}


resource "google_compute_instance" "main_with_1_data" {
  name         = format("%s-%s", var.instance_name_prefix, "instance")
  machine_type = var.machine_type
  zone         = var.zone

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

  attached_disk {
    source      = google_compute_disk.data_disk.self_link
    device_name = "1"
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


output "instance_ids_with_1_datadisks" {
  value = google_compute_instance.main_with_1_data.id
}

output "instance_uris_with_1_datadisks" {
  value = google_compute_instance.main_with_1_data.self_link
}

output "instance_ips_with_1_datadisks" {
  value = google_compute_instance.main_with_1_data.network_interface.0.network_ip
}
