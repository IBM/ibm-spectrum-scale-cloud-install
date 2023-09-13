/*
  Creates GCP VM instance
*/

variable "zone" {}
variable "subnet_name" {}
variable "service_email" {}
variable "scopes" {}
variable "instance_name" {}
variable "ssh_key_path" {}
variable "machine_type" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "ssh_user_name" {}
variable "total_persistent_disks" {}
variable "data_disk_description" {}
variable "physical_block_size_bytes" {}
variable "data_disk_type" {}
variable "data_disk_size" {}
variable "total_local_ssd_disks" {}
variable "block_device_names" {}
variable "private_key_content" {}
variable "public_key_content" {}
variable "vpc_region" {}
variable "block_device_kms_key_ring_ref" {}
variable "block_device_kms_key_ref" {}
variable "dns_forward_dns_zone" {}
variable "dns_forward_dns_name" {}
variable "dns_reverse_dns_zone" {}
variable "dns_reverse_dns_name" {}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.private_key_content}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.public_key_content}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
EOF
}

data "google_kms_key_ring" "itself" {
  count    = var.block_device_kms_key_ring_ref != null ? 1 : 0
  name     = var.block_device_kms_key_ring_ref
  location = var.vpc_region
}

data "google_kms_crypto_key" "itself" {
  count    = var.block_device_kms_key_ref != null ? 1 : 0
  name     = var.block_device_kms_key_ref
  key_ring = data.google_kms_key_ring.itself[0].id
}

#Create scale instance
#tfsec:ignore:google-compute-enable-shielded-vm-im
#tfsec:ignore:google-compute-enable-shielded-vm-vtpm
resource "google_compute_instance" "itself" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    auto_delete = true
    mode        = "READ_WRITE"

    initialize_params {
      size  = var.boot_disk_size
      type  = var.boot_disk_type
      image = var.boot_image
    }
    kms_key_self_link = length(data.google_kms_crypto_key.itself) > 0 ? data.google_kms_crypto_key.itself[0].id : null
  }

  network_interface {
    subnetwork = var.subnet_name
    network_ip = null
  }

  metadata = {
    ssh-keys               = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
    block-project-ssh-keys = true
  }

  metadata_startup_script = data.template_file.metadata_startup_script.rendered

  service_account {
    email  = var.service_email
    scopes = var.scopes
  }

  dynamic "scratch_disk" {
    for_each = range(var.total_local_ssd_disks)
    content {
      interface = "NVME"
    }
  }

  lifecycle {
    ignore_changes = [attached_disk, metadata_startup_script]
  }
}

resource "google_compute_disk" "itself" {
  count                     = var.total_persistent_disks
  zone                      = var.zone
  name                      = format("%s-data-%s", var.instance_name, count.index + 1)
  description               = var.data_disk_description
  physical_block_size_bytes = var.physical_block_size_bytes
  type                      = var.data_disk_type
  size                      = var.data_disk_size

  dynamic "disk_encryption_key" {
    for_each = length(data.google_kms_crypto_key.itself) > 0 ? [1] : []
    content {
      kms_key_self_link = data.google_kms_crypto_key.itself[0].id
    }
  }

  depends_on = [google_compute_instance.itself]
}

resource "google_compute_attached_disk" "attach_data_disk" {
  count      = length(google_compute_disk.itself)
  disk       = google_compute_disk.itself[count.index].id
  instance   = google_compute_instance.itself.id
  depends_on = [google_compute_disk.itself]
}

# Add the VM instance ip as 'A' record to DNS
resource "google_dns_record_set" "a_itself" {
  # Trailing dot is required
  name         = format("%s.%s.", google_compute_instance.itself.name, var.dns_forward_dns_name)
  type         = "A"
  managed_zone = var.dns_forward_dns_zone
  ttl          = 300
  rrdatas      = [google_compute_instance.itself.network_interface[0].network_ip]
}


# Add the VM instance reverse lookup as 'PTR' record to DNS
resource "google_dns_record_set" "ptr_itself" {
  # Trailing dot is required
  name         = format("%s.%s.%s.%s.", split(".", google_compute_instance.itself.network_interface[0].network_ip)[3], split(".", google_compute_instance.itself.network_interface[0].network_ip)[2], split(".", google_compute_instance.itself.network_interface[0].network_ip)[1], var.dns_reverse_dns_name)
  type         = "PTR"
  managed_zone = var.dns_reverse_dns_zone
  ttl          = 300
  # Trailing dot is required
  rrdatas = [format("%s.%s.", google_compute_instance.itself.name, var.dns_forward_dns_name)]
}

#Instance details
output "instance" {
  value = google_compute_instance.itself
}

output "instance_ids" {
  value = google_compute_instance.itself.instance_id
}

output "instance_selflink" {
  value = google_compute_instance.itself.self_link
}

output "instance_ips" {
  value = google_compute_instance.itself.network_interface[0].network_ip
}

#Disk details
output "data_disk_id" {
  value = [for disk in google_compute_disk.itself : disk.id]
}

output "data_disk_uri" {
  value = [for disk in google_compute_disk.itself : disk.self_link]
}

output "data_disk_attachment_id" {
  value = [for disk_attach in google_compute_attached_disk.attach_data_disk : disk_attach.id]
}

output "data_disk_zone" {
  value = [for disk in google_compute_disk.itself : disk.zone]
}