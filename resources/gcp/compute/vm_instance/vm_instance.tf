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

locals {
  vpc_subnets             = var.vpc_subnets == null ? [] : var.vpc_subnets
  availability_zones      = var.vpc_availability_zones == null ? [] : var.vpc_availability_zones
  vpc_availability_zones  = length(local.availability_zones) > length(local.vpc_subnets) ? slice(local.availability_zones, 0, length(local.vpc_subnets)) : local.availability_zones
  total_cluster_instances = var.total_cluster_instances == null ? 0 : var.total_cluster_instances
  total_persistent_disks  = var.total_persistent_disks == null ? 0 : var.total_persistent_disks

  vm_config = flatten(toset([for i in range(local.total_cluster_instances) : { subnet = element(var.vpc_subnets, i), zone = element(local.vpc_availability_zones, i), vm_name = "${var.instance_name}-${i}" }]))

  sorted_instances = [for i in range(local.total_cluster_instances) : "${var.instance_name}-${i}"]
  vm_configuration = flatten([for value in local.sorted_instances : [for config in local.vm_config : config if value == config.vm_name]])

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
  for_each                  = { for vmconfig in local.vm_configuration : vmconfig.vm_name => vmconfig }
  name                      = each.value.vm_name
  machine_type              = var.machine_type
  zone                      = each.value.zone
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
    subnetwork = each.value.subnet
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
  for_each                  = { for vmdisk_config in local.disk_configuration : "${vmdisk_config.vm_name}-${vmdisk_config.vm_name_suffix}" => vmdisk_config }
  zone                      = each.value.vm_zone
  name                      = format("%s-data-%s", each.value.vm_name, each.value.vm_name_suffix)
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
  for_each   = { for vmdisk_config in local.disk_configuration : "${vmdisk_config.vm_name}-${vmdisk_config.vm_name_suffix}" => vmdisk_config }
  zone       = each.value.vm_zone
  disk       = format("%s-data-%s", each.value.vm_name, each.value.vm_name_suffix)
  instance   = each.value.vm_name
  depends_on = [google_compute_disk.itself]
}

# Instance details
output "instance_ids" {
  value = [ for instance in google_compute_instance.itself : instance.instance_id ]
}

output "instance_selflink" {
  value = [ for instance in google_compute_instance.itself : instance.self_link ]
}

output "instance_ips" {
  value = [ for instance in google_compute_instance.itself : instance.network_interface[0].network_ip ]
}

output "data_disk_id" {
  value = [ for disk in google_compute_disk.itself : disk.id ]
}

output "data_disk_uri" {
  value = [ for disk in google_compute_disk.itself : disk.self_link ]
}

output "data_disk_attachment_id" {
 value = [ for disk_attach in google_compute_attached_disk.attach_data_disk : disk_attach.id ]
}

output "data_disk_zone" {
  value = [ for disk in google_compute_disk.itself : disk.zone ]
}

output "disk_device_mapping" {
  value = (var.total_persistent_disks > 0) && (length(var.block_device_names) >= var.total_persistent_disks) ? { for instances in(google_compute_instance.itself) : (instances.network_interface[0].network_ip) => slice(var.block_device_names, 0, var.total_persistent_disks) } : var.total_local_ssd_disks > 0 ? { for instances in(google_compute_instance.itself) : (instances.network_interface[0].network_ip) => local.local_ssd_names } : {}
}

output "dns_hostname" {
  value = { for instances in(google_compute_instance.itself) : (instances.network_interface[0].network_ip) => "${instances.name}.${instances.zone}.c.${instances.project}.internal" }
}
