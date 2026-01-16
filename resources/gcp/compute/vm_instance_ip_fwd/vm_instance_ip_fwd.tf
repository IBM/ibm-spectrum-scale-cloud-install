/*
  Creates GCP VM instance with a static route
*/

variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "ces_ipaddress" {}
variable "instance_name" {}
variable "is_multizone" {}
variable "machine_type" {}
variable "network_name" {}
variable "network_tags" {}
variable "private_key_content" {}
variable "public_key_content" {}
variable "root_device_kms_key_ref" {}
variable "root_device_kms_key_ring_ref" {}
variable "rule_priority" {}
variable "scopes" {}
variable "service_email" {}
variable "ssh_public_key_path" {}
variable "ssh_user_name" {}
variable "subnet_name" {}
variable "vpc_ces_reverse_dns_zone" {}
variable "vpc_ces_reverse_dns_domain" {}
variable "vpc_dns_domain" {}
variable "vpc_forward_dns_zone" {}
variable "vpc_region" {}
variable "vpc_reverse_dns_zone" {}
variable "vpc_reverse_dns_domain" {}
variable "zone" {}


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


locals {
  user_data = <<-EOT
    #!/usr/bin/env bash
    echo "${var.private_key_content}" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    echo "StrictHostKeyChecking no" >> ~/.ssh/config
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
  EOT
}

#tfsec:ignore:AVD-GCP-0067
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
  #tfsec:ignore:AVD-GCP-0043
  can_ip_forward = true
  tags           = var.network_tags

  metadata = {
    ssh-keys               = <<EOT
      root:${var.public_key_content}
      ${var.ssh_user_name}:${file(var.ssh_public_key_path)}
      EOT
    block-project-ssh-keys = true
    vmdnssetting           = var.is_multizone ? "GlobalDefault" : "ZonalOnly"
  }

  metadata_startup_script = local.user_data

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

# Add static route for the CES ip address
resource "google_compute_route" "itself" {
  name                   = format("ces-%s", join("", split(".", var.ces_ipaddress)))
  dest_range             = format("%s/32", var.ces_ipaddress)
  network                = var.network_name
  next_hop_instance      = var.instance_name
  priority               = var.rule_priority
  next_hop_instance_zone = var.zone
  depends_on             = [google_compute_instance.itself]
}

# Add the CES ip address as 'A' record to DNS
resource "google_dns_record_set" "ces_a_itself" {
  name         = format("%s-ces.%s.", google_compute_instance.itself.name, var.vpc_dns_domain) # Trailing dot is required
  type         = "A"
  managed_zone = var.vpc_forward_dns_zone
  ttl          = 300
  rrdatas      = [var.ces_ipaddress]
  depends_on   = [google_compute_instance.itself, google_compute_route.itself]
}

# Add the CES instance reverse lookup as 'PTR' record to DNS
resource "google_dns_record_set" "ces_ptr_itself" {
  name         = format("%s.%s.%s.%s.", split(".", var.ces_ipaddress)[3], split(".", var.ces_ipaddress)[2], split(".", var.ces_ipaddress)[1], var.vpc_ces_reverse_dns_domain) # Trailing dot is required
  type         = "PTR"
  managed_zone = var.vpc_ces_reverse_dns_zone
  ttl          = 300
  rrdatas      = [format("%s-ces.%s.", google_compute_instance.itself.name, var.vpc_dns_domain)] # Trailing dot is required
  depends_on   = [google_compute_instance.itself, google_compute_route.itself]
}

# Ex: id: projects/spectrum-scale-xyz/zones/us-central1-b/instances/test-compute-2,  regex o/p: test-compute-2
output "instance_details" {
  value = {
    private_ip     = google_compute_instance.itself.network_interface[0].network_ip
    id             = google_compute_instance.itself.id
    dns            = format("%s.%s", regex("^projects/[^/]+/zones/[^/]+/instances/([^/]+)$", google_compute_instance.itself.id)[0], var.vpc_dns_domain)
    zone           = regex("^projects/[^/]+/zones/([^/]+)/instances/.*$", google_compute_instance.itself.id)[0]
    ces_private_ip = var.ces_ipaddress
  }
}

output "route_id" {
  value = google_compute_route.itself.id
}

output "route_uri" {
  value = google_compute_route.itself.self_link
}
