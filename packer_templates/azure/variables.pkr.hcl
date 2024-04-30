variable "client_id" {
  type        = string
  description = "The Active Directory service principal associated with your builder"
}

variable "client_secret" {
  type        = string
  description = "The password or secret for your service principal."
}

variable "image_description" {
  type        = string
  default     = "IBM Storage Scale Image"
  description = "The description to set for the resulting image."
}

variable "image_offer" {
  type        = string
  default     = null
  description = "Name of the publisher's offer to use for your base image (Azure Marketplace Images only)."
}

variable "image_publisher" {
  type        = string
  default     = null
  description = "Name of the publisher to use for your base image (Azure Marketplace Images only)."
}

variable "image_sku" {
  type        = string
  default     = null
  description = "SKU of the image offer to use for your base image (Azure Marketplace Images only)."
}

variable "image_url" {
  type        = string
  default     = null
  description = "URL to a custom VHD to use for your base image. If this value is set, image_publisher, image_offer, image_sku should not be set."
}

variable "image_version" {
  type        = string
  default     = null
  description = "Specific version of an OS/base image to boot from."
}

variable "install_protocols" {
  type        = string
  default     = "*"
  description = "Flag to determine whether to install protocol packages or not."
}

variable "instance_type" {
  type        = string
  default     = "Standard_D2ds_v4"
  description = "Size of the VM used for building."
}

variable "managed_image_name" {
  type        = string
  default     = "ibm-storage-scale"
  description = "Specify the managed image name where the result of the Packer build will be saved."
}

variable "managed_image_resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}

variable "manifest_path" {
  type    = string
  default = ""
}

locals {
  manifest_path = var.manifest_path != "" ? var.manifest_path : path.root
}

variable "scale_version" {
  type        = string
  default     = null
  description = "IBM Storage Scale version."
}

variable "ssh_bastion_host" {
  type        = string
  default     = ""
  description = "A bastion host to use for the SSH connection."
}

variable "ssh_bastion_port" {
  type        = string
  default     = "22"
  description = "The port of the bastion host."
}

variable "ssh_bastion_private_key_file" {
  type        = string
  default     = ""
  description = "Path to a private key file to use to authenticate with the bastion host."
}

variable "ssh_bastion_username" {
  type        = string
  default     = ""
  description = "The username to connect to the bastion host."
}

variable "ssh_port" {
  type        = string
  default     = "22"
  description = "The port to connect to instance via SSH."
}

variable "ssh_username" {
  type        = string
  default     = "azureuser"
  description = "The username to connect to SSH with."
}

variable "storage_account_url" {
  type        = string
  default     = null
  description = "Storage account URL that hosts the gpfs repository."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
}

variable "tenant_id" {
  type        = string
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "volume_size" {
  type        = string
  default     = "200"
  description = "The size of the volume, in GiB."
}

variable "volume_type" {
  type        = string
  default     = "Standard_LRS"
  description = "The storage account type. Standard_LRS or Premium_LRS."
}

variable "vpc_ref" {
  type        = string
  default     = null
  description = "The VPC id you want to use for building AMI."
}

variable "vpc_subnet_id" {
  type        = string
  default     = null
  description = "The subnet ID to use for the instance."
}
