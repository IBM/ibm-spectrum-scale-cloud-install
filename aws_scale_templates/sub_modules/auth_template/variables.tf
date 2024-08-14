variable "create_cloud_managed_auth" {
  type        = bool
  nullable    = false
  description = "Flag to represent if a cloud-managed auth service needs to be created or customer managed auth service needs to be created."
}

variable "managed_ad_dns_name" {
  type        = string
  nullable    = true
  description = "Managed directory DNS name"
}

variable "managed_ad_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "Managed directory (AD) password"
}

variable "managed_ad_size" {
  type        = string
  nullable    = true
  description = "Managed directory (AD) size"
}

variable "managed_ad_subnet_refs" {
  type        = list(string)
  nullable    = true
  description = "Managed directory (AD) subnets ()."
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
