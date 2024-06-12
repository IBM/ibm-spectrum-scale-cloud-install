/*
    Creates Azure Linux Virtual Machine with no data disks.
*/

variable "application_security_group_id" {}
variable "availability_zone" {}
variable "dns_domain" {}
variable "forward_dns_zone" {}
variable "location" {}
variable "login_username" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "name_prefix" {}
variable "os_disk_caching" {}
variable "os_disk_encryption_set_id" {}
variable "os_storage_account_type" {}
variable "proximity_placement_group_id" {}
variable "resource_group_name" {}
variable "reverse_dns_zone" {}
variable "source_image_id" {}
variable "ssh_public_key_path" {}
variable "subnet_id" {}
variable "vm_size" {}

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
# Hostname settings
hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
echo "DOMAIN=\"${var.dns_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
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
  name                = var.name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = var.name_prefix
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create "A" (IPv4 Address) record to map IPv4 address as hostname along with domain
resource "azurerm_private_dns_a_record" "itself" {
  name                = var.name_prefix
  zone_name           = var.forward_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = azurerm_network_interface.itself.private_ip_addresses
  depends_on          = [azurerm_network_interface.itself]
}

# Create "PTR" (Pointer) to enable reverse DNS lookup, from an IP address to a hostname
resource "azurerm_private_dns_ptr_record" "itself" {
  # Considering only the first NIC private ip address
  name                = format("%s.%s.%s", split(".", azurerm_network_interface.itself.private_ip_addresses[0])[3], split(".", azurerm_network_interface.itself.private_ip_addresses[0])[2], split(".", azurerm_network_interface.itself.private_ip_addresses[0])[1])
  zone_name           = var.reverse_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [format("%s.%s", var.name_prefix, var.dns_domain)]
  depends_on          = [azurerm_network_interface.itself]
}

resource "azurerm_network_interface_application_security_group_association" "associate_asg" {
  network_interface_id          = azurerm_network_interface.itself.id
  application_security_group_id = var.application_security_group_id
}

resource "azurerm_linux_virtual_machine" "itself" {
  name                         = var.name_prefix
  resource_group_name          = var.resource_group_name
  location                     = var.location
  size                         = var.vm_size
  admin_username               = var.login_username
  network_interface_ids        = [azurerm_network_interface.itself.id]
  proximity_placement_group_id = var.proximity_placement_group_id
  zone                         = var.availability_zone
  admin_ssh_key {
    username   = var.login_username
    public_key = file(var.ssh_public_key_path)
  }
  os_disk {
    caching                = var.os_disk_caching
    storage_account_type   = var.os_storage_account_type
    disk_encryption_set_id = var.os_disk_encryption_set_id
  }
  source_image_id = var.source_image_id
  custom_data     = data.template_cloudinit_config.user_data64.rendered
  lifecycle {
    ignore_changes = all
  }
}

output "instance_details" {
  value = {
    private_ip = azurerm_linux_virtual_machine.itself.private_ip_address
    id         = azurerm_linux_virtual_machine.itself.id
    dns        = format("%s.%s", var.name_prefix, var.dns_domain)
    zone       = var.availability_zone
  }
}
