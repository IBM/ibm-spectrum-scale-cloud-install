/*
    Creates GCP Bastion VM instance (which obtains a public ip).
*/

variable "instance_name_prefix" {}
variable "zone" {}
variable "machine_type" {}
variable "subnet_name" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "network_tier" {}
variable "ssh_user_name" {}
variable "ssh_key_path" {}
variable "vm_instance_tags" {}
variable "operator_email" {}
variable "scopes" {}


resource "google_compute_instance" "bastion_instance" {
  name         = format("%s-%s", var.instance_name_prefix, "bastion")
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true
  tags                      = var.vm_instance_tags

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

    access_config {
      // This will generate an ephemeral IP
      nat_ip       = null
      network_tier = var.network_tier
    }
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


output "bastion_instance_id" {
  value = google_compute_instance.bastion_instance.instance_id
}

output "bastion_instance_name" {
  value      = format("%s-%s", var.instance_name_prefix, "bastion")
  depends_on = [google_compute_instance.bastion_instance]
}

output "bastion_instance_uri" {
  value = google_compute_instance.bastion_instance.self_link
}

output "bastion_public_ip" {
  value = google_compute_instance.bastion_instance.network_interface.0.access_config.0.nat_ip
}

output "bastion_private_ip" {
  value = google_compute_instance.bastion_instance.network_interface.0.network_ip
}
