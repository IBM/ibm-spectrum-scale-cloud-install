variable "client_id" {
  type        = string
  description = "The Active Directory service principal associated with your account."
}

variable "client_secret" {
  type        = string
  description = "The password or secret for your service principal."
}

variable "tenant_id" {
  type        = string
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
}

variable "vnet_location" {
  type        = string
  description = "The location/region of the vnet to create. Examples are East US, West US, etc."
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "The address space that is used by the virtual network."
}

variable "vnet_public_subnets_address_space" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "List of address prefix to use for public subnets."
}

variable "vnet_storage_cluster_private_subnets_address_space" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "List of address prefix to use for storage cluster private subnets."
}

variable "vnet_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "Azure DNS domain name to be used for compute cluster."
}

variable "vnet_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "Azure DNS domain name to be used for storage cluster."
}

variable "vnet_create_separate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if separate private subnet to be created for compute cluster."
}

variable "vnet_compute_cluster_private_subnets_address_space" {
  type        = list(string)
  default     = ["10.0.3.0/24"]
  description = "List of cidr_blocks of compute private subnets."
}

variable "vnet_tags" {
  type        = map(string)
  default     = {}
  description = "The tags to associate with your network and subnets."
}
