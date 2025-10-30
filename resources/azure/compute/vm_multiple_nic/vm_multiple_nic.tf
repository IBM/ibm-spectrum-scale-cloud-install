/*
    Creates Azure Linux Virtual Machine with no data disks.
*/

variable "application_security_group_id" {}
variable "availability_zone" {}
variable "ces_ipaddress" {}
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
variable "base_subnet_id" {}
variable "ces_subnet_id" {}
variable "vm_size" {}

locals {
  user_data = <<-EOT
    #!/usr/bin/env bash
    echo "${var.meta_private_key}" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
    echo "StrictHostKeyChecking no" >> ~/.ssh/config
    # Hostname settings
    hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
    echo "DOMAIN=\"${var.dns_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
    systemctl restart NetworkManager
  EOT
}

# Primary NIC, which is used for cluster communication
resource "azurerm_network_interface" "base_nic" {
  name                = format("%s-base-nic", var.name_prefix)
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = format("%s-primary", var.name_prefix)
    subnet_id                     = var.base_subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

# Secondary NIC, which is used for CES communication
resource "azurerm_network_interface" "ces_nic" {
  name                = format("%s-secondary-nic", var.name_prefix)
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = format("%s-secondary", var.name_prefix)
    subnet_id                     = var.ces_subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
  ip_configuration {
    name                          = format("%s-ces-%s", var.name_prefix, replace(var.ces_ipaddress, ".", "-"))
    subnet_id                     = var.ces_subnet_id
    private_ip_address_allocation = "Static"
    primary                       = false
    private_ip_address            = var.ces_ipaddress
  }
}

# Create "A" (IPv4 Address) record to map IPv4 address as hostname along with domain
resource "azurerm_private_dns_a_record" "itself" {
  name                = var.name_prefix
  zone_name           = var.forward_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = azurerm_network_interface.base_nic.private_ip_addresses
  depends_on          = [azurerm_network_interface.base_nic]
}

# Create "PTR" (Pointer) to enable reverse DNS lookup, from an IP address to a hostname
resource "azurerm_private_dns_ptr_record" "itself" {
  # Considering only the first NIC private ip address
  name                = format("%s.%s.%s", split(".", azurerm_network_interface.base_nic.private_ip_addresses[0])[3], split(".", azurerm_network_interface.base_nic.private_ip_addresses[0])[2], split(".", azurerm_network_interface.base_nic.private_ip_addresses[0])[1])
  zone_name           = var.reverse_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [format("%s.%s", var.name_prefix, var.dns_domain)]
  depends_on          = [azurerm_network_interface.base_nic]
}

# Create "A" (IPv4 Address) record to map CES IPv4 address as hostname along with domain
resource "azurerm_private_dns_a_record" "ces_a_itself" {
  name                = format("%s-ces-%s", var.name_prefix, replace(var.ces_ipaddress, ".", "-"))
  zone_name           = var.forward_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = azurerm_network_interface.ces_nic.private_ip_addresses
  depends_on          = [azurerm_network_interface.ces_nic]
}

# Create "PTR" (Pointer) to enable reverse DNS lookup, from an IP address to a hostname for CES ip address
resource "azurerm_private_dns_ptr_record" "ces_ptr_itself" {
  name                = format("%s.%s.%s", split(".", var.ces_ipaddress)[3], split(".", var.ces_ipaddress)[2], split(".", var.ces_ipaddress)[1])
  zone_name           = var.reverse_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [format("%s-ces.%s", var.name_prefix, var.dns_domain)]
  depends_on          = [azurerm_network_interface.ces_nic]
}

resource "azurerm_network_interface_application_security_group_association" "associate_asg" {
  network_interface_id          = azurerm_network_interface.base_nic.id
  application_security_group_id = var.application_security_group_id
}

resource "azurerm_user_assigned_identity" "itself" {
  location            = var.location
  name                = format("%s-identity", var.name_prefix)
  resource_group_name = var.resource_group_name
}

# Assign Network Contributor role to query the nic names
resource "azurerm_role_assignment" "itself" {
  for_each = {
    base = azurerm_network_interface.base_nic.id
    ces  = azurerm_network_interface.ces_nic.id
  }

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.itself.principal_id
}

# Assign Network Contributor role to update the ip config
resource "azurerm_role_assignment" "ipconfig_update" {
  scope                = var.ces_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.itself.principal_id
}

resource "azurerm_linux_virtual_machine" "itself" {
  name                         = var.name_prefix
  resource_group_name          = var.resource_group_name
  location                     = var.location
  size                         = var.vm_size
  admin_username               = var.login_username
  network_interface_ids        = [azurerm_network_interface.base_nic.id, azurerm_network_interface.ces_nic.id]
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
  custom_data     = base64encode(local.user_data)

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.itself.id]
  }

  lifecycle {
    ignore_changes = all
  }
}

output "instance_details" {
  value = {
    private_ip     = azurerm_linux_virtual_machine.itself.private_ip_address
    id             = azurerm_linux_virtual_machine.itself.id
    dns            = format("%s.%s", var.name_prefix, var.dns_domain)
    zone           = var.availability_zone
    ces_private_ip = var.ces_ipaddress
  }
}
