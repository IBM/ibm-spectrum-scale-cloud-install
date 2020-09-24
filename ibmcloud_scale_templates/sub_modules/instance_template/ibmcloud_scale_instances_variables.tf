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

variable "vpc_id" {
  type        = string
  description = "IBM Cloud VPC ID."
}

variable "cidr_block" {
  type        = list(string)
  description = "IBM Cloud VPC subnet CIDR blocks."
}

variable "compute_instance_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-18-04-1-minimal-amd64-2"
  description = "Compute instance OS image name."
}

variable "total_compute_instances" {
  type        = string
  default     = 2
  description = "Total Compute instances."
}

variable "storage_instance_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-18-04-1-minimal-amd64-2"
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

variable "instance_key_name" {
  type        = string
  description = "SSH key name to be used for Compute, Storage virtual server instance."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet id to be used for Compute, Storage virtual server instance."
}

variable "zones" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = list(string)
  description = "IBM Cloud zone names."
}
