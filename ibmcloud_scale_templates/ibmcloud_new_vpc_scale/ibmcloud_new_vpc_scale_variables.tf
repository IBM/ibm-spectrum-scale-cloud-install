variable "operating_env" {
  type        = string
  default     = "local"
  description = "Operating environement (valid: local)."
}

variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "IBM Cloud region where the resources will be created."
}

variable "ibmcloud_api_key" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "IBM Cloud api key."
}

variable "compute_generation" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  default     = 2
  description = "IBM Cloud compute generation."
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

variable "cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC subnet CIDR blocks."
}

variable "zones" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = list(string)
  description = "IBM Cloud zone names."
}

variable "tf_data_path" {
  type        = string
  default     = "~/tf_data_path"
  description = "Data path to be used by terraform for storing ssh keys."
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

variable "bastion_key_name" {
  type        = string
  description = "SSH key name to be used for Bastion virtual server instance."
}

variable "compute_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-1-minimal-amd64-1"
  description = "Compute instance OS image name."
}

variable "total_compute_instances" {
  type        = string
  default     = 2
  description = "Total number of Compute instances."
}

variable "storage_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-1-minimal-amd64-1"
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

variable "instance_key_name" {
  type        = string
  description = "SSH key name to be used for Compute, Storage virtual server instance."
}

variable "data_disks_per_instance" {
  type        = number
  default     = 1
  description = "Number of data disks to be attached to each storage instance."
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
