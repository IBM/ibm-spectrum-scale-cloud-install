variable "vpc_region" {
  type        = string
  description = "IBM Cloud VPC region where the resources will be created."
}

variable "vpc_zones" {
  type        = list(string)
  description = "IBM Cloud VPC zone names."
}

variable "stack_name" {
  type        = string
  default     = "spectrum-scale"
  description = "IBM Cloud stack name (keep all lower case)."
}

variable "vpc_addr_prefixes" {
  type        = list(string)
  default     = ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"]
  description = "IBM Cloud VPC address prefixes."
}

variable "vpc_compute_cluster_cidr_block" {
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"]
  description = "IBM Cloud VPC primary compute subnet CIDR blocks."
}

variable "vpc_storage_cluster_cidr_block" {
  type        = list(string)
  default     = ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"]
  description = "IBM Cloud VPC primary storage subnet CIDR blocks."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if separate subnets to be created for compute and storage clusters."
}

variable "dns_domains" {
  type        = list(string)
  default     = ["strgscale.com", "compscale.com"]
  description = "IBM Cloud DNS domain names."
}

variable "resource_grp_id" {
  type        = string
  description = "IBM Cloud resource group id."
}
