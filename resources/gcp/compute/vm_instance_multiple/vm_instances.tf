/*
  Creates multiple GCP VM instances with attached persistent.
*/

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP zone that the instances should be created."
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale  instances."
}

variable "instance_name_prefix" {
  type        = string
  default     = "compute"
  description = "Instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
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
  description = "Image from which to initialize Spectrum Scale instances."
}

variable "data_disk_size" {
  type        = string
  default     = 500
  description = "Data disk size in gigabytes."
}

variable "vm_instance_tags" {
  type        = list(string)
  default     = []
  description = "List of tags to attach to the instance."
}

variable "instances_ssh_user_name" {
  type        = string
  default     = "gcpadmin"
  description = "Name of the administrator to access the instance."
}

variable "instances_ssh_public_key_path" {
  type        = string
  description = "SSH public key local path."
}

variable "subnet_name" {
  type        = string
  nullable    = true
  description = "Subnetwork of a Virtual Private Cloud network with one primary IP range"
}

variable "total_cluster_instances" {
  type        = number
  default     = 0
  description = "Number of Instance that needs to create."
}

variable "total_data_disks" {
  type        = number
  default     = 0
  description = "Total persistent disk per Instance."
}

variable "data_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "operator_email" {
  type        = string
  description = "GCP service account e-mail address."
}

variable "scopes" {
  type        = list(string)
  default     = ["cloud-platform"]
  description = "List of service scopes."
}

variable "private_key_content" {
  type        = string
  description = "SSH private key content."
}

variable "public_key_content" {
  type        = string
  description = "SSH public key content."
}

module "compute_instances_multiple" {
  count               = var.total_cluster_instances != null ? var.total_cluster_instances : 0
  source              = "../vm_instance"
  zone                = var.zone
  machine_type        = var.machine_type
  instance_name       = "${var.instance_name_prefix}-${count.index}"
  boot_disk_size      = var.boot_disk_size
  boot_disk_type      = var.boot_disk_type
  boot_image          = var.boot_image
  data_disk_type      = var.data_disk_type
  data_disk_size      = var.data_disk_size
  total_data_disks    = var.total_data_disks
  vm_instance_tags    = var.vm_instance_tags
  subnet_name         = var.subnet_name
  ssh_user_name       = var.instances_ssh_user_name
  ssh_key_path        = var.instances_ssh_public_key_path
  private_key_content = var.private_key_content
  public_key_content  = var.public_key_content
  operator_email      = var.operator_email
  scopes              = var.scopes
}


#Instance details
output "instance_ids" {
  value = module.compute_instances_multiple[*].scale_instance_ids
}

output "instance_uris" {
  value = module.compute_instances_multiple[*].scale_instance_uris
}

output "instance_ips" {
  value = module.compute_instances_multiple[*].scale_instance_ips
}

#Disk details
output "attached_data_disk_id" {
  value = module.compute_instances_multiple[*].data_disk_id
}

output "attached_data_disk_uri" {
  value = module.compute_instances_multiple[*].data_disk_uri
}
