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

variable "vpc_region" {
  type        = string
  description = "The location in which the resources will be created. Examples are East US, West US, etc."
}

variable "image_publisher" {
  type        = string
  description = "Name of the publisher to use for your base image (Azure Marketplace Images only)."
}

variable "image_offer" {
  type        = string
  description = "Name of the publisher's offer to use for your base image (Azure Marketplace Images only)."
}

variable "image_sku" {
  type        = string
  description = "SKU of the image offer to use for your base image (Azure Marketplace Images only)."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "The image version to use for your base image"
}

variable "resource_prefix" {
  type        = string
  description = "Specify the managed image name where the result of the Packer build will be saved."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}

variable "instance_type" {
  type        = string
  description = "Size of the VM used for building."
}

variable "storage_accountname" {
  type        = string
  description = "Azure storage account that contains container with IBM Spectrum Scale rpm(s)."
}

variable "package_repository" {
  type        = string
  description = "Data storage container which contains IBM Spectrum Scale rpm(s)."
}

variable "volume_size" {
  type        = string
  description = "The size of the OS disk, in GB."
}

variable "ssh_username" {
  type        = string
  description = "The username to connect to SSH with."
}

variable "vpc_ref" {
  type        = string
  description = "The vnet name to use for deploy packer instances."
}

variable "scale_version" {
  type        = string
  description = "The username to connect to SSH with."
}

variable "vpc_subnet_id" {
  type        = string
  description = "The vnet subnet to use for deploy packer instances."
}

variable "manifest_path" {
  type        = string
  description = "The manifest path."
}
