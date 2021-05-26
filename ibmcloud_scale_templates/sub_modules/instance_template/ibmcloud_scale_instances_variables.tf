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

   validation {
    condition     = lower(var.stack_name) == var.stack_name
    error_message = "IBM Cloud stack name should be all lower case."
  }
}

variable "vpc_id" {
  type        = string
  description = "IBM Cloud VPC ID."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Compute instance OS image name."
}

variable "total_compute_instances" {
  type        = string
  default     = 2
  description = "Total Compute instances."
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Storage instance OS image name."
}

variable "total_storage_instances" {
  type        = string
  default     = 2
  description = "Total Storage instances."
}

variable "compute_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Compute virtual server instance."
}

variable "storage_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for Storage virtual server instance."
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

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  description = "Subnet id to be used for Compute virtual server instance."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  description = "Subnet id to be used for Storage virtual server instance."
}

variable "vpc_compute_cluster_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC primary compute subnet CIDR blocks."
}

variable "vpc_storage_cluster_cidr_block" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "IBM Cloud VPC primary storage subnet CIDR blocks."
}

variable "dns_service_ids" {
  type        = list(string)
  description = "IBM Cloud DNS service resource ids."
}

variable "dns_zone_ids" {
  type        = list(string)
  description = "IBM Cloud DNS zone ids."
}

variable "dns_domains" {
  type        = list(string)
  default     = ["strgscale.com", "compscale.com"]
  description = "IBM Cloud DNS domain names."
}

variable "tf_data_path" {
  type        = string
  default     = "/tmp/.schematics/IBM/tf_data_path"
  description = "Data path to be used by terraform for storing ssh keys."
}

variable "tf_input_json_root_path" {
  type        = string
  default     = null
  description = "Terraform module absolute path."
}

variable "tf_input_json_file_name" {
  type        = string
  default     = null
  description = "Terraform module input variable defintion/json file name."
}

variable "block_volumes_per_instance" {
  type        = number
  default     = 0
  description = "Number of block storage volumes/disks to be attached to each storage instance."
}

variable "volume_profile" {
  type        = string
  default     = "10iops-tier"
  description = "Profile to use for this volume."
}

variable "volume_iops" {
  type        = number
  default     = null
  description = "Total input/output operations per second."
}

variable "volume_capacity" {
  type        = number
  default     = 100
  description = "Capacity of the volume in gigabytes."
}

variable "scale_infra_repo_clone_path" {
  type        = string
  default     = "/tmp/.schematics/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "bastion_ssh_private_key_content" {
  type        = string
  description = "Bastion SSH private key content, which will be used to login to bastion host."
}

variable "bastion_public_ip" {
  type        = string
  description = "Bastion public ip."
}

variable "bastion_os_flavor" {
  type        = string
  description = "Bastion OS image flavor."
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

variable "resource_grp_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "scale_version" {
  type        = string
  default     = "5.1.1"
  description = "IBM Spectrum Scale version."
}

variable "activity_tracker_plan_type" {
  type        = string
  default     = "lite"
  description = "IBM Cloud activity tracker plan type (Valid: lite, 7-day, 14-day, 30-day, hipaa-30-day)."
}
