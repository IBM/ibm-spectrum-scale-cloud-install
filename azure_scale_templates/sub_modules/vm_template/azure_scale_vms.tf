/*
    Creates specified number of IBM Spectrum Scale compute, storage vm's
    along with specified number of data disk attachment(s).
*/

module "ansible_vault" {
    source = "../../../resources/common/ansible_vault"
}

module "compute_vms" {
    source                           = "../../../resources/azure/compute/vm"
    location                         = var.location
    resource_group_name              = var.resource_group_name
    availability_zones               = var.availability_zones
    vm_name_prefix                   = "SpectrumScale-compute"
    total_vms                        = var.total_compute_vms
    all_nic_ids                      = var.all_compute_nic_ids

    vm_osdisk_caching                = var.vm_osdisk_caching
    vm_osdisk_create_option          = var.vm_osdisk_create_option
    vm_osdisk_name_prefix            = "scale-computevm"
    vm_osdisk_type                   = var.vm_osdisk_type
    delete_os_disk_on_termination    = var.delete_os_disk_on_termination
    delete_data_disks_on_termination = var.delete_data_disks_on_termination

    vm_os_offer                      = var.compute_vm_os_offer
    vm_os_publisher                  = var.compute_vm_os_publisher
    vm_os_sku                        = var.compute_vm_os_sku
    vm_size                          = var.compute_vm_size

    vm_admin_username                = var.vm_admin_username
    vm_hostname_prefix               = lower("SpectrumScale-compute")
    vm_sshlogin_pubkey_path          = var.vm_sshlogin_pubkey_path
    vault_private_key                = module.ansible_vault.id_rsa_content
    vault_public_key                 = module.ansible_vault.id_rsa_pub_content
    vm_tags                          = {role: "compute"}
    private_zone_vnet_link_name      = var.private_zone_vnet_link_name
}

module "create_desc_data_disk" {
    source                  = "../../../resources/azure/storage/data_disks_create"
    location                = var.location
    resource_group_name     = var.resource_group_name
    availability_zones      = var.availability_zones
    total_disks_count       = 1
    data_disk_create_option = var.data_disk_create_option
    data_disk_name_prefix   = "spectrumscale-descdisk"
    data_disk_size          = 5
    data_disk_type          = var.data_disk_type
}

module "attach_desc_disk" {
    source            = "../../../resources/azure/storage/data_disks_attach"
    data_disk_caching = var.data_disk_caching
    data_disk_ids     = module.create_desc_data_disk.disk_ids_by_availability_zone[var.availability_zones[0]]
    lun_units         = slice(range(0, 31), 0, 1)
    vm_ids            = module.storage_vms.vms_by_availability_zone[var.availability_zones[0]]
}

module "storage_vms" {
    source                           = "../../../resources/azure/compute/vm"
    location                         = var.location
    resource_group_name              = var.resource_group_name
    availability_zones               = var.availability_zones
    vm_name_prefix                   = "SpectrumScale-storage"
    total_vms                        = var.total_storage_vms
    all_nic_ids                      = var.all_storage_nic_ids

    vm_osdisk_caching                = var.vm_osdisk_caching
    vm_osdisk_create_option          = var.vm_osdisk_create_option
    vm_osdisk_name_prefix            = "scale-storagevm"
    vm_osdisk_type                   = var.vm_osdisk_type
    delete_data_disks_on_termination = var.delete_data_disks_on_termination
    delete_os_disk_on_termination    = var.delete_data_disks_on_termination

    vm_os_offer                      = var.storage_vm_os_offer
    vm_os_publisher                  = var.storage_vm_os_publisher
    vm_os_sku                        = var.storage_vm_os_sku
    vm_size                          = var.storage_vm_size

    vm_admin_username                = var.vm_admin_username
    vm_hostname_prefix               = lower("SpectrumScale-storage")
    vm_sshlogin_pubkey_path          = var.vm_sshlogin_pubkey_path
    vault_private_key                = module.ansible_vault.id_rsa_content
    vault_public_key                 = module.ansible_vault.id_rsa_pub_content
    vm_tags                          = {role: "storage"}
    private_zone_vnet_link_name      = var.private_zone_vnet_link_name
}

module "create_data_disks" {
    source                  = "../../../resources/azure/storage/data_disks_create"
    location                = var.location
    resource_group_name     = var.resource_group_name
    availability_zones      = var.availability_zones
    total_disks_count       = var.total_disks_per_vm * var.total_storage_vms
    data_disk_create_option = var.data_disk_create_option
    data_disk_name_prefix   = "spectrumscale-datadisk"
    data_disk_size          = var.data_disk_size
    data_disk_type          = var.data_disk_type
}

locals {
    # Re-arrange vm's list by az mix.
    total_iterations = length(var.availability_zones) == 2 ? var.total_storage_vms/2 : var.total_storage_vms
    vm_by_az_mix = [
        for iter in range(local.total_iterations): [
            for az in range(length(var.availability_zones)): [
                module.storage_vms.vms_by_availability_zone[element(var.availability_zones, az)][iter],
            ]
        ]
    ]
    required_vms_by_az_format = flatten(local.vm_by_az_mix)

    # Re-arrange disk's list by az mix.
    disk_by_az_mix = [
        for iter in range(var.total_disks_per_vm): [
            for az in range(length(var.availability_zones)): [
                module.create_data_disks.disk_ids_by_availability_zone[element(var.availability_zones, az)][iter],
            ]
        ]
    ]
    required_disks_by_az_format = flatten(local.disk_by_az_mix)
}

module "attach_data_disks" {
    source            = "../../../resources/azure/storage/data_disks_attach"
    data_disk_caching = var.data_disk_caching
    data_disk_ids     = local.required_disks_by_az_format
    lun_units         = slice(range(0, 31), 0, var.total_disks_per_vm)
    vm_ids            = local.required_vms_by_az_format
}
