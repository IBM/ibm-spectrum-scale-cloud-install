variable "client_id" {
  type        = string
  description = "The Active Directory service principal associated with your builder"
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

variable "location" {
  type        = string
  description = "The location in which the resources will be created. Examples are East US, West US, etc."
}

variable "image_publisher" {
  type        = string
  default     = null
  description = "Name of the publisher to use for your base image (Azure Marketplace Images only)."
}

variable "image_offer" {
  type        = string
  default     = null
  description = "Name of the publisher's offer to use for your base image (Azure Marketplace Images only)."
}

variable "image_sku" {
  type        = string
  default     = null
  description = "SKU of the image offer to use for your base image (Azure Marketplace Images only)."
}

variable "image_version" {
  type        = string
  default     = null
  description = " "
}

variable "image_url" {
  type        = string
  default     = null
  description = "URL to a custom VHD to use for your base image. If this value is set, image_publisher, image_offer, image_sku should not be set."
}

variable "user_assigned_managed_identities" {
  type        = list(string)
  description = "A list of one or more fully-qualified resource IDs of user assigned managed identities to be configured on the VM."
}

variable "managed_image_name" {
  type        = string
  default     = "scale-image"
  description = "Specify the managed image name where the result of the Packer build will be saved."
}

variable "managed_image_resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}

variable "vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Size of the VM used for building."
}

variable "storage_accountname" {
  type        = string
  description = "Azure storage account that contains container with IBM Spectrum Scale rpm(s)."
}

variable "spectrumscale_container" {
  type        = string
  description = "Data storage container which contains IBM Spectrum Scale rpm(s)."
}

variable "os_disk_size_gb" {
  type        = string
  default     = "100"
  description = "The size of the OS disk, in GB."
}

variable "ssh_username" {
  type        = string
  default     = "azureuser"
  description = "The username to connect to SSH with."
}
