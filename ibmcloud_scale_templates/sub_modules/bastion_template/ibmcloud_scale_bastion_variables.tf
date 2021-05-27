variable "vpc_region" {
  type        = string
  description = "IBM Cloud region where the resources will be created."
}

variable "vpc_zones" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = list(string)
  description = "IBM Cloud zone names."
}

variable "stack_name" {
  type        = string
  default     = "spectrum-scale"
  description = "IBM Cloud stack name (keep all lower case)."

  validation {
    condition     = lower(var.stack_name) == var.stack_name
    error_message = "IBM Cloud stack name should be all lower case."
  }
}

variable "vpc_id" {
  type        = string
  description = "IBM Cloud VPC ID."
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

variable "bastion_subnet_id" {
  type        = list(string)
  description = "Subnet id to be used for Bastion virtual server instance."
}

variable "resource_grp_id" {
  type        = string
  description = "IBM Cloud resource group id."
}
