/*
    Creates Azure Linux Virtual Machine with data disk
*/

variable "vm_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "vm_size" {}
variable "subnet_id" {}
variable "login_username" {}
variable "proximity_placement_group_id" {}
variable "os_disk_caching" {}
variable "os_storage_account_type" {}
variable "data_disk_device_names" {}
variable "data_disk_storage_account_type" {}
variable "user_key_pair" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "dns_zone" {}
variable "availability_zone" {}
variable "source_image_id" {}
variable "application_security_group_id" {}
variable "disks" {}

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

# Gets Azure ssh keypair data
data "azurerm_ssh_public_key" "itself" {
  name                = var.user_key_pair
  resource_group_name = var.resource_group_name
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

resource "azurerm_private_dns_a_record" "itself" {
  name                = var.vm_name
  zone_name           = var.dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = azurerm_network_interface.itself.private_ip_addresses

  depends_on = [azurerm_network_interface.itself]
}

resource "azurerm_network_interface_application_security_group_association" "associate_asg" {
  network_interface_id          = azurerm_network_interface.itself.id
  application_security_group_id = var.application_security_group_id
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
    public_key = replace(data.azurerm_ssh_public_key.itself.public_key, "\r\n", "")
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_storage_account_type
  }

  source_image_id = var.source_image_id

  custom_data = data.template_cloudinit_config.user_data64.rendered
}

resource "azurerm_managed_disk" "itself" {
  for_each             = var.disks
  name                 = each.key
  location             = var.location
  create_option        = "Empty"
  disk_size_gb         = each.value["size"]
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value["type"]
  zone                 = azurerm_linux_virtual_machine.itself.zone
}

resource "azurerm_virtual_machine_data_disk_attachment" "itself" {
  for_each = azurerm_managed_disk.itself

  virtual_machine_id = azurerm_linux_virtual_machine.itself.id
  managed_disk_id    = azurerm_managed_disk.itself[each.key].id
  lun                = var.disks[each.key]["lun_no"]
  caching            = "ReadWrite"
}

output "instance_private_ips" {
  value = azurerm_linux_virtual_machine.itself.private_ip_address
}

output "instance_ids" {
  value = azurerm_linux_virtual_machine.itself.id
}

output "instance_ips_with_data_mapping" {
  value = { (azurerm_linux_virtual_machine.itself.private_ip_address) = slice(var.data_disk_device_names, 0, length(var.disks)) }
}

output "instance_private_dns_name" {
  value = "${azurerm_network_interface.itself.name}.${azurerm_network_interface.itself.internal_domain_name_suffix}"
}
