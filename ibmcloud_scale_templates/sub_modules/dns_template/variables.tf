variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "resource_tags" {
  type        = list(string)
  description = "IBM Cloud resource tags."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if separate private subnet to be created for compute cluster."
}

variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id to be associated with the DNS zone."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "IBM Cloud DNS domain name to be used for storage cluster."
}
