variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "IBM Cloud region where the resources will be created."
}

variable "zones" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = list(string)
  description = "IBM Cloud zone names."
}

variable "stack_name" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  default     = "spectrum-scale"
  description = "IBM Cloud stack name (keep all lower case)."
}

variable "vpc_id" {
  type        = string
  description = "IBM Cloud VPC ID."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-2"
  description = "Compute instance OS image name."
}

variable "total_compute_instances" {
  type        = string
  default     = 2
  description = "Total Compute instances."
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-2"
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

variable "instance_ssh_key" {
  type        = string
  description = "SSH key name to be used for Compute, Storage virtual server instance."
}

variable "primary_private_subnet_ids" {
  type        = list(string)
  description = "Subnet id to be used for Compute, Storage virtual server instance."
}

variable "secondary_private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet id to be used for Compute, Storage virtual server instance."
}

variable "primary_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC primary subnet CIDR blocks."
}

variable "secondary_cidr_block" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "IBM Cloud VPC secondary subnet CIDR blocks."
}

variable "dns_service_id" {
  type        = string
  description = "IBM Cloud DNS service resource id."
}

variable "dns_zone_id" {
  type        = string
  description = "IBM Cloud DNS zone id."
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

variable "instances_ssh_private_key" {
  type        = string
  description = "SSH private key, which will be used to login to bastion host."
}

variable "bastion_public_ip" {
  type        = string
  description = "Bastion public ip."
}

variable "filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Filesystem mount point."
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
