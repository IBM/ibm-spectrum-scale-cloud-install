variable "client_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Active Directory service principal associated with your account."
}

variable "client_secret" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password or secret for your service principal."
}

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

variable "resource_group_name" {
  type        = string
  nullable    = true
  description = "The name of a new resource group in which the resources will be created."
}

variable "subscription_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The subscription ID to use."
}

variable "tenant_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VNet id to be associated with the DNS zone (Ex: /subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue)."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = false
  description = "Private DNS zone name."
}

variable "vpc_storage_cluster_dns_zone" {
  type        = string
  nullable    = false
  description = "Private DNS zone name."
}
