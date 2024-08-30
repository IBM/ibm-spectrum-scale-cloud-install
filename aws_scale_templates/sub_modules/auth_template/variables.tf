variable "create_cloud_managed_auth" {
  type        = bool
  nullable    = false
  description = "Flag to represent if a cloud-managed auth service needs to be created or customer managed auth service needs to be created."
}

variable "ldap_image_ref" {
  type        = string
  default     = null
  nullable    = true
  description = "ID of AMI to use for provisioning the ldap instance."
}

variable "ldap_instance_boot_disk_type" {
  type        = string
  default     = null
  nullable    = true
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "ldap_instance_key_pair" {
  type        = string
  default     = null
  nullable    = true
  description = "The key pair to use to launch the ldap instance."
}

variable "ldap_instance_private_subnet" {
  type        = string
  default     = null
  nullable    = true
  description = "OpenLDAP private subnet."
}

variable "ldap_instance_type" {
  type        = string
  default     = null
  nullable    = true
  description = "Instance type to use for provisioning the ldap instance."
}

variable "ldap_public_ssh_port" {
  type        = number
  default     = null
  nullable    = true
  description = "Set the SSH port to use from desktop to the ldap."
}

variable "managed_ad_dns_name" {
  type        = string
  default     = null
  nullable    = true
  description = "Managed directory DNS name"
}

variable "managed_ad_password" {
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
  description = "Managed directory (AD) password"
}

variable "managed_ad_size" {
  type        = string
  default     = null
  nullable    = true
  description = "Managed directory (AD) size"
}

variable "managed_ad_subnet_refs" {
  type        = list(string)
  default     = []
  nullable    = true
  description = "Managed directory (AD) subnets (they must belong to two different availability zones)."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  default     = []
  nullable    = true
  description = "List of CIDRs that can access to the ldap. Example: 0.0.0.0/0"
}

variable "resource_prefix" {
  type        = string
  default     = null
  nullable    = true
  description = "Prefix is added to all resources that are created."
}

variable "vpc_dns_domain" {
  type        = string
  default     = null
  nullable    = true
  description = "DNS domain name to be used for ldap instance."
}

variable "vpc_forward_dns_zone" {
  type        = string
  default     = null
  nullable    = true
  description = "DNS zone name to be used for scale cluster (Ex: example-zone)."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id to be associated with the AD zone."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_reverse_dns_domain" {
  type        = string
  default     = null
  nullable    = true
  description = "DNS reverse domain (Ex: 10.in-addr.arpa)."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  default     = null
  nullable    = true
  description = "DNS reverse zone lookup to be used for scale cluster (Ex: example-zone-reverse)."
}
