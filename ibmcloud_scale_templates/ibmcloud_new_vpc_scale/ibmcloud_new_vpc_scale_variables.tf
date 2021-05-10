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

variable "addr_prefixes" {
  type        = list(string)
  default     = ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"]
  description = "IBM Cloud VPC address prefixes."
}

variable "create_seperate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if seperate subnets to be created for compute and storage."
}

variable "compute_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC subnet CIDR blocks."
}

variable "storage_cidr_block" {
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

variable "compute_gui_username" {
  type        = string
  default     = "SEC"
  description = "Username for Compute cluster GUI"
}

variable "storage_gui_username" {
  type        = string
  default     = "SEC"
  description = "Username for Storage cluster GUI"
}

variable "compute_gui_password" {
  type        = string
  default     = "Storage@Scale1"
  description = "Password for Compute cluster GUI"
}

variable "storage_gui_password" {
  type        = string
  default     = "Storage@Scale1"
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
  description = "Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "instances_ssh_private_key" {
  type        = string
  sensitive   = true
  description = "SSH private key, which will be used to login to bastion host."
}
