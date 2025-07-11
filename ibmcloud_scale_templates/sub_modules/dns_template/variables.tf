variable "ibmcloud_api_key" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The IBM Cloud platform API key."
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "resource_prefix" {
  type        = string
  description = "Prefix is added to all resources that are created."
}

variable "vpc_dns_tags" {
  type        = list(string)
  nullable    = true
  description = "Additional tags for the DNS zone."
}

variable "vpc_compute_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "IBM Cloud DNS zone name."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id to be associated with the DNS zone."
}

variable "vpc_storage_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "IBM Cloud DNS zone name."
}
