variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."

  validation {
    condition     = contains(["Storage-only", "Compute-only", "Combined-compute-storage"], var.cluster_type)
    error_message = "The cluster_type must be one of: Storage-only, Compute-only, Combined-compute-storage."
  }
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
  description = "The IBM Cloud platform API key needed for authentication."
}

variable "dns_service_instance_id" {
  type        = string
  default     = null
  description = "IBM Cloud DNS Service Instance Id. If not provided, a new DNS service instance will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created. Example: ibm-storage-scale"
}

variable "resource_group_id" {
  type        = string
  nullable    = false
  description = "ID of the resource group where DNS service instance will be created (only used if dns_service_instance_id is not provided)."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = null
  description = "IBM Cloud DNS zone name for compute cluster. Required only when deploying compute nodes."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC name to be associated with the DNS zone."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The IBM Cloud region where resources will be created. Examples: us-south, us-east, eu-gb, eu-de."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = null
  description = "IBM Cloud DNS zone name for storage cluster. Required only when deploying storage nodes."
}

variable "vpc_protocol_cluster_dns_domain" {
  type        = string
  default     = null
  description = "IBM Cloud DNS zone name for protocol cluster. If not provided, protocol nodes will use storage cluster DNS zone."
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to be attached to DNS resources."
}
