/*
  Creates multiple GCP VM instances.
*/

variable "machine_type" {}
variable "instance_name_prefix" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "data_disk_size" {}
variable "instances_ssh_user_name" {}
variable "instances_ssh_public_key_path" {}
variable "total_cluster_instances" {}
variable "total_persistent_disks" {}
variable "data_disk_type" {}
variable "service_email" {}
variable "scopes" {}
variable "private_key_content" {}
variable "public_key_content" {}
variable "block_device_names" {}
variable "total_local_ssd_disks" {}
variable "vpc_region" {}
variable "block_device_kms_key_ring_ref" {}
variable "block_device_kms_key_ref" {}
variable "data_disk_description" {}
variable "physical_block_size_bytes" {}
variable "dns_forward_dns_zone" {}
variable "dns_forward_dns_name" {}
variable "dns_reverse_dns_zone" {}
variable "dns_reverse_dns_name" {}
variable "vpc_availability_zones" {}
variable "vpc_subnets" {}

locals {
  local_ssd_names         = [for i in range(var.total_local_ssd_disks) : "/dev/nvme0n${i + 1}"]
  vpc_subnets             = var.vpc_subnets == null ? [] : var.vpc_subnets
  availability_zones      = var.vpc_availability_zones == null ? [] : var.vpc_availability_zones
  vpc_availability_zones  = length(local.availability_zones) > length(local.vpc_subnets) ? slice(local.availability_zones, 0, length(local.vpc_subnets)) : local.availability_zones
  total_cluster_instances = var.total_cluster_instances == null ? 0 : var.total_cluster_instances
  vm_configuration        = flatten([for i in range(local.total_cluster_instances) : { subnet = element(local.vpc_subnets, i), zone = element(local.vpc_availability_zones, i), vm_name = "${var.instance_name_prefix}-${i}" }])
}

# Creating multiple instances
module "instances_multiple" {
  count                         = length(local.vm_configuration)
  source                        = "../instance_vm"
  vpc_region                    = var.vpc_region
  zone                          = local.vm_configuration[count.index].zone
  machine_type                  = var.machine_type
  instance_name                 = local.vm_configuration[count.index].vm_name
  boot_disk_size                = var.boot_disk_size
  boot_disk_type                = var.boot_disk_type
  boot_image                    = var.boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
  total_persistent_disks        = var.total_persistent_disks
  total_local_ssd_disks         = var.total_local_ssd_disks
  subnet_name                   = local.vm_configuration[count.index].subnet
  ssh_user_name                 = var.instances_ssh_user_name
  ssh_key_path                  = var.instances_ssh_public_key_path
  private_key_content           = var.private_key_content
  public_key_content            = var.public_key_content
  service_email                 = var.service_email
  scopes                        = var.scopes
  block_device_kms_key_ring_ref = var.block_device_kms_key_ring_ref
  block_device_kms_key_ref      = var.block_device_kms_key_ref
  physical_block_size_bytes     = var.physical_block_size_bytes
  data_disk_description         = var.data_disk_description
  dns_forward_dns_zone          = var.dns_forward_dns_zone
  dns_forward_dns_name          = var.dns_forward_dns_name
  dns_reverse_dns_zone          = var.dns_reverse_dns_zone
  dns_reverse_dns_name          = var.dns_reverse_dns_name
}

# Instance details
output "instances" {
  value = module.instances_multiple[*]
}

output "instance_ids" {
  value = module.instances_multiple[*].instance_ids
}

output "instance_selflink" {
  value = module.instances_multiple[*].instance_selflink
}

output "instance_ips" {
  value = module.instances_multiple[*].instance_ips
}

output "disk_device_mapping" {
  value = (var.total_persistent_disks > 0) && (length(var.block_device_names) >= var.total_persistent_disks) ? { for i in range(var.total_cluster_instances) : (module.instances_multiple[i].instance.network_interface[0].network_ip) => slice(var.block_device_names, 0, var.total_persistent_disks) } : var.total_local_ssd_disks > 0 ? { for i in range(var.total_cluster_instances) : (module.instances_multiple[i].instance.network_interface[0].network_ip) => local.local_ssd_names } : {}
}

output "dns_hostname" {
  value = { for i in range(var.total_cluster_instances) : (module.instances_multiple[i].instance.network_interface[0].network_ip) => "${module.instances_multiple[i].instance.name}.${module.instances_multiple[i].instance.zone}.c.${module.instances_multiple[i].instance.project}.internal" }
}
