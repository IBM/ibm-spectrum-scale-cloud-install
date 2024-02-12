variable "vpc_region" {
  type        = string
  nullable    = false
  description = "GCP region where the resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created."
}

variable "project_id" {
  type        = string
  nullable    = false
  description = "GCP project ID to manage resources."
}

variable "credential_json_path" {
  type        = string
  nullable    = false
  description = "The path of a GCP service account key file in JSON format."
}

variable "vpc_routing_mode" {
  type        = string
  nullable    = false
  description = "Network-wide routing mode to use (valid: REGIONAL, GLOBAL)."
}

variable "vpc_description" {
  type        = string
  nullable    = true
  description = "Description of VPC."
}

variable "vpc_cidr_block" {
  type        = string
  nullable    = false
  description = "The CIDR block for the VPC."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "Range of internal addresses."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  nullable    = true
  description = "List of cidr_blocks of storage cluster private subnets."
}
