/*
    Creates specified number of Azure data disk(s) per Az.
*/

variable "total_disks_count" {
    type = string
}
variable "resource_group_name" {
    type = string
}
variable "location" {
    type = string
}
variable "availability_zones" {
    type = list(string)
}
variable "data_disk_name_prefix" {
    type = string
}
variable "data_disk_size" {
    type = string
}
variable "data_disk_create_option" {
    type = string
}
variable "data_disk_type" {
    type = string
}


resource "azurerm_managed_disk" "data_disk" {
    count                = var.total_disks_count
    name                 = "${var.data_disk_name_prefix}${count.index+1}"
    location             = var.location
    resource_group_name  = var.resource_group_name
    storage_account_type = var.data_disk_type
    create_option        = var.data_disk_create_option
    disk_size_gb         = var.data_disk_size
    zones                = [element(var.availability_zones, count.index)]
}

output "disk_ids" {
    value = azurerm_managed_disk.data_disk.*.id
}

output "disk_names" {
    value = azurerm_managed_disk.data_disk.*.name
}

output "disk_names_by_availability_zone" {
    # Result is a map from availability zone to instance ids, such as:
    #  {"1": ["d1", "d3"]}
    value = {
    for disk in azurerm_managed_disk.data_disk:
    disk.zones[0] => disk.name...
    }
}

output "disk_ids_by_availability_zone" {
    # Result is a map from availability zone to instance ids, such as:
    #  {"1": ["vm-1", "vm-3"], "2": ["vm-2", "vm-4"]}
    value = {
    for disk in azurerm_managed_disk.data_disk:
    disk.zones[0] => disk.id...
    }
}
