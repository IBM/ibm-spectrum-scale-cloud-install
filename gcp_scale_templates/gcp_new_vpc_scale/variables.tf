variable "gcp_project_id" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP project ID to manage resources."
}

variable "credentials_file_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP region where the resources will be created."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = true
  default     = null
  description = "The CIDR block for the VPC."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "Range of internal addresses."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of storage cluster private subnets."
}

variable "bastion_ssh_key_path" {
  type        = string
  description = "SSH public key local path, will be used to login bastion instance."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "A list of availability zones names or ids in the region."
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for storage instances."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for compute instances."
}

variable "data_disks_per_instance" {
  type        = number
  default     = 1
  description = "Number of data disks to be attached to each storage instance."
}

variable "data_disk_size" {
  type        = string
  default     = 500
  description = "Data disk size in gigabytes."
}

variable "create_remote_mount_cluster" {
  type        = bool
  nullable    = true
  default     = null
  description = "Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup."
}

variable "filesystem_block_size" {
  type        = string
  nullable    = true
  default     = null
  description = "Filesystem block size."
}

variable "operator_email" {
  type        = string
  description = "GCP service account e-mail address."
}

variable "compute_cluster_public_key_path" {
  type        = string
  description = "SSH public key local path for compute instances."
}

variable "storage_cluster_public_key_path" {
  type        = string
  description = "SSH public key local path for storage instances."
}

variable "compute_boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "storage_boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize Spectrum Scale storage instances."
}

variable "bastion_boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize bastion instance."
}

variable "data_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd , local-ssd)."
}
