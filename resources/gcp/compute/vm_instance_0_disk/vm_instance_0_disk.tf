/*
  Creates GCP VM instance without additional(Persistent/Ephemeral) disks (i.e. compute instances)
*/

variable "vpc_region" {}
variable "zone" {}
variable "subnet_name" {}
variable "is_multizone" {}
variable "service_email" {}
variable "scopes" {}
variable "instance_name" {}
variable "ssh_public_key_path" {}
variable "machine_type" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "ssh_user_name" {}
variable "private_key_content" {}
variable "public_key_content" {}
variable "vpc_forward_dns_zone" {}
variable "vpc_dns_domain" {}
variable "vpc_reverse_dns_zone" {}
variable "vpc_reverse_dns_domain" {}
variable "root_device_kms_key_ring_ref" {}
variable "root_device_kms_key_ref" {}
variable "network_tags" {}

data "google_kms_key_ring" "itself" {
  count    = var.root_device_kms_key_ring_ref != null ? 1 : 0
  name     = var.root_device_kms_key_ring_ref
  location = var.vpc_region
}

data "google_kms_crypto_key" "itself" {
  count    = var.root_device_kms_key_ref != null ? 1 : 0
  name     = var.root_device_kms_key_ref
  key_ring = data.google_kms_key_ring.itself[0].id
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.private_key_content}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "StrictHostKeyChecking no" >> ~/.ssh/config
EOF
}

#tfsec:ignore:google-compute-enable-shielded-vm-im
#tfsec:ignore:google-compute-enable-shielded-vm-vtpm
resource "google_compute_instance" "itself" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  hostname     = format("%s.%s", var.instance_name, var.vpc_dns_domain)

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
  tags = var.network_tags

  metadata = {
    ssh-keys               = <<EOT
      root:${var.public_key_content}
      ${var.ssh_user_name}:${file(var.ssh_public_key_path)}
      EOT
    block-project-ssh-keys = true
    vmdnssetting           = var.is_multizone ? "GlobalDefault" : "ZonalOnly"
  }

  metadata_startup_script = data.template_file.metadata_startup_script.rendered

  service_account {
    email  = var.service_email
    scopes = var.scopes
  }
  lifecycle {
    ignore_changes = all
  }
}

# Add the VM instance ip as 'A' record to DNS
resource "google_dns_record_set" "a_itself" {
  name         = format("%s.%s.", google_compute_instance.itself.name, var.vpc_dns_domain) # Trailing dot is required
  type         = "A"
  managed_zone = var.vpc_forward_dns_zone
  ttl          = 300
  rrdatas      = [google_compute_instance.itself.network_interface[0].network_ip]
}

# Add the VM instance reverse lookup as 'PTR' record to DNS
resource "google_dns_record_set" "ptr_itself" {
  name         = format("%s.%s.%s.%s.", split(".", google_compute_instance.itself.network_interface[0].network_ip)[3], split(".", google_compute_instance.itself.network_interface[0].network_ip)[2], split(".", google_compute_instance.itself.network_interface[0].network_ip)[1], var.vpc_reverse_dns_domain) # Trailing dot is required
  type         = "PTR"
  managed_zone = var.vpc_reverse_dns_zone
  ttl          = 300
  rrdatas      = [format("%s.%s.", google_compute_instance.itself.name, var.vpc_dns_domain)] # Trailing dot is required
}

# Ex: id: projects/spectrum-scale-xyz/zones/us-central1-b/instances/test-compute-2,  regex o/p: test-compute-2
output "instance_details" {
  value = {
    private_ip = google_compute_instance.itself.network_interface[0].network_ip
    id         = google_compute_instance.itself.id
    dns        = format("%s.%s", regex("^projects/[^/]+/zones/[^/]+/instances/([^/]+)$", google_compute_instance.itself.id)[0], var.vpc_dns_domain)
    zone       = regex("^projects/[^/]+/zones/([^/]+)/instances/.*$", google_compute_instance.itself.id)[0]
  }
}
