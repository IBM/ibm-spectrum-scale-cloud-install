variable "vpc_region" {
  type        = string
  description = "IBM Cloud VPC region where the resources will be created."
}

variable "vpc_zones" {
  type        = list(string)
  description = "IBM Cloud VPC zone names."
}

variable "stack_name" {
  type        = string
  default     = "spectrum-scale"
  description = "IBM Cloud stack name (keep all lower case), it will be used as resource prefix."
}

variable "vpc_addr_prefixes" {
  type        = list(string)
  default     = ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"]
  description = "IBM Cloud VPC address prefixes."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if separate subnets to be created for compute and storage."
}

variable "vpc_compute_cluster_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC subnet CIDR blocks."
}

variable "vpc_storage_cluster_cidr_block" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "IBM Cloud VPC secondary subnet CIDR blocks."
}

variable "dns_domains" {
  type        = list(string)
  default     = ["strgscale.com", "compscale.com"]
  description = "IBM Cloud DNS domain names."
}

variable "resource_group" {
  type        = string
  default     = "default"
  description = "IBM Cloud resource group name."
}

variable "bastion_incoming_remote" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Bastion security group inbound remote."
}

variable "bastion_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-18-04-1-minimal-amd64-2"
  description = "Bastion OS image name."
}

variable "bastion_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Bastion virtual server instance."

  validation {
    condition     = can(regex("^[^\\s]+-[0-9]+x[0-9]+", var.bastion_vsi_profile))
    error_message = "The profile must be a valid profile name."
  }
}

variable "bastion_ssh_key" {
  type        = string
  description = "SSH key name to be used for Bastion virtual server instance."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Compute instance OS image name."
}

variable "total_compute_instances" {
  type        = string
  default     = 2
  description = "Total number of Compute instances."

  validation {
    condition     = var.total_compute_instances <= 100
    error_message = "Input \"total_compute_instances\" must be <= 100."
  }
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Storage instance OS image name."
}

variable "total_storage_instances" {
  type        = string
  default     = 2
  description = "Total number of Storage instances."

  validation {
    condition     = var.total_storage_instances <= 34
    error_message = "Input \"total_storage_instances\" must be <= 34."
  }
}

variable "compute_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Compute virtual server instance."

  validation {
    condition     = can(regex("^[^\\s]+-[0-9]+x[0-9]+", var.compute_vsi_profile))
    error_message = "The profile must be a valid profile name."
  }
}

variable "storage_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Storage virtual server instance."

  validation {
    condition     = can(regex("^[^\\s]+-[0-9]+x[0-9]+", var.storage_vsi_profile))
    error_message = "The profile must be a valid profile name."
  }
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for Compute cluster GUI"
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "instance_ssh_key" {
  type        = string
  description = "SSH key name to be used for Compute, Storage virtual server instance."
}

variable "scale_version" {
  type        = string
  description = "IBM Spectrum Scale version."
}

variable "filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "compute_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "bastion_ssh_private_key_content" {
  type        = string
  sensitive   = true
  description = "Bastion SSH private key content, which will be used to login to bastion host."
}
