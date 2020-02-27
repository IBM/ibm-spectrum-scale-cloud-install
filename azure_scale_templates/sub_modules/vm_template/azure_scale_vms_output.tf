output "compute_vm_ids" {
    value = module.compute_vms.vm_ids
}

output "storage_vm_ids" {
    value = module.storage_vms.vm_ids
}

output "compute_vms_by_az" {
    value = module.compute_vms.vms_by_availability_zone
}

output "storage_vms_by_az" {
    value = module.storage_vms.vms_by_availability_zone
}
