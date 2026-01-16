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

variable "vm_name_prefix" {
  type        = string
  description = "Prefix is added to jump host resource that are created."
}

variable "vm_public_key" {
  type        = string
  description = "The key pair to use to launch the jump host."
}

variable "vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Instance type to use for provisioning the jump host virtual machine."
}

variable "image_publisher" {
  type        = string
  default     = "RedHat"
  description = "Specifies the publisher of the image used to create the jump host virtual machine."
}

variable "image_offer" {
  type        = string
  default     = "RHEL"
  description = "Specifies the offer of the image used to create the jump host virtual machine."
}

variable "image_sku" {
  type        = string
  default     = "8.2"
  description = "Specifies the SKU of the image used to create the jump host virtual machine."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the image used to create the jump host virtual machine."
}

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "os_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "using_direct_connection" {
  type        = bool
  default     = false
  description = "If true, will skip the jump/bastion host configuration."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of IDs of cluster private subnets."
}
