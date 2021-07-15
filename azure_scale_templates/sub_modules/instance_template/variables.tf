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

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "create_separate_namespaces" {
  type        = bool
  default     = true
  description = "Flag to select if separate namespace needs to be created for compute instances."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Number of Azure instances (vms) to be launched for compute cluster."
}

variable "compute_cluster_key_pair" {
  type        = string
  description = "The key pair to use to launch the compute cluster host."
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Number of Azure instances (vms) to be launched for storage cluster."
}

variable "storage_cluster_key_pair" {
  type        = string
  description = "The key pair to use to launch the storage cluster host."
}

variable "compute_cluster_vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_image_publisher" {
  type        = string
  default     = "RedHat"
  description = "Specifies the publisher of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_image_offer" {
  type        = string
  default     = "RHEL"
  description = "Specifies the offer of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_image_sku" {
  type        = string
  default     = "8-LVM"
  description = "Specifies the SKU of the image used to create the compute cluster virtual machines."
}
variable "compute_cluster_image_version" {
  type        = string
  default     = "8.1.20200318"
  description = "Specifies the version of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "compute_cluster_os_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "compute_cluster_login_username" {
  type        = string
  default     = "azureuser"
  description = "The username of the local administrator used for the Virtual Machine."
}
