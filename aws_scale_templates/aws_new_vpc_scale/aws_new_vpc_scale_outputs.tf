output "cloud_infrastructure" {
    value = "yes"
    description = "Flag to represent cloud platform."
}

output "cloud_platform" {
    value = "aws"
    description = "Flag to represent AWS cloud."
}

output "stack_name" {
    value = var.stack_name
    description = "AWS Stack name."
}

output "vpc_id" {
    value = module.vpc_module.vpc_id
    description = "VPC ID."
}

output "public_subnets" {
    value = module.vpc_module.public_subnets
    description = "AWS public subnet IDs."
}

output "private_subnets" {
    value = module.vpc_module.private_subnets
    description = "AWS private subnet IDs."
}

output "compute_instances_private_ip_by_instance_id" {
    value = module.instances_module.compute_instances_private_ip_by_instance_id
    description = "Dictionary of compute instance ip vs. instance id."
}

output "storage_instances_private_ip_by_instance_id" {
    value = module.instances_module.storage_instances_private_ip_by_instance_id
    description = "Dictionary of storage instance ip vs. instance id."
}

output "compute_instances_by_private_ip" {
    value = module.instances_module.compute_instance_ips
    description = "Private IP address of AWS compute instances."
}

output "storage_instances_by_private_ip" {
    value = module.instances_module.storage_instance_ips
    description = "Private IP address of AWS storage instances."
}

output "storage_instances_device_names_map" {
    value = module.instances_module.instance_ips_ebs_device_names
    description = "Dictionary of storage instance ip vs. EBS device path."
}

output "compute_instance_desc_map" {
    value = module.instances_module.compute_instance_desc_map
    description = "Dictionary of compute instance ip vs. descriptor EBS device path."
}
