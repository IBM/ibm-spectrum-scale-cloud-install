variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "credential_json_path" {
  type        = string
  nullable    = false
  description = "The path of a GCP service account key file in JSON format."
}

variable "project_id" {
  type        = string
  nullable    = false
  description = "GCP project ID to manage resources."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created. Example: ibm-storage-scale"
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = false
  description = "The CIDR block for the VPC."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_description" {
  type        = string
  nullable    = true
  description = "Description of VPC."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "Range of internal addresses."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "GCP region where the resources will be created."
}

variable "vpc_routing_mode" {
  type        = string
  nullable    = false
  description = "Network-wide routing mode to use (valid: REGIONAL, GLOBAL)."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of storage cluster private subnets."
}
