/*
  Creates GCP VM instance with specified number of persistent disk
*/

variable "service_email" {
  type        = string
  description = "GCP service account e-mail address."
}

variable "scopes" {
  type        = list(string)
  default     = ["cloud-platform"]
  description = "List of service scopes."
}

variable "instance_name" {
  type        = string
  default     = "compute-0"
  description = "Instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "ssh_key_path" {
  type        = string
  description = "SSH public key local path."
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale compute instances."
}

variable "boot_disk_size" {
  type        = number
  default     = 100
  description = "Compute instances boot disk size in gigabytes."
}
variable "boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize compute instances."
}

variable "ssh_user_name" {
  type        = string
  default     = "gcpadmin"
  description = "Name of the administrator to access the instance."
}

variable "vm_instance_tags" {
  type        = list(string)
  default     = []
  description = "List of tags to attach to the compute instance."
}

#Disk variables
variable "total_persistent_disks" {
  type        = number
  default     = 0
  description = "Number of persistent data disks that needs to be attached to compute instance."
}

variable "data_disk_name_prefix" {
  type        = string
  default     = "scale-disk"
  description = "Persistent data disk name prefix."
}

variable "data_disk_description" {
  type        = string
  default     = "SSD scale-disk"
  description = "Persistent data disk description."
}

variable "physical_block_size_bytes" {
  type        = number
  default     = 4096
  description = "Physical block size of the persistent disk, in bytes (valid: 4096, 16384)."
}

variable "data_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "data_disk_size" {
  type        = string
  default     = 500
  description = "Data disk size in gigabytes."
}

variable "total_local_ssd_disks" {
  type        = number
  default     = 0
  description = "Local ssd nvme disk."
}

variable "block_device_names" {
  type        = list(string)
  default     = []
  description = "List block devices names."
}

variable "private_key_content" {
  type        = string
  description = "SSH private key content."
}

variable "public_key_content" {
  type        = string
  description = "SSH public key content."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "A list of availability zones names or ids in the region."
}

variable "vpc_subnets" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "Subnetwork of a Virtual Private Cloud network with one primary IP range"
}

variable "total_cluster_instances" {
  type        = number
  default     = 0
  description = "Number of Instance that needs to create."
}

locals {
  vpc_subnets             = var.vpc_subnets == null ? [] : var.vpc_subnets
  vpc_availability_zones  = var.vpc_availability_zones == null ? [] : var.vpc_availability_zones
  total_cluster_instances = var.total_cluster_instances == null ? 0 : var.total_cluster_instances
  total_persistent_disks  = var.total_persistent_disks == null ? 0 : var.total_persistent_disks

  vm_configuration    = flatten([for zone_name in local.vpc_availability_zones : [for network in local.vpc_subnets : [for i in range(local.total_cluster_instances) : {zone = zone_name , subnet = network, vm_name = "${var.instance_name}-${index(local.vpc_subnets, network)}${i}"}]]])
  disk_configuration  = flatten([for vm_index in range(local.total_cluster_instances * length(local.vpc_subnets)) : [for disk_no in range(local.total_persistent_disks) : { index = vm_index , vm_name_suffix = "${disk_no}" }]])

  block_device_names = ["/dev/sdb", "/dev/sdc", "/dev/sdd", "/dev/sdf", "/dev/sdg",
  "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdm", "/dev/sdn", "/dev/sdo", "/dev/sdp", "/dev/sdq"]
}

output "generate_config" {
  value = local.vm_configuration[*]
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.private_key_content}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "StrictHostKeyChecking no" >> ~/.ssh/config
EOF
}

#Create scale instance
#tfsec:ignore:google-compute-enable-shielded-vm-im
#tfsec:ignore:google-compute-enable-shielded-vm-vtpm
resource "google_compute_instance" "itself" {
  count        = length(local.vm_configuration)
  name         = "${local.vm_configuration[count.index].vm_name}"
  machine_type = var.machine_type
  zone         = local.vm_configuration[count.index].zone

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
    subnetwork = local.vm_configuration[count.index].subnet
    network_ip = null
  }

  metadata = {
    ssh-keys               = format("%s:%s\n %s:%s", var.ssh_user_name, file(var.ssh_key_path),"root", var.public_key_content)
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


#tfsec:ignore:google-compute-disk-encryption-customer-key
resource "google_compute_disk" "data_disk" {
  count                     = length(local.disk_configuration)
  zone                      = google_compute_instance.itself[local.disk_configuration[count.index].index].zone
  name                      = format("%s-%s-%s", var.data_disk_name_prefix, google_compute_instance.itself[local.disk_configuration[count.index].index].instance_id, local.disk_configuration[count.index].vm_name_suffix)
  description               = var.data_disk_description
  physical_block_size_bytes = var.physical_block_size_bytes
  type                      = var.data_disk_type
  size                      = var.data_disk_size
  depends_on                = [google_compute_instance.itself]
}

resource "google_compute_attached_disk" "attach_data_disk" {
  count      = length(local.disk_configuration)
  disk       = format("%s-%s-%s", var.data_disk_name_prefix, google_compute_instance.itself[local.disk_configuration[count.index].index].instance_id, local.disk_configuration[count.index].vm_name_suffix)
  instance   = google_compute_instance.itself[local.disk_configuration[count.index].index].self_link
  depends_on = [google_compute_disk.data_disk]
}

#Instance details
output "instance_ids" {
  value = google_compute_instance.itself[*].instance_id
}

output "instance_uris" {
  value = google_compute_instance.itself[*].self_link
}

output "instance_ips" {
  value = google_compute_instance.itself[*].network_interface[0].network_ip
}

#Disk details
output "data_disk_id" {
  value = google_compute_disk.data_disk[*].id
}

output "data_disk_uri" {
  value = google_compute_disk.data_disk[*].self_link
}

output "data_disk_attachment_id" {
  value = google_compute_attached_disk.attach_data_disk[*].id
}

output "data_disk_zone" {
  value = google_compute_disk.data_disk[*].zone
}

output "disk_device_mapping" {
  value = (var.total_persistent_disks > 0) && (length(local.block_device_names) >= var.total_persistent_disks) ? { for instances in (google_compute_instance.itself) : (instances.network_interface[0].network_ip) => slice(local.block_device_names, 0, var.total_persistent_disks) } : {}
}

output "dns_hostname" {
  value = { for instances in (google_compute_instance.itself) : (instances.network_interface[0].network_ip) => "${instances.name}.${instances.zone}.c.${instances.project}.internal"  }
}

output "publlickeyContent" {
  value = var.public_key_content
}
