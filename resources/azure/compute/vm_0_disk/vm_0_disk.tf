/*
    Creates Azure Linux Virtual Machine with no data disks.
*/

variable "vm_name" {}
variable "image_publisher" {}
variable "image_offer" {}
variable "image_sku" {}
variable "image_version" {}
variable "resource_group_name" {}
variable "location" {}
variable "vm_size" {}
variable "subnet_id" {}
variable "login_username" {}
variable "proximity_placement_group_id" {}
variable "os_disk_caching" {}
variable "os_storage_account_type" {}
variable "user_public_key" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "dns_zone" {}
variable "availability_zone" {}

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "DOMAIN=\"${var.dns_zone}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
systemctl restart NetworkManager
EOF
}

data "template_cloudinit_config" "user_data64" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
}

resource "azurerm_network_interface" "itself" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.vm_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "itself" {
  name                         = var.vm_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  size                         = var.vm_size
  admin_username               = var.login_username
  network_interface_ids        = [azurerm_network_interface.itself.id]
  proximity_placement_group_id = var.proximity_placement_group_id
  zone                         = var.availability_zone

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

  custom_data = data.template_cloudinit_config.user_data64.rendered
}

output "instance_private_ips" {
  value = azurerm_linux_virtual_machine.itself.private_ip_address
}

output "instance_ids" {
  value = azurerm_linux_virtual_machine.itself.id
}