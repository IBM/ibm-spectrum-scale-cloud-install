output "cloud_infrastructure" {
  value       = "yes"
  description = "Flag to represent cloud platform."
}

output "cloud_platform" {
  value       = "azure"
  description = "Flag to represent Azure cloud."
}

output "vnet_name" {
  value       = module.vnet_module.vnet_name
  description = "Azure virtual network name."
}

output "resource_group_name" {
  value       = module.vnet_module.resource_group_name
  description = "Azure resource group name."
}

output "private_subnet_name" {
  value       = module.vnet_module.private_subnet_name
  description = "Azure private subnet name."
}

output "bastion_subnet_name" {
  value       = module.vnet_module.bastion_public_subnet_name
  description = "Azure bastion public subnet name."
}

output "storage_vms_by_private_ip" {
  value       = module.create_storage_vm_nics.nic_ipaddress
  description = "Private IP address of Azure storage vms."
}

output "compute_vms_by_private_ip" {
  value       = module.create_compute_vm_nics.nic_ipaddress
  description = "Private IP address of Azure compute vms."
}

output "storage_vmips_lun_number_map" {
  value = {
    for vm_ip in module.create_storage_vm_nics.nic_ipaddress :
    vm_ip => slice(range(0, 31), 0, var.total_disks_per_vm)
  }
  description = "Dictionary of storage vm ip vs. data disk device path."
}
