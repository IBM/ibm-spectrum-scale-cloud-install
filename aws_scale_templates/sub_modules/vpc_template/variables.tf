variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = true
  default     = null
  description = "The CIDR block for the VPC."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of public subnets."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of storage cluster private subnets."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  nullable    = true
  default     = null
  description = "Flag to select if separate private subnet to be created for compute cluster."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the VPC"
}
