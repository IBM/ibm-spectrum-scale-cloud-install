/*
  Create compute and storage GCP VM instances.
*/

terraform {
  backend "gcs" {}
}

module "generate_keys" {
  source       = "../../../resources/common/generate_keys"
  tf_data_path = var.tf_data_path
}

module "compute_instances_firewall" {
  source               = "../../../resources/gcp/network/firewall/allow_internal"
  source_range         = ["35.235.240.0/20"]
  firewall_name_prefix = var.stack_name
  vpc_name             = var.vpc_name
}

module "compute_instances" {
  source               = "../../../resources/gcp/compute_engine/vm_instance/vm_instance_multiple_zones"
  total_instances      = var.total_compute_instances
  zones                = var.zones
  machine_type         = var.compute_machine_type
  instance_name_prefix = "compute"
  boot_disk_size       = var.compute_boot_disk_size
  boot_disk_type       = var.compute_boot_disk_type
  boot_image           = var.compute_boot_image
  network_tier         = var.compute_network_tier
  vm_instance_tags     = var.compute_instance_tags
  subnet_name          = var.private_subnet_name
  operator_email       = var.operator_email
  scopes               = var.scopes
  ssh_user_name        = var.instances_ssh_user_name
  ssh_key_path         = var.instances_ssh_key_path
  private_key_path     = module.generate_keys.private_key_path
  public_key_path      = module.generate_keys.public_key_path
}

module "desc_compute_instance" {
  source                  = "../../../resources/gcp/compute_engine/vm_instance/vm_instance_1_disk"
  zone                    = length(var.zones) > 1 ? var.zones.1 : var.zones.0
  machine_type            = var.compute_machine_type
  instance_name_prefix    = "compute-desc"
  boot_disk_size          = var.compute_boot_disk_size
  boot_disk_type          = var.compute_boot_disk_type
  boot_image              = var.compute_boot_image
  network_tier            = var.compute_network_tier
  vm_instance_tags        = var.compute_instance_tags
  subnet_name             = var.private_subnet_name
  data_disks_per_instance = 1
  data_disk_block_size    = var.data_disk_physical_block_size_bytes
  data_disk_description   = "Spectrum Scale file system descriptor"
  data_disk_size          = 5
  data_disk_type          = var.data_disk_type
  ssh_user_name           = var.instances_ssh_user_name
  ssh_key_path            = var.instances_ssh_key_path
  private_key_path        = module.generate_keys.private_key_path
  public_key_path         = module.generate_keys.public_key_path
  operator_email          = var.operator_email
  scopes                  = var.scopes
}

locals {
  total_nsd_disks = var.data_disks_per_instance * var.total_storage_instances
}

module "create_data_disks_1A_zone" {
  source                    = "../../../resources/gcp/storage/compute_disk_create"
  total_data_disks          = length(var.zones) == 1 ? local.total_nsd_disks : local.total_nsd_disks / 2
  zone                      = var.zones.0
  data_disk_description     = "Spectrum Scale NSD disk"
  data_disk_name_prefix     = "storage"
  data_disk_size            = var.data_disk_size
  data_disk_type            = var.data_disk_type
  physical_block_size_bytes = var.data_disk_physical_block_size_bytes
}

module "create_data_disks_2A_zone" {
  source                    = "../../../resources/gcp/storage/compute_disk_create"
  total_data_disks          = length(var.zones) == 1 ? 0 : local.total_nsd_disks / 2
  zone                      = var.zones.1
  data_disk_description     = "Spectrum Scale NSD disk"
  data_disk_name_prefix     = "storage"
  data_disk_size            = var.data_disk_size
  data_disk_type            = var.data_disk_type
  physical_block_size_bytes = var.data_disk_physical_block_size_bytes
}

module "storage_instances_1A_zone" {
  source               = "../../../resources/gcp/compute_engine/vm_instance/vm_instance_0_disk"
  total_instances      = length(var.zones) > 1 ? var.total_storage_instances / 2 : var.total_storage_instances
  zone                 = var.zones.0
  instance_name_prefix = "storage"
  machine_type         = var.storage_machine_type
  boot_disk_size       = var.storage_boot_disk_size
  boot_disk_type       = var.storage_boot_disk_type
  boot_image           = var.storage_boot_image
  network_tier         = var.storage_network_tier
  vm_instance_tags     = var.compute_instance_tags
  subnet_name          = var.private_subnet_name
  ssh_user_name        = var.instances_ssh_user_name
  ssh_key_path         = var.instances_ssh_key_path
  private_key_path     = module.generate_keys.private_key_path
  public_key_path      = module.generate_keys.public_key_path
  operator_email       = var.operator_email
  scopes               = var.scopes
}

module "storage_instances_2A_zone" {
  source               = "../../../resources/gcp/compute_engine/vm_instance/vm_instance_0_disk"
  total_instances      = length(var.zones) > 1 ? var.total_storage_instances / 2 : 0
  zone                 = var.zones.1
  instance_name_prefix = "storage"
  machine_type         = var.storage_machine_type
  boot_disk_size       = var.storage_boot_disk_size
  boot_disk_type       = var.storage_boot_disk_type
  boot_image           = var.storage_boot_image
  network_tier         = var.storage_network_tier
  vm_instance_tags     = var.compute_instance_tags
  subnet_name          = var.private_subnet_name
  ssh_user_name        = var.instances_ssh_user_name
  ssh_key_path         = var.instances_ssh_key_path
  private_key_path     = module.generate_keys.private_key_path
  public_key_path      = module.generate_keys.public_key_path
  operator_email       = var.operator_email
  scopes               = var.scopes
}

module "attach_data_disk_1A_zone" {
  source                 = "../../../resources/gcp/storage/compute_disk_attach"
  total_disk_attachments = length(var.zones) > 1 ? local.total_nsd_disks / 2 : local.total_nsd_disks
  data_disk_ids          = module.create_data_disks_1A_zone.data_disk_id
  instance_ids           = module.storage_instances_1A_zone.instance_ids
}

module "attach_data_disk_2A_zone" {
  source                 = "../../../resources/gcp/storage/compute_disk_attach"
  total_disk_attachments = length(var.zones) > 1 ? local.total_nsd_disks / 2 : 0
  data_disk_ids          = module.create_data_disks_2A_zone.data_disk_id
  instance_ids           = module.storage_instances_2A_zone.instance_ids
}
