variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP region where the resources will be created."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "project_id" {
  type        = string
  nullable    = true
  default     = null
  description = "GCP project ID to manage resources."
}

variable "credential_json_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "vpc_routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "Network-wide routing mode to use (valid: REGIONAL, GLOBAL)."
}

variable "vpc_description" {
  type        = string
  default     = "This VPC is used by IBM Spectrum Scale"
  description = "Description of VPC."
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
  description = "Range of internal addresses."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of storage cluster private subnets."
}
