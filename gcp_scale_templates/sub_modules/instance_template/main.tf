/*
  Creates compute and storage GCP VM clusters.
*/
terraform {
  backend "gcs" {}
}

locals {
  zones = var.vpc_availability_zones != null ? var.vpc_availability_zones : ["us-central1-a"]
}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances != null ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances != null ? true : false
}

module "bastion_compute_instances_firewall" {
  source               = "../../../resources/gcp/network/firewall/allow_bastion_internal"
  source_range         = [var.bastion_subnet_cidr]
  firewall_name_prefix = var.resource_prefix
  vpc_name             = var.vpc_name
}

module "compute_instances_firewall" {
  source               = "../../../resources/gcp/network/firewall/allow_internal"
  source_range         = [var.private_subnet_cidr]
  firewall_name_prefix = var.resource_prefix
  vpc_name             = var.vpc_name
}

#Creates compute instances
module "compute_cluster_instances" {
  count                         = length(local.zones) > 2 ? 2 : length(local.zones)
  source                        = "../../../resources/gcp/compute/vm_instance_multiple"
  zone                          = local.zones[count.index]
  instances_ssh_public_key_path = var.instances_ssh_public_key_path
  instances_ssh_user_name       = var.instances_ssh_user_name
  total_cluster_instances       = var.total_compute_cluster_instances
  total_data_disks              = 0
  instance_name_prefix          = var.compute_instance_name_prefix
  machine_type                  = var.compute_machine_type
  subnet_name                   = var.vpc_compute_cluster_private_subnets[count.index]
  private_key_content           = module.generate_compute_cluster_keys.private_key_content
  public_key_content            = module.generate_compute_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.compute_instance_tags
  boot_disk_size                = var.compute_boot_disk_size
  boot_disk_type                = var.compute_boot_disk_type
  boot_image                    = var.compute_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
}

module "storage_cluster_tie_breaker_instance" {
  count                         = length(var.vpc_storage_cluster_private_subnets) > 1 ? (length(local.zones) > 2 ? 1 : 0) : 0
  source                        = "../../../resources/gcp/compute/vm_instance_multiple"
  zone                          = local.zones[2]
  instances_ssh_public_key_path = var.instances_ssh_public_key_path
  instances_ssh_user_name       = var.instances_ssh_user_name
  total_cluster_instances       = 1
  total_data_disks              = var.data_disks_per_instance
  instance_name_prefix          = format("%s-storage-tie", var.resource_prefix)
  machine_type                  = var.compute_machine_type
  subnet_name                   = var.vpc_storage_cluster_private_subnets != null ? (length(var.vpc_storage_cluster_private_subnets) > 1 ? var.vpc_storage_cluster_private_subnets[2] : var.vpc_storage_cluster_private_subnets[0]) : null
  private_key_content           = module.generate_storage_cluster_keys.private_key_content
  public_key_content            = module.generate_storage_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.storage_instance_tags
  boot_disk_size                = var.storage_boot_disk_size
  boot_disk_type                = var.storage_boot_disk_type
  boot_image                    = var.storage_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
}

#Creates storage instances
module "storage_cluster_instances" {
  count                         = length(local.zones) > 2 ? 2 : length(local.zones)
  source                        = "../../../resources/gcp/compute/vm_instance_multiple"
  zone                          = local.zones[count.index]
  instances_ssh_public_key_path = var.instances_ssh_public_key_path
  instances_ssh_user_name       = var.instances_ssh_user_name
  total_cluster_instances       = var.total_storage_cluster_instances
  total_data_disks              = var.data_disks_per_instance
  instance_name_prefix          = var.storage_instance_name_prefix
  machine_type                  = var.storage_machine_type
  subnet_name                   = var.vpc_storage_cluster_private_subnets[count.index]
  private_key_content           = module.generate_storage_cluster_keys.private_key_content
  public_key_content            = module.generate_storage_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.storage_instance_tags
  boot_disk_size                = var.storage_boot_disk_size
  boot_disk_type                = var.storage_boot_disk_type
  boot_image                    = var.storage_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
}
