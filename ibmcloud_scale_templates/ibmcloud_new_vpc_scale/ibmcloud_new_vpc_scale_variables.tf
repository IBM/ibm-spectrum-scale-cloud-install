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

variable "primary_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC subnet CIDR blocks."
}

variable "secondary_cidr_block" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "IBM Cloud VPC secondary subnet CIDR blocks."
}

variable "create_secondary_subnets" {
  type        = bool
  default     = true
  description = "Choose if secondary subnets have to be created or not."
}

variable "dns_domain" {
  type        = string
  default     = "scale.com"
  description = "IBM Cloud DNS domain name."
}

variable "resource_group" {
  type        = string
  default     = "default"
  description = "IBM Cloud resource group name."
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

variable "bastion_ssh_key" {
  type        = string
  description = "SSH key name to be used for Bastion virtual server instance."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-1-minimal-amd64-1"
  description = "Compute instance OS image name."
}

variable "total_compute_instances" {
  type        = string
  default     = 2
  description = "Total number of Compute instances."
}

variable "storage_vsi_osimage_name" {
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

variable "instance_ssh_key" {
  type        = string
  description = "SSH key name to be used for Compute, Storage virtual server instance."
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

variable "scale_version" {
  type        = string
  default     = "5.0.5.0"
  description = "IBM Spectrum Scale version."
}

variable "bucket_name" {
  type        = string
  description = "IBM COS bucket name to be used for backing up ansible inventory file."
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

variable "create_scale_cluster" {
  type        = bool
  default     = false
  description = "Flag to represent whether to create scale cluster or not."
}

variable "generate_jumphost_ssh_config" {
  type        = bool
  default     = false
  description = "Flag to represent whether to generate jump host SSH config or not."
}

variable "generate_ansible_inv" {
  type        = bool
  default     = true
  description = "Flag to represent whether to generate ansible inventory JSON or not."
}

variable "block_volumes_per_instance" {
  type        = number
  default     = 1
  description = "Number of block storage volumes/disks to be attached to each storage instance."
}

variable "instances_ssh_user" {
  type        = string
  default     = "root"
  description = "Name of the administrator to access the bastion instance."
}

variable "instances_ssh_private_key_path" {
  type        = string
  description = "SSH private key local path, which will be used to login to bastion host."
}
