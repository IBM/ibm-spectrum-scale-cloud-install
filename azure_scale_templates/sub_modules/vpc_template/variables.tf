# variable "client_id" {
#   type        = string
#   description = "The Active Directory service principal associated with your account."
# }

# variable "client_secret" {
#   type        = string
#   description = "The password or secret for your service principal."
# }

# variable "tenant_id" {
#   type        = string
#   description = "The Active Directory tenant identifier, must provide when using service principals."
# }

# variable "subscription_id" {
#   type        = string
#   description = "The subscription ID to use."
# }

variable "vpc_location" {
  type        = string
  nullable    = true
  description = "The location/region of the vpc to create. Examples are East US, West US, etc."
}

# variable "resource_group_name" {
#   type        = string
#   description = "The name of a new resource group in which the resources will be created."
# }

variable "resource_prefix" {
  type        = string
  nullable    = true
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vpc_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "The CIDR block for the VPC."
}

variable "vpc_public_subnet_address_spaces" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks of public subnets."
}

variable "vpc_strg_priv_subnet_address_spaces" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks for storage cluster private subnets."
}

variable "vpc_comp_priv_subnet_address_spaces" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of cidr_blocks for compute cluster private subnets."
}

variable "strg_dns_domain" {
  type        = string
  nullable    = true
  default     = "strgscale.com"
  description = "Azure DNS domain name to be used for storage cluster."
}

variable "comp_dns_domain" {
  type        = string
  nullable    = true
  default     = "compscale.com"
  description = "Azure DNS domain name to be used for compute cluster."
}

variable "vpc_tags" {
  type        = map(string)
  nullable    = true
  default     = {}
  description = "The tags to associate with your network and subnets."
}

variable "storage_account_name" {
  type        = string
  nullable    = true
  default     = "spectrumscalestorageaccnt"
  description = "Name for the storage account."
}
