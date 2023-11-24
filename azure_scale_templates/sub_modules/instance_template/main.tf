/*
  Creates compute and storage cluster VM for Azure
    - Spin storage cluster instances
    - Spin compute cluster instances
    - Generates ansible inventory file for scale cluster deployment
*/

locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets == null && var.vpc_compute_cluster_private_subnets != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets != null) ? "combined" : "none"
  )
  block_device_names = ["/dev/sdc", "/dev/sdd", "/dev/sdf", "/dev/sdg",
  "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdm", "/dev/sdn", "/dev/sdo", "/dev/sdp", "/dev/sdq"]
  gpfs_base_rpm_path = var.spectrumscale_rpms_path == null ? fileset(var.spectrumscale_rpms_path, "gpfs.base-*") : null
  ssd_device_names   = [for i in range(var.scratch_devices_per_storage_instance) : "/dev/nvme0n${i + 1}"]
  scale_version      = local.gpfs_base_rpm_path != null ? regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0] : null
}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
}

module "proximity_group" {
  source                  = "../../../resources/azure/compute/proximity_placement_group"
  proximity_group_name    = var.resource_prefix
  resource_group_name     = var.resource_group_name
  location                = var.vpc_region
  vnet_availability_zones = var.vpc_availability_zones
}

resource "time_sleep" "wait_30_seconds" {
  depends_on       = [module.proximity_group]
  destroy_duration = "30s"
}

/*
    Generate a list of compute vm name(s).
    Ex: vm_list = ["vm-1", "vm-2", "vm-3",]
*/
resource "null_resource" "generate_compute_vm_name" {
  count = (local.cluster_type == "compute" || local.cluster_type == "combined") ? (var.total_compute_cluster_instances != null) ? var.total_compute_cluster_instances : 0 : 0
  triggers = {
    vm_name = format("%s-compute-%s", var.resource_prefix, count.index + 1)
  }
}

/*
    Generate a map using compute vm name key and values of subnet and zone.
    Ex:
        compute_vm_zone_map = {
            "vm-1" = {
                "subnet" = "test-public-subnet-1"
                "zone" = "1"
            }
            "vm-2" = {
                "subnet" = "test-public-subnet-0"
                "zone" = "1"
            }
        }
*/
locals {
  compute_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_compute_vm_name[*].triggers.vm_name :
    vm_name => {
      zone   = element(var.vpc_availability_zones, idx)
      subnet = element(var.vpc_compute_cluster_private_subnets, idx)
    }
  }
}

module "compute_cluster_instances" {
  for_each                     = local.compute_vm_zone_map
  source                       = "../../../resources/azure/compute/vm_0_disk"
  vm_name                      = each.key
  image_publisher              = var.compute_cluster_image_publisher
  image_offer                  = var.compute_cluster_image_offer
  image_sku                    = var.compute_cluster_image_sku
  image_version                = var.compute_cluster_image_version
  subnet_id                    = each.value["subnet"]
  resource_group_name          = var.resource_group_name
  location                     = var.vpc_region
  vm_size                      = var.compute_cluster_instance_type
  login_username               = var.compute_cluster_login_username
  proximity_placement_group_id = length(var.vpc_availability_zones) > 1 ? null : module.proximity_group.proximity_group_compute_id
  os_disk_caching              = var.compute_cluster_os_disk_caching
  os_storage_account_type      = var.compute_boot_disk_type
  user_public_key              = var.create_separate_namespaces == true ? var.compute_cluster_ssh_public_key : var.storage_cluster_ssh_public_key
  meta_private_key             = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key              = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  dns_zone                     = var.compute_cluster_dns_zone
  availability_zone            = each.value["zone"]
}

/*
    Generate a list of storage vm name(s).
    Ex: vm_list = ["vm-1", "vm-2", "vm-3",]
*/
resource "null_resource" "generate_storage_vm_name" {
  count = (local.cluster_type == "storage" || local.cluster_type == "combined") ? (var.total_storage_cluster_instances != null) ? var.total_storage_cluster_instances : 0 : 0
  triggers = {
    vm_name = format("%s-storage-%s", var.resource_prefix, count.index + 1)
  }
}

/*
    Generate a map using storage vm name key and values of disks list, subnet and zone.
    Ex:
        storage_vm_zone_map = {
            "vm-1" = {
                "disks" = ["vm-1-disk-1", "vm-1-disk-2",]
                "subnet" = "test-private-subnet-1"
                "zone" = "1"
            }
            "vm-2" = {
                "disks" = ["vm-1-disk-1", "vm-1-disk-2",]
                "subnet" = "test-private-subnet-0"
                "zone" = "1"
            }
        }
*/
locals {
  storage_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_storage_vm_name[*].triggers.vm_name :
    vm_name => {
      zone   = length(var.vpc_availability_zones) > 1 ? element(slice(var.vpc_availability_zones, 0, 2), idx) : element(var.vpc_availability_zones, idx)                                        # Consider only first 2 elements in multi-az
      subnet = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx) # Consider only first 2 elements
      disks  = toset([for i in range(1, var.block_devices_per_storage_instance + 1) : "${vm_name}-data-${i}"])                                                                                  // TODO# later use the disk                                                                              # Persistent disk names
    }
  }
}

module "storage_cluster_instances" {
  for_each                        = local.storage_vm_zone_map
  source                          = "../../../resources/azure/compute/vm_multiple_disk"
  vm_name                         = each.key
  image_publisher                 = var.storage_cluster_image_publisher
  image_offer                     = var.storage_cluster_image_offer
  image_sku                       = var.storage_cluster_image_sku
  image_version                   = var.storage_cluster_image_version
  subnet_id                       = each.value["subnet"]
  resource_group_name             = var.resource_group_name
  location                        = var.vpc_region
  vm_size                         = var.storage_cluster_instance_type
  login_username                  = var.storage_cluster_login_username
  proximity_placement_group_id    = length(var.vpc_availability_zones) > 1 ? null : module.proximity_group.proximity_group_storage_id
  os_disk_caching                 = var.storage_cluster_os_disk_caching
  os_storage_account_type         = var.storage_boot_disk_type
  data_disks_per_storage_instance = var.block_devices_per_storage_instance
  data_disk_device_names          = local.block_device_names
  data_disk_size                  = var.block_device_volume_size
  data_disk_storage_account_type  = var.block_device_volume_type
  user_public_key                 = var.storage_cluster_ssh_public_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                 = module.generate_storage_cluster_keys.public_key_content
  dns_zone                        = var.storage_cluster_dns_zone
  availability_zone               = each.value["zone"]
}

/*
     Generate a list of storage tie-breaker vm name(s).
     Ex: vm_list = ["vm-1",]
*/
resource "null_resource" "generate_storage_tie_vm_name" {
  count = (local.cluster_type == "storage" || local.cluster_type == "combined") && (var.total_storage_cluster_instances > 0) ? (length(var.vpc_availability_zones) > 1 ? 1 : 0) : 0
  triggers = {
    vm_name = format("%s-storage-tie", var.resource_prefix)
  }
}

/*
    Generate a map using storage vm name key and values of disks list, subnet and zone.
    Ex:
        storage_vm_zone_map = {
            "vm-1" = {
                "disks" = ["vm-1-disk-1",]
                "subnet" = "test-private-subnet-1"
                "zone" = "1"
            }
        }
*/
locals {
  storage_tie_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_storage_tie_vm_name[*].triggers.vm_name :
    vm_name => {
      zone   = var.vpc_availability_zones[2]                      # Consider only last element
      subnet = var.vpc_storage_cluster_private_subnets[2]         # Consider only last 2 elements
      disks  = toset([for i in range(1) : "${vm_name}-tie-disk"]) # Persistent disk name TODO# later use the disks    
    }
  }
}

module "storage_cluster_tie_breaker_instance" {
  for_each                        = local.storage_tie_vm_zone_map
  source                          = "../../../resources/azure/compute/vm_multiple_disk"
  vm_name                         = format("%s-storage-tie", var.resource_prefix)
  image_publisher                 = var.storage_cluster_image_publisher
  image_offer                     = var.storage_cluster_image_offer
  image_sku                       = var.storage_cluster_image_sku
  image_version                   = var.storage_cluster_image_version
  subnet_id                       = each.value["subnet"]
  resource_group_name             = var.resource_group_name
  location                        = var.vpc_region
  vm_size                         = var.storage_cluster_instance_type
  login_username                  = var.storage_cluster_login_username
  proximity_placement_group_id    = length(var.vpc_availability_zones) > 1 ? null : module.proximity_group.proximity_group_storage_id
  os_disk_caching                 = var.storage_cluster_os_disk_caching
  os_storage_account_type         = var.storage_boot_disk_type
  data_disks_per_storage_instance = 1
  data_disk_device_names          = local.block_device_names
  data_disk_size                  = var.block_device_volume_size
  data_disk_storage_account_type  = var.block_device_volume_type
  user_public_key                 = var.storage_cluster_ssh_public_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                 = module.generate_storage_cluster_keys.public_key_content
  dns_zone                        = var.storage_cluster_dns_zone
  availability_zone               = each.value["zone"]
}

module "prepare_ansible_configuration" {
  turn_on    = true
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

# Write the compute cluster related inventory.
module "write_compute_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == true && local.cluster_type == "compute" || local.cluster_type == "combined") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode("None")
  compute_cluster_filesystem_mountpoint            = jsonencode(var.compute_cluster_filesystem_mountpoint)
  bastion_instance_id                              = var.bastion_instance_ref == null ? jsonencode("None") : jsonencode(var.bastion_instance_ref)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(flatten([for instance in module.compute_cluster_instances : instance.instance_ids]))
  compute_cluster_instance_private_ips             = jsonencode([for instance in module.compute_cluster_instances : instance.instance_private_ips])
  compute_cluster_instance_private_dns_ip_map      = length(module.compute_cluster_instances) > 0 ? jsonencode([for instance in module.compute_cluster_instances : instance.instance_dns_name]) : jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode("None")
  storage_cluster_instance_ids                     = jsonencode([])
  storage_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_with_data_volume_mapping         = jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([])
  storage_cluster_desc_instance_private_ips        = jsonencode([])
  storage_cluster_desc_data_volume_mapping         = jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode({})
  compute_subnet_cidr                              = jsonencode("None")
  storage_subnet_cidr                              = jsonencode("None")
  opposit_cluster_clustername                      = jsonencode("None")
  compute_cluster_instance_names                   = jsonencode("None")
  storage_cluster_instance_names                   = jsonencode("None")
}

locals {
  storage_cluster_private_ips                = (local.cluster_type == "storage" || local.cluster_type == "combined") && (var.total_storage_cluster_instances != null) ? [for instance in module.storage_cluster_instances : instance.instance_private_ips] : []
  storage_instance_ips_with_disk_mapping     = (local.cluster_type == "storage" || local.cluster_type == "combined") && var.total_storage_cluster_instances != null && var.block_devices_per_storage_instance > 0 ? { for ip in local.storage_cluster_private_ips : ip => slice(local.block_device_names, 0, var.block_devices_per_storage_instance) } : { for ip in local.storage_cluster_private_ips : ip => slice(local.ssd_device_names, 0, var.scratch_devices_per_storage_instance) }
  storage_cluster_desc_private_ips           = (local.cluster_type == "storage" || local.cluster_type == "combined") && (var.total_storage_cluster_instances != null) && length(var.vpc_availability_zones) > 1 ? [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips] : []
  storage_instance_desc_ip_with_disk_mapping = (local.cluster_type == "storage" || local.cluster_type == "combined") && var.total_storage_cluster_instances != null && var.block_devices_per_storage_instance > 0 && length(var.vpc_availability_zones) > 1 ? { for ip in local.storage_cluster_desc_private_ips : ip => slice(local.block_device_names, 0, 1) } : {}
}

# Write the storage cluster related inventory.
module "write_storage_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == true && local.cluster_type == "storage" || local.cluster_type == "combined") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_ref == null ? jsonencode("None") : jsonencode(var.bastion_instance_ref)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode([])
  compute_cluster_instance_private_ips             = jsonencode([])
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode([for instance in module.storage_cluster_instances : instance.instance_ids])
  storage_cluster_instance_private_ips             = jsonencode([for instance in module.storage_cluster_instances : instance.instance_private_ips])
  storage_cluster_with_data_volume_mapping         = length(module.storage_cluster_instances) > 0 ? jsonencode(local.storage_instance_ips_with_disk_mapping) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = length(module.storage_cluster_instances) > 0 ? jsonencode([for instance in module.storage_cluster_instances : instance.instance_dns_name]) : jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids])
  storage_cluster_desc_instance_private_ips        = jsonencode([for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips])
  storage_cluster_desc_data_volume_mapping         = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode(local.storage_instance_desc_ip_with_disk_mapping) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode([for instance in module.storage_cluster_tie_breaker_instance : instance.instance_dns_name]) : jsonencode({})
  compute_subnet_cidr                              = jsonencode("None")
  storage_subnet_cidr                              = jsonencode("None")
  opposit_cluster_clustername                      = jsonencode("None")
  compute_cluster_instance_names                   = jsonencode("None")
  storage_cluster_instance_names                   = jsonencode("None")
}

# Write combined cluster related inventory.
module "write_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == false && local.cluster_type == "combined") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_ref == null ? jsonencode("None") : jsonencode(var.bastion_instance_ref)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode([for instance in module.compute_cluster_instances : instance.instance_ids])
  compute_cluster_instance_private_ips             = jsonencode([for instance in module.compute_cluster_instances : instance.instance_private_ips])
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode([for instance in module.storage_cluster_instances : instance.instance_ids])
  storage_cluster_instance_private_ips             = jsonencode([for instance in module.storage_cluster_instances : instance.instance_private_ips])
  storage_cluster_with_data_volume_mapping         = length(module.storage_cluster_instances) > 0 ? jsonencode(local.storage_instance_ips_with_disk_mapping) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = length(module.storage_cluster_instances) > 0 ? jsonencode([for instance in module.storage_cluster_instances : instance.instance_dns_name]) : jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids])
  storage_cluster_desc_instance_private_ips        = jsonencode([for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips])
  storage_cluster_desc_data_volume_mapping         = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode(local.storage_instance_desc_ip_with_disk_mapping) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode([for instance in module.storage_cluster_tie_breaker_instance : instance.instance_dns_name]) : jsonencode({})
  compute_subnet_cidr                              = jsonencode("None")
  storage_subnet_cidr                              = jsonencode("None")
  opposit_cluster_clustername                      = jsonencode("None")
  compute_cluster_instance_names                   = jsonencode("None")
  storage_cluster_instance_names                   = jsonencode("None")
}

# Configure the compute cluster using ansible based on the create_scale_cluster input.
module "compute_cluster_configuration" {
  source                          = "../../../resources/common/compute_configuration"
  turn_on                         = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true) ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete        = module.write_compute_cluster_inventory.write_inventory_complete
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  memory_size                     = 8
  max_pagepool_gb                 = 4
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_compute_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
}

# Configure the storage cluster using ansible based on the create_scale_cluster input.
module "storage_cluster_configuration" {
  source                          = "../../../resources/common/storage_configuration"
  turn_on                         = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true) ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete        = module.write_storage_cluster_inventory.write_inventory_complete
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = true
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = 5
  max_pagepool_gb                 = 16
  vcpu_count                      = 2
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  depends_on                      = [module.storage_cluster_instances]
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  max_mbps                        = 50000 * 0.25 # TODO: maximum egress bandwidth limit ranges from 50-200 Gbps
  disk_type                       = jsonencode("None")
  max_data_replicas               = jsonencode("None")
  max_metadata_replicas           = jsonencode("None")
  default_metadata_replicas       = 3
  default_data_replicas           = 3
}

# Configure the combined cluster using ansible based on the create_scale_cluster input.
module "combined_cluster_configuration" {
  source                          = "../../../resources/common/scale_configuration"
  turn_on                         = (var.create_remote_mount_cluster == false && local.cluster_type == "combined") ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete        = module.write_cluster_inventory.write_inventory_complete
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = 4
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
}
