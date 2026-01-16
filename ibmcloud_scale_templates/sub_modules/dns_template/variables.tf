variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "create_dns_zone" {
  type        = bool
  nullable    = false
  description = "Flag to represent if a new private DNS zone needs to be created or reused."
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

variable "vpc_compute_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "IBM Cloud DNS zone name."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  nullable    = false
  description = "Flag to select if separate private subnet to be created for compute cluster."
}

variable "vpc_dns_tags" {
  type        = list(string)
  nullable    = true
  description = "Additional tags for the DNS zone."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id to be associated with the DNS zone."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_storage_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "IBM Cloud DNS zone name."
}
