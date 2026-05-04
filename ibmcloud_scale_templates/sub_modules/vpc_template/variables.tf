variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Options: 'Storage-only', 'Compute-only', 'Combined-compute-storage'."

  validation {
    condition     = contains(["Storage-only", "Compute-only", "Combined-compute-storage"], var.cluster_type)
    error_message = "cluster_type must be one of: 'Storage-only', 'Compute-only', 'Combined-compute-storage'."
  }
}

variable "create_resource_group" {
  type        = bool
  nullable    = true
  description = "Flag to create a new resource group. Set to false to use an existing resource group."
}

variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "IBM Cloud API key for authentication and resource provisioning."
}

variable "resource_group_name" {
  type        = string
  nullable    = true
  description = "Name of the IBM Cloud resource group where VPC resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix added to all resource names for identification and organization (e.g., 'ibm-storage-scale')."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "List of availability zone names or IDs within the selected region for multi-zone deployment."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = false
  description = "CIDR block for the VPC that will be automatically subdivided into address prefixes for each availability zone (e.g., '10.241.0.0/18')."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of CIDR blocks for compute cluster private subnets, one per availability zone."
}

variable "vpc_protocol_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of CIDR blocks for protocol node private subnets, one per availability zone."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of CIDR blocks for public subnets, one per availability zone. Set to null if no public subnets are needed."
}

variable "vpc_region" {
  type        = string
  description = "IBM Cloud region where VPC and all resources will be deployed (e.g., 'us-east', 'us-south', 'eu-de')."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of CIDR blocks for storage cluster private subnets, one per availability zone."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to be attached to all VPC resources."
}
