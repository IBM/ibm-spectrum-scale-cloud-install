/*
    Creates GCP Bastion VM instance (which obtains a public ip).
*/

variable "instance_name" {}
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

resource "google_compute_instance" "bastion_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true
  tags                      = var.vm_instance_tags

  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
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

    #tfsec:ignore:google-compute-no-public-ip
    access_config {
      # This will generate an ephemeral IP
      nat_ip       = null
      network_tier = var.network_tier
    }
  }

  metadata = {
    ssh-keys               = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
    block-project-ssh-keys = true
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
  }
}

output "bastion_instance_id" {
  value = google_compute_instance.bastion_instance.instance_id
}

output "bastion_instance_name" {
  value      = var.instance_name
  depends_on = [google_compute_instance.bastion_instance]
}

output "bastion_instance_uri" {
  value = google_compute_instance.bastion_instance.self_link
}

output "bastion_public_ip" {
  value = google_compute_instance.bastion_instance.network_interface[0].access_config[0].nat_ip
}

output "bastion_private_ip" {
  value = google_compute_instance.bastion_instance.network_interface[0].network_ip
}
