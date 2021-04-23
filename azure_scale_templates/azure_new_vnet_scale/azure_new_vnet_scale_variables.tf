variable "location" {
  type        = string
  description = "Azure location where the resources will be created."
}
variable "resource_group_name" {
  type        = string
  default     = "Spectrum-Scale-rg"
  description = "Azure resource group name, will be used for tagging resources."
}
variable "availability_zones" {
  type        = list(string)
  default     = [1, 2]
  description = "List of Azure Availability Zones."
}
variable "vnet_name" {
  type        = string
  default     = "Spectrum-Scale-vnet"
  description = "Azure virtual network name."
}
variable "vnet_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Address space that is used for virtual network."
}
variable "bastion_subnet_name" {
  type    = string
  default = "AzureBastionSubnet"
}
variable "public_subnet_address_prefix" {
  type        = string
  default     = "10.0.1.0/27"
  description = "Address space that is used for public subnet."
}

variable "delete_os_disk_on_termination" {
  type        = bool
  default     = true
  description = "Whether OS disk to be deleted on VM termination"
}
variable "delete_data_disks_on_termination" {
  type        = bool
  default     = false
  description = "Whether data disk to be deleted on VM termination"
}

variable "vm_hostname" {
  type        = string
  default     = "spectrumscale"
  description = "Local name of the VM."
}

variable "vm_admin_username" {
  type        = string
  default     = "azureuser"
  description = "Name of the administrator to access the VM."
}

variable "vm_sshlogin_pubkey_path" {
  type        = string
  description = "SH public key local path, will be used to login VM."
}

variable "total_compute_vms" {
  type        = string
  default     = 2
  description = "Number of VM's to be launched for compute nodes."
}

variable "compute_vm_os_publisher" {
  type        = string
  description = "Name of the publisher of the image that you want to deploy for compute VMs."
}

variable "compute_vm_os_offer" {
  type        = string
  description = "Name of the offer of the image that you want to deploy for compute VMs."
}

variable "compute_vm_os_sku" {
  type        = string
  description = "Sku of the image that you want to deploy for compute VMs"
}

variable "compute_vm_size" {
  type        = string
  description = "Size of the virtual machine that will be deployed for compute VMs."
}

variable "total_storage_vms" {
  type        = string
  default     = 2
  description = "Number of VM's to be launched for storage nodes"
}

variable "storage_vm_os_publisher" {
  type        = string
  description = "Name of the publisher of the image that you want to deploy for storage VMs."
}

variable "storage_vm_os_offer" {
  type        = string
  description = "Name of the offer of the image that you want to deploy for storage VMs."
}

variable "storage_vm_os_sku" {
  type        = string
  description = "Sku of the image that you want to deploy for storage VMs."
}

variable "storage_vm_size" {
  type        = string
  description = "Size of the virtual machine that will be deployed for storage VMs."
}

variable "vm_osdisk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Type of Caching which should be used for the OS Disk."
}

variable "vm_osdisk_create_option" {
  type        = string
  default     = "FromImage"
  description = "Copy a Platform Image."
}

variable "vm_osdisk_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage to use for the OS disk. Possible values: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS"
}

variable "total_disks_per_vm" {
  type        = string
  default     = 1
  description = "Number of data disks to be attached to each storage VM."
}

variable "data_disk_size" {
  type        = string
  default     = 500
  description = "Data disk size in GiB."
}

variable "data_disk_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage to use for the data disk. Possible values: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS"
}

variable "data_disk_create_option" {
  type        = string
  default     = "Empty"
  description = "Create an empty managed disk"
}

variable "data_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Caching requirements for the Data Disk. Possible values: None, ReadOnly and ReadWrite."
}
