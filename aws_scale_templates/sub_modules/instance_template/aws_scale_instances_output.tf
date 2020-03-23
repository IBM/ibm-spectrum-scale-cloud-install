output "compute_instance_ips" {
    value = module.compute_instances.instance_ips
}

output "storage_instance_ips" {
    value = module.storage_instances.instance_ips
}

output "compute_instances_private_ip_by_instance_id" {
    value = module.compute_instances.instances_private_ip_addresses
}

output "storage_instances_private_ip_by_instance_id" {
    value = module.storage_instances.instances_private_ip_addresses
}

output "storage_az_instances_map" {
    value = module.storage_instances.instances_by_availability_zone
}

output "ins_by_availability_zone_mix" {
    value = local.instances_by_az_mix
    description = "Dictionary of instances vs. availability zone."
}

output "ins_by_zone_mix" {
    value = local.required_ins_by_az_format
}

output "az_ebs_map" {
    value = module.storage_ebs_volumes.ebs_by_availability_zone
    description = "Dictionary of EBS volumes vs. availability zone."
}

output "ebs_by_availability_zone_mix" {
    value = local.ebs_by_az_mix
}

output "ebs_by_zone_mix" {
    value = local.required_ebs_by_az_format
}

output "instance_ids_ebs_device_names" {
    value = module.storage_ebs_instance_attach.instances_device_map
}

output "instance_ips_ebs_device_names" {
    value = {
        for instance in module.storage_instances.instance_ips:
            instance => slice(var.ebs_volume_device_names, 0, var.ebs_volumes_per_instance)
    }
}

output "compute_instance_desc_map" {
    value = {
        for instance in module.desc_compute_instance.instance_private_ip_address:
            instance => var.ebs_volume_device_names[0]
    }
}

