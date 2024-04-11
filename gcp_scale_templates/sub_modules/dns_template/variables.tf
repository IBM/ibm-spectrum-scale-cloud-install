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

variable "vpc_compute_cluster_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP cloud dns zone name to be used for compute cluster."
}

variable "vpc_compute_cluster_dns_zone_description" {
  type        = string
  nullable    = true
  description = "DNS zone description."
}

variable "vpc_compute_cluster_forward_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP cloud dns zone name to be used for scale cluster (Ex: example-zone)."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "GCP VPC name"
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "GCP region where the resources will be created."
}

variable "vpc_reverse_dns_name" {
  type        = string
  nullable    = false
  description = "GCP cloud dns reverse dns name (Ex: 10.in-addr.arpa)."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP cloud dns reverse zone lookup to be used for scale cluster (Ex: example-zone-reverse)."
}

variable "vpc_reverse_dns_zone_description" {
  type        = string
  nullable    = true
  description = "Reverse DNS zone description."
}

variable "vpc_storage_cluster_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP cloud dns zone name to be used for storage cluster."
}

variable "vpc_storage_cluster_dns_zone_description" {
  type        = string
  nullable    = true
  description = "DNS zone description."
}

variable "vpc_storage_cluster_forward_dns_zone" {
  type        = string
  nullable    = true
  description = "GCP cloud dns zone name to be used for scale cluster (Ex: example-zone)."
}
