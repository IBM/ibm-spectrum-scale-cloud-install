/*
  Creates GCP VM instance withouth additional(Persistent/Ephemeral) disks
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
variable "private_key_content" {}
variable "public_key_content" {}
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

output "dns_hostname" {
  value = { (google_compute_instance.itself.network_interface[0].network_ip) = "${google_compute_instance.itself.name}.${google_compute_instance.itself.zone}.c.${google_compute_instance.itself.project}.internal" }
}
