/*
    Creates Azure Linux Virtual Machine Template for Spectrum scale.
    - Creates Linux Virtual Machine
    - Uses cloud-init script to provision spectrum scale rpms
    - Wait till cloud-init script completes
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
variable "os_disk_caching" {}
variable "os_storage_account_type" {}
variable "user_public_key" {}
variable "user_private_key" {}
variable "dns_zone" {}
variable "availability_zone" {}
variable "createimage" { default = false }
variable "storage_account" {}
variable "blob_container" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}


# cloud-init scale deployment script
data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
echo "${var.user_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.user_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "DOMAIN=\"${var.dns_zone}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
systemctl restart NetworkManager
dnf install -y unzip @python36
dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`
dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo '[azure-cli]' >> /etc/yum.repos.d/azure-cli.repo
echo 'name=Azure CLI' >> /etc/yum.repos.d/azure-cli.repo
echo 'baseurl=https://packages.microsoft.com/yumrepos/azure-cli' >> /etc/yum.repos.d/azure-cli.repo
echo 'enabled=1' >> /etc/yum.repos.d/azure-cli.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/azure-cli.repo
echo 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' >> /etc/yum.repos.d/azure-cli.repo
dnf install -y azure-cli
az login --service-principal --tenant "${var.tenant_id}" --username "${var.client_id}" --password "${var.client_secret}" --output table
az storage blob download-batch --source "${var.blob_container}" --destination . --account-name "${var.storage_account}" --auth-mode login
dnf install 5.2.0.0/gpfs_rpms/*.rpm 5.2.0.0/zimon_rpms/rhel8/gpfs*.rpm -y
rm -rf *.rpm *.gpg
/usr/lpp/mmfs/bin/mmbuildgpl
echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc
rm -rf /root/.ssh/authorized_keys
rm -rf /home/"azureuser"/authorized_keys
firewall-offline-cmd --add-port={1191/tcp,47080/tcp,60000-61000/tcp,4444/tcp,9080/tcp,443/tcp,47443/tcp,4739/tcp}
systemctl stop syslog
rm -rf /var/log/messages
rm -rf /root/.bash_history
rm -rf /home/"azureuser"/.bash_history
touch /tmp/cloudinitdone
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

# Generate random id for uniqueness image
resource "random_id" "randomid" {
  keepers = {
    resource_group = var.resource_group_name
  }

  byte_length = 8
}

# Create public ip
resource "azurerm_public_ip" "imagepublicip" {
  name                = "publicIp-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface for Image vm
resource "azurerm_network_interface" "itself" {
  name                = "${var.vm_name}-${random_id.randomid.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.vm_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.imagepublicip.id
  }
}

# Create image nsg
resource "azurerm_network_security_group" "image_nsg" {
  name                = "ImageNetworkSecurityGroup-${random_id.randomid.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Scale"
  }
}

# Associate Nsg to Image VM
resource "azurerm_network_interface_security_group_association" "image_vm_assoc" {
  network_interface_id      = azurerm_network_interface.itself.id
  network_security_group_id = azurerm_network_security_group.image_nsg.id
}

# Create Image VM
resource "azurerm_linux_virtual_machine" "itself" {
  name                  = "${var.vm_name}-${random_id.randomid.hex}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.login_username
  network_interface_ids = [azurerm_network_interface.itself.id]
  zone                  = var.availability_zone

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

# Wait till cloudinit provision finish
resource "null_resource" "waitcloudinit" {
  connection {
    type        = "ssh"
    user        = var.login_username
    private_key = file(var.user_private_key)
    host        = azurerm_linux_virtual_machine.itself.public_ip_address
    timeout     = 1200
  }

  #  Alternativly we can use #cloud-init status --wait , command instead of file /tmp/cloudinitdone creation wait
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /tmp/cloudinitdone ]; do echo 'waiting for cloudinit provision..' ;sleep 40; done",
      "touch /tmp/remoteexecdone",
      "sleep 20"
    ]
  }

  depends_on = [azurerm_linux_virtual_machine.itself]
}

output "instance_private_ip" {
  value       = azurerm_linux_virtual_machine.itself.private_ip_address
  description = "VM instance ip"
}

output "instance_public_ip" {
  value = azurerm_linux_virtual_machine.itself.public_ip_address
}

output "instance_id" {
  value = azurerm_linux_virtual_machine.itself.id
}

output "instance_name" {
  value = azurerm_linux_virtual_machine.itself.name
}

output "instance_dns_name" {
  value = "${azurerm_network_interface.itself.name}.${azurerm_network_interface.itself.internal_domain_name_suffix}"
}

output "instance_random_suffix" {
  value = random_id.randomid.hex
}
