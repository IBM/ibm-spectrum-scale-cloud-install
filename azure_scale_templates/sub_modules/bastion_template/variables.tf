variable "azure_bastion_service" {
  type        = bool
  nullable    = true
  description = "Enable Azure Bastion service"
}

variable "bastion_boot_disk_type" {
  type        = string
  nullable    = false
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "bastion_instance_type" {
  type        = string
  nullable    = false
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "bastion_ssh_key_path" {
  type        = string
  nullable    = false
  description = "SSH public key local path, will be used to login bastion instance."
}

variable "bastion_ssh_user_name" {
  type        = string
  nullable    = false
  description = "The Bastion SSH username to launch bastion vm."
}

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

variable "image_offer" {
  type        = string
  nullable    = false
  description = "Specifies the offer of the image used to create the storage cluster virtual machines."
}

variable "image_publisher" {
  type        = string
  nullable    = false
  description = "Specifies the publisher of the image used to create the storage cluster virtual machines."
}

variable "image_sku" {
  type        = string
  nullable    = false
  description = "Specifies the SKU of the image used to create the storage cluster virtual machines."
}

variable "image_version" {
  type        = string
  nullable    = false
  description = "Specifies the version of the image used to create the compute cluster virtual machines."
}

variable "nsg_rule_start_index" {
  type        = number
  default     = 100
  description = "Specifies the network security group rule priority start index."
}

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "remote_cidr_blocks" {
  type        = list(string)
  nullable    = false
  description = "List of CIDRs that can access to the bastion."
}

variable "resource_group_name" {
  type        = string
  nullable    = false
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  default     = "ibm-storage-scale"
  description = "Prefix is added to all resources that are created."
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

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  nullable    = false
  description = "List of IDs of bastion subnets."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "A list of availability zones ids in the region/location."
}

variable "vpc_network_security_group_ref" {
  type        = string
  nullable    = false
  description = "VNet network security group id/reference."
}

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id to where bastion needs to deploy."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The location/region of the vnet to create. Examples are East US, West US, etc."
}
