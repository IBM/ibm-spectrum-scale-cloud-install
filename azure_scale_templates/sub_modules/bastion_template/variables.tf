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

variable "vpc_region" {
  type        = string
  nullable    = true
  default     = null
  description = "The location/region of the vnet to create. Examples are East US, West US, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "A list of availability zones ids in the region/location."
}

variable "vpc_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "VPC id to where bastion needs to deploy."
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  default     = "ibm-storage-scale"
  description = "Prefix is added to all resources that are created."
}

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "image_publisher" {
  type        = string
  nullable    = true
  default     = null
  description = "Specifies the publisher of the image used to create the storage cluster virtual machines."
}

variable "image_offer" {
  type        = string
  nullable    = true
  default     = null
  description = "Specifies the offer of the image used to create the storage cluster virtual machines."
}

variable "image_sku" {
  type        = string
  nullable    = true
  default     = null
  description = "Specifies the SKU of the image used to create the storage cluster virtual machines."
}

variable "bastion_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the image used to create the compute cluster virtual machines."
}

variable "bastion_login_username" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion default login username"
}

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of IDs of bastion subnets."
}

variable "bastion_boot_disk_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "bastion_key_pair" {
  type        = string
  nullable    = true
  default     = null
  description = "The SSH keypair to launch the bastion vm."
}

variable "bastion_ssh_user_name" {
  type        = string
  nullable    = true
  default     = null
  description = "The Bastion SSH username to launch bastion vm."
}

variable "azure_bastion_service" {
  type        = bool
  default     = false
  description = "Enable Azure Bastion service"
}

variable "remote_cidr_blocks" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of CIDRs that can access to the bastion."
}

variable "auto_scale_vm_count" {
  type        = number
  nullable    = true
  default     = null
  description = "Auto scaling virtual machine count."
}