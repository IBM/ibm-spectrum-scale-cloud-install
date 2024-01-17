variable "resource_group_name" {
  type        = string
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  default     = "imagecreator"
  description = "Prefix is added to all resources that are created."
}

variable "image_publisher" {
  default     = "RedHat"
  description = "Specifies the publisher of the image used to create the virtual machines."
}

variable "image_offer" {
  type        = string
  default     = "RHEL"
  description = "Specifies the offer of the image used to create the compute cluster virtual machines."
}

variable "image_sku" {
  type        = string
  default     = "8_7"
  description = "Specifies the SKU of the image used to create the compute cluster virtual machines."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the image used to create the compute cluster virtual machines."
}

variable "vpc_region" {
  type        = string
  default     = "eastus"
  description = "The location/region of the vnet to create. Examples are East US, West US, etc."
}

variable "vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "The virtual machine size."
}

variable "subnet_id" {
  type        = string
  description = "ID of image public subnets."
}

variable "login_username" {
  type        = string
  default     = "azureuser"
  description = "The username of the local administrator used for the Virtual Machine."
}

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "os_storage_account_type" {
  description = "Type of storage account which should back this the internal OS disk."
}

variable "user_public_key" {
  type        = string
  description = "The SSH public key to use to launch the image host."
}

variable "user_private_key" {
  type        = string
  description = "The SSH private key to use to launch the image host."
}

variable "dns_zone" {
  type        = string
  description = "Image VM DNS zone."
}

variable "availability_zone" {
  type        = number
  description = "availability zones id in the region/location."
}

variable "skip_cli_generalize_vm" {
  type        = bool
  default     = false
  description = "Skips az cli generalize steps."
}

variable "createimage" {
  type        = bool
  default     = false
  description = "Storage cluster DNS zone."
}

variable "storage_account" {
  type        = string
  description = "Type of storage account which should back this the internal OS disk."
}

variable "blob_container" {
  type        = string
  description = "Storage Blob container name."
}

variable "gpfs_version" {
  type        = string
  description = "GPFS rpm version."
}

variable "zimon_os_dir" {
  type        = string
  description = "zimon rpm os dir name."
}