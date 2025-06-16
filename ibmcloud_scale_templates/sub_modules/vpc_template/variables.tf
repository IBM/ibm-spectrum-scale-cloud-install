variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "create_resource_group" {
  type        = bool
  nullable    = true
  description = "Create resource group."
}

variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The IBM Cloud platform API key."
}

variable "resource_group_name" {
  type        = string
  nullable    = true
  description = "The name of a resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created. Example: ibm-storage-scale"
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "A list of availability zones names or ids in the region."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = false
  description = "The CIDR block for the VPC. Example: 10.0.0.0/16"
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_protocol_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of protocol private subnets."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of public subnets."
}

variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of storage cluster private subnets."
}
