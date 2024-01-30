/*
  Azure Bastion host
*/

variable "vm_count" {}
variable "vm_name_prefix" {}
variable "image_publisher" {}
variable "image_offer" {}
variable "image_sku" {}
variable "image_version" {}
variable "resource_group_name" {}
variable "location" {}
variable "vm_size" {}
variable "subnet_ids" {}
variable "login_username" {}
variable "proximity_placement_group_id" {}
variable "os_disk_caching" {}
variable "os_storage_account_type" {}
variable "user_public_key" {}

resource "azurerm_public_ip" "itself" {
  count               = var.vm_count
  name                = format("%s-public-ip", var.vm_name_prefix)
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "itself" {
  count               = var.vm_count
  name                = format("%s-nic", var.vm_name_prefix)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = format("%s-ip-config", var.vm_name_prefix)
    subnet_id                     = element(var.subnet_ids, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.itself[*].id, count.index)
  }
}

resource "azurerm_linux_virtual_machine" "itself" {
  count                        = var.vm_count
  name                         = format("%s-%s", var.vm_name_prefix, count.index + 1)
  resource_group_name          = var.resource_group_name
  location                     = var.location
  size                         = var.vm_size
  admin_username               = var.login_username
  network_interface_ids        = [element(azurerm_network_interface.itself[*].id, count.index)]
  proximity_placement_group_id = var.proximity_placement_group_id

  admin_ssh_key {
    username   = var.login_username
    public_key = file(var.user_public_key)
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}

output "instance_public_ips" {
  value = azurerm_linux_virtual_machine.itself[*].public_ip_address
}

output "instance_private_ips" {
  value = azurerm_linux_virtual_machine.itself[*].private_ip_address
}

output "instance_ids" {
  value = azurerm_linux_virtual_machine.itself[*].id
}
