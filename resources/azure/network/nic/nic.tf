/*
    Creates new Azure NIC id's.
*/

variable "total_nics" {
    type = string
}
variable "nic_name_prefix" {
    type = string
}
variable "nic_config_prefix" {
    type = string
}
variable "location" {
    type = string
}
variable "resource_group_name" {
    type = string
}
variable "subnet_id" {
    type = string
}


resource "azurerm_network_interface" "nic" {
    count                     = var.total_nics
    name                      = "${var.nic_name_prefix}-${count.index+1}"
    location                  = var.location
    resource_group_name       = var.resource_group_name

    ip_configuration {
        name                          = "${var.nic_config_prefix}-${count.index+1}"
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = "Dynamic"
    }
}

output "nic_ids" {
    value = azurerm_network_interface.nic.*.id
}

output "nic_ipaddress" {
    value = azurerm_network_interface.nic.*.private_ip_address
}
