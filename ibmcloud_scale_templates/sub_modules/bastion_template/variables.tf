variable "enable_bastion" {
  type        = bool
  default     = true
  description = "Enable or disable bastion host creation. When false, no resources will be created."
}

variable "bastion_image_ref" {
  type        = string
  nullable    = false
  description = "IBM Cloud image ID for the bastion instance."
}

variable "bastion_instance_type" {
  type        = string
  nullable    = false
  description = "Instance type to use for the bastion instance."
}

variable "bastion_key_pair" {
  type        = string
  nullable    = false
  description = "The key pair to use to launch the bastion host."
}

variable "bastion_public_ssh_port" {
  type        = number
  nullable    = false
  description = "Set the SSH port to use from desktop to the bastion."

  validation {
    condition     = var.bastion_public_ssh_port > 0 && var.bastion_public_ssh_port <= 65535
    error_message = "bastion_public_ssh_port must be a valid port number between 1 and 65535."
  }
}

variable "desired_instance_count" {
  type        = number
  nullable    = false
  description = "Bastion instance desired count."
}

variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The IBM Cloud platform API key."
}

variable "resource_group_id" {
  type        = string
  nullable    = false
  description = "The ID of the resource group for bastion resources."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs that can access to the bastion. Default : 0.0.0.0/0"
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix added to all resource names for identification and organization (e.g., 'ibm-storage-scale')."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix)) && length(var.resource_prefix) <= 50
    error_message = "resource_prefix must contain only lowercase letters, numbers, and hyphens, and be 50 characters or less."
  }
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "IBM Cloud region where bastion and all resources will be deployed (e.g., 'us-east', 'us-south', 'eu-de')."
}

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  nullable    = false
  description = "List of subnets where the Auto Scaling Group will deploy the instances."

  validation {
    condition     = length(var.vpc_auto_scaling_group_subnets) > 0
    error_message = "vpc_auto_scaling_group_subnets must contain at least one subnet."
  }
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "A list of availability zones names or ids in the region."

  validation {
    condition     = length(var.vpc_availability_zones) > 0
    error_message = "vpc_availability_zones must contain at least one availability zone."
  }
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id were to deploy the bastion."
}
