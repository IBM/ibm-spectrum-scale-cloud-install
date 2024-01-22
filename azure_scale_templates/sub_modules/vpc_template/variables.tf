variable "client_id" {
  type        = string
  description = "The Active Directory service principal associated with your account."
}

variable "client_secret" {
  type        = string
  description = "The password or secret for your service principal."
}

variable "tenant_id" {
  type        = string
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
}

variable "vpc_region" {
  type        = string
  nullable    = true
  description = "The location/region of the vpc to create. Examples are East US, West US, etc."
}

variable "resource_prefix" {
  type        = string
  nullable    = true
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = true
  default     = null
  description = "The CIDR block for the vpc."
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
  description = "List of cidr_blocks for storage cluster private subnets."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks for compute cluster private subnets."
}

variable "strg_dns_domain" {
  type        = string
  nullable    = true
  default     = "strgscale.com"
  description = "Azure DNS domain name to be used for storage cluster."
}

variable "comp_dns_domain" {
  type        = string
  nullable    = true
  default     = "compscale.com"
  description = "Azure DNS domain name to be used for compute cluster."
}

variable "vpc_tags" {
  type        = map(string)
  nullable    = true
  default     = {}
  description = "The tags to associate with your network and subnets."
}
