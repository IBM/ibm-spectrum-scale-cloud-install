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
  ssh_key_path         = var.instances_ssh_public_key_path
  private_key_path     = module.generate_keys.private_key_path
  public_key_path      = module.generate_keys.public_key_path
}

module "desc_compute_instance" {
  source                  = "../../../resources/gcp/compute_engine/vm_instance/vm_instance_1_disk"
  total_instances         = length(var.zones) >= 3 ? 1 : 0
  zone                    = length(var.zones) >= 3 ? var.zones.2 : var.zones.0
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
  ssh_key_path            = var.instances_ssh_public_key_path
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
  zone                      = length(var.zones) == 1 ? var.zones.0 : var.zones.1
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
  ssh_key_path         = var.instances_ssh_public_key_path
  private_key_path     = module.generate_keys.private_key_path
  public_key_path      = module.generate_keys.public_key_path
  operator_email       = var.operator_email
  scopes               = var.scopes
}

module "storage_instances_2A_zone" {
  source               = "../../../resources/gcp/compute_engine/vm_instance/vm_instance_0_disk"
  total_instances      = length(var.zones) > 1 ? var.total_storage_instances / 2 : 0
  zone                 = length(var.zones) == 1 ? var.zones.0 : var.zones.1
  instance_name_prefix = "storage"
  machine_type         = var.storage_machine_type
  boot_disk_size       = var.storage_boot_disk_size
  boot_disk_type       = var.storage_boot_disk_type
  boot_image           = var.storage_boot_image
  network_tier         = var.storage_network_tier
  vm_instance_tags     = var.compute_instance_tags
  subnet_name          = var.private_subnet_name
  ssh_user_name        = var.instances_ssh_user_name
  ssh_key_path         = var.instances_ssh_public_key_path
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

locals {
  compute_instance_desc_map = {
    for instance in module.desc_compute_instance.instance_ips_with_1_datadisks :
    instance => slice(var.data_disks_device_names, 0, 1)
  }
  storage_instance_1A_ips_device_names_map = length(var.zones) == 1 ? {
    for instance in module.storage_instances_1A_zone.instance_ips :
    instance => slice(var.data_disks_device_names, 0, var.data_disks_per_instance)
    } : {
    for instance in module.storage_instances_1A_zone.instance_ips :
    instance => slice(var.data_disks_device_names, 0, local.total_nsd_disks / 2)
  }
  storage_instance_2A_ips_device_names_map = length(var.zones) == 1 ? {
    for instance in module.storage_instances_2A_zone.instance_ips :
    instance => slice(var.data_disks_device_names, 0, 0)
    } : {
    for instance in module.storage_instances_2A_zone.instance_ips :
    instance => slice(var.data_disks_device_names, 0, local.total_nsd_disks / 2)
  }

  storage_instance_ips_with_0_datadisks  = var.data_disks_per_instance == 0 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_1_datadisks  = var.data_disks_per_instance == 1 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_2_datadisks  = var.data_disks_per_instance == 2 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_3_datadisks  = var.data_disks_per_instance == 3 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_4_datadisks  = var.data_disks_per_instance == 4 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_5_datadisks  = var.data_disks_per_instance == 5 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_6_datadisks  = var.data_disks_per_instance == 6 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_7_datadisks  = var.data_disks_per_instance == 7 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_8_datadisks  = var.data_disks_per_instance == 8 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_9_datadisks  = var.data_disks_per_instance == 9 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_10_datadisks = var.data_disks_per_instance == 10 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_11_datadisks = var.data_disks_per_instance == 11 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_12_datadisks = var.data_disks_per_instance == 12 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_13_datadisks = var.data_disks_per_instance == 13 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_14_datadisks = var.data_disks_per_instance == 14 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null
  storage_instance_ips_with_15_datadisks = var.data_disks_per_instance == 15 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ips : concat(module.storage_instances_1A_zone.instance_ips, module.storage_instances_2A_zone.instance_ips)) : null

  storage_instance_ids_with_0_datadisks  = var.data_disks_per_instance == 0 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_1_datadisks  = var.data_disks_per_instance == 1 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_2_datadisks  = var.data_disks_per_instance == 2 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_3_datadisks  = var.data_disks_per_instance == 3 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_4_datadisks  = var.data_disks_per_instance == 4 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_5_datadisks  = var.data_disks_per_instance == 5 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_6_datadisks  = var.data_disks_per_instance == 6 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_7_datadisks  = var.data_disks_per_instance == 7 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_8_datadisks  = var.data_disks_per_instance == 8 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_9_datadisks  = var.data_disks_per_instance == 9 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_10_datadisks = var.data_disks_per_instance == 10 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_11_datadisks = var.data_disks_per_instance == 11 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_12_datadisks = var.data_disks_per_instance == 12 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_13_datadisks = var.data_disks_per_instance == 13 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_14_datadisks = var.data_disks_per_instance == 14 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null
  storage_instance_ids_with_15_datadisks = var.data_disks_per_instance == 15 ? (length(var.zones) == 1 ? module.storage_instances_1A_zone.instance_ids : concat(module.storage_instances_1A_zone.instance_ids, module.storage_instances_2A_zone.instance_ids)) : null

  storage_instance_ips_0_datadisks_device_names_map = var.data_disks_per_instance == 0 ? {
    for instance in local.storage_instance_ips_with_0_datadisks :
    instance => slice(var.data_disks_device_names, 0, 0)
  } : null
  storage_instance_ips_1_datadisks_device_names_map = var.data_disks_per_instance == 1 ? {
    for instance in local.storage_instance_ips_with_1_datadisks :
    instance => slice(var.data_disks_device_names, 0, 1)
  } : null
  storage_instance_ips_2_datadisks_device_names_map = var.data_disks_per_instance == 2 ? {
    for instance in local.storage_instance_ips_with_2_datadisks :
    instance => slice(var.data_disks_device_names, 0, 2)
  } : null
  storage_instance_ips_3_datadisks_device_names_map = var.data_disks_per_instance == 3 ? {
    for instance in local.storage_instance_ips_with_3_datadisks :
    instance => slice(var.data_disks_device_names, 0, 3)
  } : null
  storage_instance_ips_4_datadisks_device_names_map = var.data_disks_per_instance == 4 ? {
    for instance in local.storage_instance_ips_with_4_datadisks :
    instance => slice(var.data_disks_device_names, 0, 4)
  } : null
  storage_instance_ips_5_datadisks_device_names_map = var.data_disks_per_instance == 5 ? {
    for instance in local.storage_instance_ips_with_5_datadisks :
    instance => slice(var.data_disks_device_names, 0, 5)
  } : null
  storage_instance_ips_6_datadisks_device_names_map = var.data_disks_per_instance == 6 ? {
    for instance in local.storage_instance_ips_with_6_datadisks :
    instance => slice(var.data_disks_device_names, 0, 6)
  } : null
  storage_instance_ips_7_datadisks_device_names_map = var.data_disks_per_instance == 7 ? {
    for instance in local.storage_instance_ips_with_7_datadisks :
    instance => slice(var.data_disks_device_names, 0, 7)
  } : null
  storage_instance_ips_8_datadisks_device_names_map = var.data_disks_per_instance == 8 ? {
    for instance in local.storage_instance_ips_with_8_datadisks :
    instance => slice(var.data_disks_device_names, 0, 8)
  } : null
  storage_instance_ips_9_datadisks_device_names_map = var.data_disks_per_instance == 9 ? {
    for instance in local.storage_instance_ips_with_9_datadisks :
    instance => slice(var.data_disks_device_names, 0, 9)
  } : null
  storage_instance_ips_10_datadisks_device_names_map = var.data_disks_per_instance == 10 ? {
    for instance in local.storage_instance_ips_with_10_datadisks :
    instance => slice(var.data_disks_device_names, 0, 10)
  } : null
  storage_instance_ips_11_datadisks_device_names_map = var.data_disks_per_instance == 11 ? {
    for instance in local.storage_instance_ips_with_11_datadisks :
    instance => slice(var.data_disks_device_names, 0, 11)
  } : null
  storage_instance_ips_12_datadisks_device_names_map = var.data_disks_per_instance == 12 ? {
    for instance in local.storage_instance_ips_with_12_datadisks :
    instance => slice(var.data_disks_device_names, 0, 12)
  } : null
  storage_instance_ips_13_datadisks_device_names_map = var.data_disks_per_instance == 13 ? {
    for instance in local.storage_instance_ips_with_13_datadisks :
    instance => slice(var.data_disks_device_names, 0, 13)
  } : null
  storage_instance_ips_14_datadisks_device_names_map = var.data_disks_per_instance == 14 ? {
    for instance in local.storage_instance_ips_with_14_datadisks :
    instance => slice(var.data_disks_device_names, 0, 14)
  } : null
  storage_instance_ips_15_datadisks_device_names_map = var.data_disks_per_instance == 15 ? {
    for instance in local.storage_instance_ips_with_15_datadisks :
    instance => slice(var.data_disks_device_names, 0, 15)
  } : null
}

module "invoke_scale_playbook" {
  source     = "../../../resources/common/ansible_scale_playbook"
  region     = var.region
  stack_name = var.stack_name

  tf_data_path            = var.tf_data_path
  tf_input_json_root_path = var.tf_input_json_root_path == null ? abspath(path.cwd) : var.tf_input_json_root_path
  tf_input_json_file_name = var.tf_input_json_file_name == null ? join(", ", fileset(abspath(path.cwd), "*.tfvars*")) : var.tf_input_json_file_name

  bucket_name                    = var.bucket_name
  scale_infra_repo_clone_path    = var.scale_infra_repo_clone_path
  create_scale_cluster           = var.create_scale_cluster
  generate_ansible_inv           = var.generate_ansible_inv
  scale_version                  = var.scale_version
  filesystem_mountpoint          = var.filesystem_mountpoint
  filesystem_block_size          = var.filesystem_block_size
  generate_jumphost_ssh_config   = var.generate_jumphost_ssh_config
  bastion_public_ip              = var.bastion_public_ip
  instances_ssh_private_key_path = var.instances_ssh_private_key_path
  instances_ssh_user_name        = var.instances_ssh_user_name
  private_subnet_cidr            = var.private_subnet_cidr

  cloud_platform   = "GCP"
  avail_zones      = jsonencode(var.zones)
  notification_arn = "None"

  compute_instances_by_id   = module.compute_instances.instance_ids_with_0_datadisks == null ? "[]" : jsonencode(module.compute_instances.instance_ids_with_0_datadisks)
  compute_instances_by_ip   = module.compute_instances.instance_ips_with_0_datadisks == null ? "[]" : jsonencode(module.compute_instances.instance_ips_with_0_datadisks)
  compute_instance_desc_map = jsonencode(local.compute_instance_desc_map)
  compute_instance_desc_id  = jsonencode(module.desc_compute_instance.instance_ids_with_1_datadisks)

  storage_instance_ids_with_0_datadisks  = local.storage_instance_ids_with_0_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_0_datadisks)
  storage_instance_ids_with_1_datadisks  = local.storage_instance_ids_with_1_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_1_datadisks)
  storage_instance_ids_with_2_datadisks  = local.storage_instance_ids_with_2_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_2_datadisks)
  storage_instance_ids_with_3_datadisks  = local.storage_instance_ids_with_3_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_3_datadisks)
  storage_instance_ids_with_4_datadisks  = local.storage_instance_ids_with_4_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_4_datadisks)
  storage_instance_ids_with_5_datadisks  = local.storage_instance_ids_with_5_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_5_datadisks)
  storage_instance_ids_with_6_datadisks  = local.storage_instance_ids_with_6_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_6_datadisks)
  storage_instance_ids_with_7_datadisks  = local.storage_instance_ids_with_7_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_7_datadisks)
  storage_instance_ids_with_8_datadisks  = local.storage_instance_ids_with_8_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_8_datadisks)
  storage_instance_ids_with_9_datadisks  = local.storage_instance_ids_with_9_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_9_datadisks)
  storage_instance_ids_with_10_datadisks = local.storage_instance_ids_with_10_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_10_datadisks)
  storage_instance_ids_with_11_datadisks = local.storage_instance_ids_with_11_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_11_datadisks)
  storage_instance_ids_with_12_datadisks = local.storage_instance_ids_with_12_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_12_datadisks)
  storage_instance_ids_with_13_datadisks = local.storage_instance_ids_with_13_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_13_datadisks)
  storage_instance_ids_with_14_datadisks = local.storage_instance_ids_with_14_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_14_datadisks)
  storage_instance_ids_with_15_datadisks = local.storage_instance_ids_with_15_datadisks == null ? "[]" : jsonencode(local.storage_instance_ids_with_15_datadisks)

  storage_instance_ips_with_0_datadisks_device_names_map = local.storage_instance_ips_0_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_0_datadisks_device_names_map)
  storage_instance_ips_with_1_datadisks_device_names_map = "[]"
  #storage_instance_ips_with_1_datadisks_device_names_map  = local.storage_instance_ips_1_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_1_datadisks_device_names_map)
  storage_instance_ips_with_2_datadisks_device_names_map  = local.storage_instance_ips_2_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_2_datadisks_device_names_map)
  storage_instance_ips_with_3_datadisks_device_names_map  = local.storage_instance_ips_3_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_3_datadisks_device_names_map)
  storage_instance_ips_with_4_datadisks_device_names_map  = local.storage_instance_ips_4_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_4_datadisks_device_names_map)
  storage_instance_ips_with_5_datadisks_device_names_map  = local.storage_instance_ips_5_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_5_datadisks_device_names_map)
  storage_instance_ips_with_6_datadisks_device_names_map  = local.storage_instance_ips_6_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_6_datadisks_device_names_map)
  storage_instance_ips_with_7_datadisks_device_names_map  = local.storage_instance_ips_7_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_7_datadisks_device_names_map)
  storage_instance_ips_with_8_datadisks_device_names_map  = local.storage_instance_ips_8_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_8_datadisks_device_names_map)
  storage_instance_ips_with_9_datadisks_device_names_map  = local.storage_instance_ips_9_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_9_datadisks_device_names_map)
  storage_instance_ips_with_10_datadisks_device_names_map = local.storage_instance_ips_10_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_10_datadisks_device_names_map)
  storage_instance_ips_with_11_datadisks_device_names_map = local.storage_instance_ips_11_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_11_datadisks_device_names_map)
  storage_instance_ips_with_12_datadisks_device_names_map = local.storage_instance_ips_12_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_12_datadisks_device_names_map)
  storage_instance_ips_with_13_datadisks_device_names_map = local.storage_instance_ips_13_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_13_datadisks_device_names_map)
  storage_instance_ips_with_14_datadisks_device_names_map = local.storage_instance_ips_14_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_14_datadisks_device_names_map)
  storage_instance_ips_with_15_datadisks_device_names_map = local.storage_instance_ips_15_datadisks_device_names_map == null ? "[]" : jsonencode(local.storage_instance_ips_15_datadisks_device_names_map)
}
