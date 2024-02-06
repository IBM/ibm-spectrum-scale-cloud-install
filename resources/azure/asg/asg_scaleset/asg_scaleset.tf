/*
  Creates and manages Azure Virtual Machine scale set.
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
variable "subnet_id" {}
variable "login_username" {}
variable "os_disk_caching" {}
variable "os_storage_account_type" {}
variable "bastion_key_pair" {}

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
systemctl restart NetworkManager
systemctl start sshd
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

# Gets Azure ssh keypair data
data "azurerm_ssh_public_key" "itself" {
  name                = var.bastion_key_pair
  resource_group_name = "spectrum-scaleprvn2"
}

# Manages a Public IP Prefix
resource "azurerm_public_ip_prefix" "itself" {
  name                = "${var.vm_name_prefix}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Creates azure linux virtual machine with uniform mode
resource "azurerm_linux_virtual_machine_scale_set" "itself" {
  name                = var.vm_name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_size
  instances           = var.vm_count
  admin_username      = var.login_username

  admin_ssh_key {
    username   = var.login_username
    public_key = replace(data.azurerm_ssh_public_key.itself.public_key, "\r\n", "")
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_storage_account_type
  }

  network_interface {
    name    = format("%s-nic", var.vm_name_prefix)
    primary = true

    ip_configuration {
      name      = format("%s-ip-config", var.vm_name_prefix)
      primary   = true
      subnet_id = var.subnet_id

      public_ip_address {
        name                = var.vm_name_prefix
        public_ip_prefix_id = azurerm_public_ip_prefix.itself.id
      }
    }
  }

  custom_data = data.template_cloudinit_config.user_data64.rendered
}

output "instance_public_ips" {
  value = azurerm_public_ip_prefix.itself[*].ip_prefix
}

output "instance_private_ips" {
  value = azurerm_linux_virtual_machine_scale_set.itself[*].id
}

output "instance_ids" {
  value = azurerm_linux_virtual_machine_scale_set.itself[*].id
}
