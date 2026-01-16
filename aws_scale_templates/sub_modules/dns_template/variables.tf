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

variable "vpc_compute_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "Route53 DNS zone name/id (incase of new creation use name, incase of association use id)."
}

variable "vpc_compute_cluster_dns_zone_description" {
  type        = string
  nullable    = true
  description = "DNS zone description"
}

variable "vpc_dns_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the DNS zone"
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id to be associated with the DNS zone."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = false
  description = "Route53 DNS zone/id (incase of new creation use name, incase of association use id)."
}

variable "vpc_reverse_dns_zone_description" {
  type        = string
  nullable    = true
  description = "Route53 DNS zone description."
}

variable "vpc_storage_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "Route53 DNS zone name/id (incase of new creation use name, incase of association use id)."
}

variable "vpc_storage_cluster_dns_zone_description" {
  type        = string
  nullable    = true
  description = "DNS zone description"
}
