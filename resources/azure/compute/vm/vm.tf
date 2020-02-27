/*
    Creates specified number of Azure VM's.
*/

variable "total_vms" {
    type = string
}
variable "location" {
    type = string
}
variable "resource_group_name" {
    type = string
}
variable "availability_zones" {
    type = list(string)
}
variable "vm_name_prefix" {
    type = string
}
variable "all_nic_ids" {
    type = list(string)
}
variable "vm_size" {
    type = string
}
variable "delete_os_disk_on_termination" {
    type = bool
}
variable "delete_data_disks_on_termination" {
    type = bool
}
variable "vm_os_publisher" {
    type = string
}
variable "vm_os_offer" {
    type = string
}
variable "vm_os_sku" {
    type = string
}
variable "vm_osdisk_name_prefix" {
    type = string
}
variable "vm_osdisk_caching" {
    type = string
}
variable "vm_osdisk_create_option" {
    type = string
}
variable "vm_osdisk_type" {
    type = string
}
variable "vm_hostname_prefix" {
    type = string
}
variable "vm_admin_username" {
    type = string
}
variable "vm_sshlogin_pubkey_path" {
    type = string
}
variable "vault_private_key" {
    type = string
}
variable "vault_public_key" {
    type = string
}
variable "vm_tags" {
    type = map(string)
}
variable "private_zone_vnet_link_name" {
    type = string
}


resource "azurerm_virtual_machine" "main" {
    count                 = var.total_vms
    name                  = "${var.vm_name_prefix}-vm${count.index+1}"
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [element(var.all_nic_ids, count.index)]
    vm_size               = var.vm_size
    zones                 = [element(var.availability_zones, count.index)]

    delete_os_disk_on_termination    = var.delete_os_disk_on_termination
    delete_data_disks_on_termination = var.delete_data_disks_on_termination

    storage_image_reference {
        publisher = var.vm_os_publisher
        offer     = var.vm_os_offer
        sku       = var.vm_os_sku
        version   = "latest"
    }
    storage_os_disk {
        name              = "${var.vm_osdisk_name_prefix}-osdisk${count.index+1}"
        caching           = var.vm_osdisk_caching
        create_option     = var.vm_osdisk_create_option
        managed_disk_type = var.vm_osdisk_type
    }
    os_profile {
        computer_name  = "${var.vm_hostname_prefix}${count.index+1}"
        admin_username = var.vm_admin_username
        custom_data    = <<-EOF
        #!/usr/bin/env bash
        AZURE_REPO=$(lsb_release -cs)
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZURE_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
        curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        sudo apt-get install -y apt-transport-https
        sudo apt-get update && sudo apt-get install -y azure-cli
        sudo apt-get update && sudo apt-get install -y libssl-dev libffi-dev python-dev python-pip
        sudo pip install ansible[azure]
        echo "${var.vault_private_key}" > ~/.ssh/id_rsa
        echo "${var.vault_public_key}"  > ~/.ssh/id_rsa.pub
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa.pub
        chmod 600 ~/.ssh/authorized_keys
EOF
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
            key_data = file(var.vm_sshlogin_pubkey_path)
        }
    }

    tags = var.vm_tags

    depends_on = [var.private_zone_vnet_link_name]
}


output "vm_ids" {
    value = azurerm_virtual_machine.main.*.id
}

output "vms_by_availability_zone" {
    # Result is a map from availability zone to vm ids, such as:
    # {"1": ["i-1234", "i-5678"], "2": ["i-1234", "i-5678"]}
    value = {
        for vm in azurerm_virtual_machine.main:
        # Use the ellipsis (...) after the value expression to enable
        # grouping by key.
            vm.zones[0] => vm.id...
    }
}
