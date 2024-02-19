variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
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

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of public subnets."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of storage cluster private subnets."
}

variable "vpc_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the VPC"
}
