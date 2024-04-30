variable "client_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Active Directory service principal associated with your account."
}

variable "client_secret" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password or secret for your service principal."
}

variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "create_resouce_group" {
  type        = bool
  nullable    = true
  description = "Creates resouce group."
}

variable "resource_group_name" {
  type        = string
  nullable    = true
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created. Example: ibm-storage-scale"
}

variable "subscription_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The subscription ID to use."
}

variable "tenant_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "vpc_bastion_service_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of CIDR blocks for azure fully managed bastion subnet."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = false
  description = "The CIDR block for the vpc."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks for compute cluster private subnets."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of public subnets."
}

variable "vpc_region" {
  type        = string
  nullable    = true
  description = "The location/region of the vpc to create. Examples are East US, West US, etc."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks for storage cluster private subnets."
}

variable "vpc_tags" {
  type        = map(string)
  nullable    = true
  description = "The tags to associate with your network and subnets."
}
