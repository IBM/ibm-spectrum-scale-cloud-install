/*
  Creates GCP VM instance with specified number of persistent disk
*/

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
variable "vpc_availability_zones" {}
variable "vpc_subnets" {}
variable "total_cluster_instances" {}
variable "block_device_kms_key_ring_ref" {}
variable "block_device_kms_key_ref" {}
variable "dns_forward_dns_zone" {}
variable "dns_forward_dns_name" {}
variable "dns_reverse_dns_zone" {}
variable "dns_reverse_dns_name" {}

locals {
  vpc_subnets             = var.vpc_subnets == null ? [] : var.vpc_subnets
  availability_zones      = var.vpc_availability_zones == null ? [] : var.vpc_availability_zones
  vpc_availability_zones  = length(local.availability_zones) > length(local.vpc_subnets) ? slice(local.availability_zones, 0, length(local.vpc_subnets)) : local.availability_zones
  total_cluster_instances = var.total_cluster_instances == null ? 0 : var.total_cluster_instances
  total_persistent_disks  = var.total_persistent_disks == null ? 0 : var.total_persistent_disks

  vm_configuration   = flatten(toset([for i in range(local.total_cluster_instances) : { subnet = element(var.vpc_subnets, i), zone = element(local.vpc_availability_zones, i), vm_name = "${var.instance_name}-${i}" }]))
  disk_configuration = flatten(toset([for disk_no in range(local.total_persistent_disks) : flatten([for vm_meta in local.vm_configuration : { vm_name = vm_meta.vm_name, vm_name_suffix = disk_no, vm_zone = vm_meta.zone }])]))

  local_ssd_names = [for i in range(var.total_local_ssd_disks) : "/dev/nvme0n${i + 1}"]
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
  count                     = length(local.vm_configuration)
  name                      = local.vm_configuration[count.index].vm_name
  machine_type              = var.machine_type
  zone                      = local.vm_configuration[count.index].zone
  allow_stopping_for_update = true
  hostname                  = format("%s.%s", local.vm_configuration[count.index].vm_name, var.dns_forward_dns_name)

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
    subnetwork = local.vm_configuration[count.index].subnet
    network_ip = null
  }
  metadata = {
    ssh-keys               = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
    block-project-ssh-keys = true
    vmdnssetting           = length(var.vpc_availability_zones) > 1 ? "GlobalDefault" : "ZonalOnly"
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

# Add the VM instance ip as 'A' record to DNS
resource "google_dns_record_set" "a_itself" {
  count = length(local.vm_configuration)
  # Trailing dot is required
  name         = format("%s.%s.", local.vm_configuration[count.index].vm_name, var.dns_forward_dns_name)
  type         = "A"
  managed_zone = var.dns_forward_dns_zone
  ttl          = 300
  rrdatas      = [google_compute_instance.itself[count.index].network_interface[0].network_ip]
}


# Add the VM instance reverse lookup as 'PTR' record to DNS
resource "google_dns_record_set" "ptr_itself" {
  count = length(local.vm_configuration)
  # Trailing dot is required
  name         = format("%s.%s.%s.%s.", split(".", google_compute_instance.itself[count.index].network_interface[0].network_ip)[3], split(".", google_compute_instance.itself[count.index].network_interface[0].network_ip)[2], split(".", google_compute_instance.itself[count.index].network_interface[0].network_ip)[1], var.dns_reverse_dns_name)
  type         = "PTR"
  managed_zone = var.dns_reverse_dns_zone
  ttl          = 300
  # Trailing dot is required
  rrdatas = [format("%s.%s.", local.vm_configuration[count.index].vm_name, var.dns_forward_dns_name)]
}

resource "google_compute_disk" "itself" {
  count                     = length(local.disk_configuration)
  zone                      = local.disk_configuration[count.index].vm_zone
  name                      = format("%s-data-%s", local.disk_configuration[count.index].vm_name, local.disk_configuration[count.index].vm_name_suffix)
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
  count      = length(local.disk_configuration)
  zone       = local.disk_configuration[count.index].vm_zone
  disk       = format("%s-data-%s", local.disk_configuration[count.index].vm_name, local.disk_configuration[count.index].vm_name_suffix)
  instance   = local.disk_configuration[count.index].vm_name
  depends_on = [google_compute_disk.itself]
}

# Instance details
output "instance_ids" {
  value = google_compute_instance.itself[*].instance_id
}

output "instance_selflink" {
  value = google_compute_instance.itself[*].self_link
}

output "instance_ips" {
  value = google_compute_instance.itself[*].network_interface[0].network_ip
}

output "data_disk_id" {
  value = google_compute_disk.itself[*].id
}

output "data_disk_uri" {
  value = google_compute_disk.itself[*].self_link
}

output "data_disk_attachment_id" {
  value = google_compute_attached_disk.attach_data_disk[*].id
}

output "data_disk_zone" {
  value = google_compute_disk.itself[*].zone
}

output "disk_device_mapping" {
  value = (var.total_persistent_disks > 0) && (length(var.block_device_names) >= var.total_persistent_disks) ? { for instances in(google_compute_instance.itself) : (instances.network_interface[0].network_ip) => slice(var.block_device_names, 0, var.total_persistent_disks) } : var.total_local_ssd_disks > 0 ? { for instances in(google_compute_instance.itself) : (instances.network_interface[0].network_ip) => local.local_ssd_names } : {}
}

output "dns_hostname" {
  value = { for instances in(google_compute_instance.itself) : (instances.network_interface[0].network_ip) => "${instances.name}.${instances.zone}.c.${instances.project}.internal" }
}
