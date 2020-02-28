variable "location" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "availability_zones" {
    type = list(string)
}

variable "delete_os_disk_on_termination" {
    type = bool
    default = true
}

variable "delete_data_disks_on_termination" {
    type = bool
    default = true
}

variable "vm_admin_username" {
    type    = string
    default = "azureuser"
}

variable "vm_sshlogin_pubkey_path" {
    type = string
}

variable "total_compute_vms" {
    type = string
}

variable "all_compute_nic_ids" {
    type = list(string)
}

variable "compute_vm_os_publisher" {
    type = string
}

variable "compute_vm_os_offer" {
    type = string
}

variable "compute_vm_os_sku" {
    type = string
}

variable "compute_vm_size" {
    type = string
}

variable "total_storage_vms" {
    type = string
}

variable "all_storage_nic_ids" {
    type = list(string)
}

variable "storage_vm_os_publisher" {
    type = string
}

variable "storage_vm_os_offer" {
    type = string
}

variable "storage_vm_os_sku" {
    type = string
}

variable "storage_vm_size" {
    type = string
}

variable "vm_osdisk_caching" {
    type    = string
    default = "ReadWrite"
}

variable "vm_osdisk_create_option" {
    type    = string
    default = "FromImage"
}

variable "vm_osdisk_type" {
    type    = string
    default = "Standard_LRS"
}

variable "total_disks_per_vm" {
    type = string
}

variable "data_disk_size" {
    type = string
}

variable "data_disk_type" {
    type    = string
    default = "Empty"
}

variable "data_disk_create_option" {
    type    = string
    default = "Empty"
}

variable "data_disk_caching" {
    type    = string
    default = "ReadWrite"
}

variable "private_zone_vnet_link_name" {
    type = string
}
