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

variable "vpc_location" {
  type        = string
  nullable    = true
  default     = null
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

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "image_publisher" {
  type        = string
  default     = "RedHat"
  description = "Specifies the publisher of the image used to create the storage cluster virtual machines."
}

variable "image_offer" {
  type        = string
  default     = "RHEL"
  description = "Specifies the offer of the image used to create the storage cluster virtual machines."
}

variable "image_sku" {
  type        = string
  default     = "8.2"
  description = "Specifies the SKU of the image used to create the storage cluster virtual machines."
}

variable "bastion_instance_type" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the image used to create the compute cluster virtual machines."
}

variable "bastion_login_username" {
  type        = string
  default     = "azureuser"
  description = "Bastion default login username"
}

variable "bastion_public_subnet_ids" {
  type        = list(string)
  description = "List of IDs of bastion subnets."
  default     = null
}

variable "os_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "user_public_key" {
  type        = string
  description = "The SSH public key to use to launch the image vm."
}

variable "azure_bastion_service" {
  type        = bool
  default     = false
  description = "Enable Azure Bastion service"
}
