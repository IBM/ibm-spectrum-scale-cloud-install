locals {
  compute_or_combined = ((var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") && var.total_compute_cluster_instances > 0) ? true : false
  storage_or_combined = ((var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.total_storage_cluster_instances > 0) ? true : false
  storage_and_gateway = ((var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.total_gateway_instances > 0) ? true : false

  tcp_port_scale_cluster         = ["22", "1191", "60000-61000", "47080", "4444", "4739", "9080", "9081", "80", "443"]
  udp_port_scale_cluster         = ["47443", "4739"]
  tcp_port_bastion_scale_cluster = ["22", "443"]

  create_placement_group = (length(var.vpc_availability_zones) == 1 && var.enable_placement_group == true) ? true : false # Placement group does not spread across multiple availability zones
  block_device_names = ["/dev/sdb", "/dev/sdc", "/dev/sdd", "/dev/sdf", "/dev/sdg",
  "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdm", "/dev/sdn", "/dev/sdo", "/dev/sdp", "/dev/sdq"]
  instance_storage_device_names = [for i in range(var.scratch_devices_per_storage_instance) : "/dev/nvme${i}n1"] # [/dev/nvme0n1, /dev/nvme1n1, /dev/nvme2n1]

  gpfs_base_rpm_path = var.spectrumscale_rpms_path != null ? fileset(var.spectrumscale_rpms_path, "gpfs.base-*") : null
  scale_version      = local.gpfs_base_rpm_path != null ? regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0] : null
}

/*
    Generate a list of compute vm name(s).
    Ex: vm_list = ["vm-compute-1", "vm-compute-2", "vm-compute-3",]
*/
resource "null_resource" "generate_compute_vm_name" {
  count = local.compute_or_combined ? var.total_compute_cluster_instances : 0
  triggers = {
    vm_name = format("%s-compute-%s", var.resource_prefix, count.index + 1)
  }
}

/*
    Generate a list of storage vm name(s).
    Ex: vm_list = ["vm-storage-1", "vm-storage-2", "vm-storage-3", "vm-storage-4",]
*/
resource "null_resource" "generate_storage_vm_name" {
  count = local.storage_or_combined ? var.total_storage_cluster_instances : 0
  triggers = {
    vm_name = format("%s-storage-%s", var.resource_prefix, count.index + 1)
  }
}

/*
     Generate a list of storage tie-breaker vm name(s).
     Ex: vm_list = ["vm-storage-tie",]
*/
resource "null_resource" "generate_storage_tie_vm_name" {
  count = local.storage_or_combined && length(var.vpc_availability_zones) > 1 ? 1 : 0
  triggers = {
    vm_name = format("%s-storage-tie", var.resource_prefix)
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

/*
    Generate a list of gateway vm name(s).
    Ex: vm_list = ["vm-gateway-1", "vm-gateway-2",]
*/
resource "null_resource" "generate_gateway_vm_name" {
  count = local.storage_and_gateway ? var.total_gateway_instances : 0
  triggers = {
    vm_name = format("%s-gateway-%s", var.resource_prefix, count.index + 1)
  }
}

/*
    Generate a map using gateway vm name key and values of subnet.
    Ex:
        gateway_vm_subnet_map = {
            "vm-gateway-1" = {
                "subnet" = "test-private-subnet-1"
            }
            "vm-gateway-2" = {
                "subnet" = "test-public-subnet-2"
            }
        }
*/
locals {
  gateway_vm_subnet_map = {
    for idx, vm_name in resource.null_resource.generate_gateway_vm_name[*].triggers.vm_name :
    vm_name => {
      # Consider only first 2 elements
      zone   = length(var.vpc_availability_zones) > 1 ? element(slice(var.vpc_availability_zones, 0, 2), idx) : element(var.vpc_availability_zones, idx)
      subnet = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx)
    }
  }
}

/*
    Generate a map using storage vm name key and values of disks list, subnet.
    Ex:
        storage_vm_zone_map = {
          subnet = "test-subnet-1"
          zone   = "eastus"
          "vm-storage-1" = {
            "disks" = {
                "fs1-gold-1" = {
                    device_name = "/dev/xvdi"
                    encrypted   = false
                    iops        = null
                    kms_key     = null
                    size        = "500"
                    termination = true
                    throughput  = null
                    type        = "Standard_LRS"
                    lun_no      = "1"
                }
                "fs1-system-1" = {
                    device_name = "/dev/xvdi"
                    encrypted   = false
                    iops        = null
                    kms_key     = null
                    size        = "500"
                    termination = true
                    throughput  = null
                    type        = "Standard_LRS"
                    lun_no      = "2"
                }
                "fs1-system-2" = {
                  device_name = "/dev/xvdi"
                  encrypted   = false
                  iops        = null
                  kms_key     = null
                  size        = "500"
                  termination = true
                  throughput  = null
                  type        = "Standard_LRS"
                  lun_no      = "3"
                }
                "fs2-system-1" = {
                  device_name = "/dev/xvdi"
                  encrypted   = false
                  iops        = null
                  kms_key     = null
                  size        = "500"
                  termination = true
                  throughput  = null
                  type        = "Standard_LRS"
                  lun         = "1"
                  lun_no      = "4"
                }
            }
        }
*/
locals {
  encryption_set_ids = {
    for idx, fs in var.filesystem_parameters : fs.name =>
    fs.filesystem_encrypted ? module.data_disk_encryption_set[idx].enc_set_id : null
  }

  inflate_disks_per_fs_pool = flatten([
    for fs_config in var.filesystem_parameters != null ? var.filesystem_parameters : [] : [
      for disk_details in fs_config.disk_config : {
        for i in range(var.scratch_devices_per_storage_instance > 0 ? var.scratch_devices_per_storage_instance : disk_details.block_devices_per_storage_instance) :
        "${fs_config.name}-${disk_details.filesystem_pool}-${i + 1}" => {
          "fs_name"                = fs_config.name
          "config_file"            = fs_config.filesystem_config_file
          "encrypted"              = fs_config.filesystem_encrypted
          "disk_encryption_set_id" = local.encryption_set_ids[fs_config.name]
          "termination"            = fs_config.device_delete_on_termination
          "pool"                   = disk_details.filesystem_pool
          "size"                   = disk_details.block_device_volume_size
          "type"                   = disk_details.block_device_volume_type
          "iops"                   = disk_details.block_device_iops
          "throughput"             = disk_details.block_device_throughput
        }
      }
    ]
  ])
  flatten_disks_per_vm = flatten([
    for pool in local.inflate_disks_per_fs_pool :
    [for disk, properties in pool :
      {
        name                   = disk
        fs_name                = properties["fs_name"]
        pool                   = properties["pool"]
        config                 = properties["config_file"]
        encrypted              = properties["encrypted"]
        disk_encryption_set_id = properties["disk_encryption_set_id"]
        termination            = properties["termination"]
        size                   = properties["size"]
        type                   = properties["type"]
        iops                   = properties["iops"]
        throughput             = properties["throughput"]
      }
    ]
  ])
  flatten_tie_disk = flatten([
    for fs_config in var.filesystem_parameters != null ? var.filesystem_parameters : [] : [
      [for disk_config in fs_config.disk_config :
        {
          name                   = format("%s-tie", fs_config.name)
          fs_name                = fs_config.name
          pool                   = "system"
          config                 = fs_config.filesystem_config_file
          encrypted              = fs_config.filesystem_encrypted
          disk_encryption_set_id = local.encryption_set_ids[fs_config.name]
          termination            = fs_config.device_delete_on_termination
          size                   = "5"
          type                   = "Standard_LRS"
          throughput             = null
          iops                   = null
        }
      ]
    ]
  ])
}

locals {
  storage_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_storage_vm_name[*].triggers.vm_name :
    vm_name => {
      # Consider only first 2 elements in multi-az
      zone   = length(var.vpc_availability_zones) > 1 ? element(slice(var.vpc_availability_zones, 0, 2), idx) : element(var.vpc_availability_zones, idx)
      subnet = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx)
      disks = var.scratch_devices_per_storage_instance > 0 ? {} : tomap({
        for idx, disk in tolist(local.flatten_disks_per_vm) :
        format("%s-%s", vm_name, disk["name"]) => {
          size                   = disk["size"]
          type                   = disk["type"]
          termination            = disk["termination"]
          iops                   = disk["iops"]
          throughput             = disk["throughput"]
          encrypted              = disk["encrypted"]
          disk_encryption_set_id = disk["disk_encryption_set_id"]
          fs_name                = disk["fs_name"]
          pool                   = disk["pool"]
          lun_no                 = idx
          device_name            = element(local.block_device_names, idx)
        } if length(var.marked_vm_names_to_attach_disks) == 0 || contains(var.marked_vm_names_to_attach_disks, vm_name)
      })
    }
  }

  filesystem_details = local.storage_or_combined ? { for fs_config in var.filesystem_parameters : fs_config.name => fs_config.filesystem_config_file } : {}
  storage_instance_ips_with_disk_mapping = {
    for idx, vm_name in resource.null_resource.generate_storage_vm_name[*].triggers.vm_name :
    format("%s.%s", vm_name, var.vpc_storage_cluster_dns_domain) => {
      zone = length(var.vpc_availability_zones) > 1 ? element(slice(var.vpc_availability_zones, 0, 2), idx) : element(var.vpc_availability_zones, idx)
      disks = var.scratch_devices_per_storage_instance > 0 ? tomap({
        for jdx, disk in tolist(local.flatten_disks_per_vm) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.instance_storage_device_names, jdx)
        } if length(var.marked_vm_names_to_attach_disks) == 0 || anytrue([for marked_vm in var.marked_vm_names_to_attach_disks : can(regex(marked_vm, format("%s.%s", vm_name, var.vpc_storage_cluster_dns_domain)))])
        }) : tomap({
        for jdx, disk in tolist(local.flatten_disks_per_vm) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = format("disk/azure/scsi1/lun%s", jdx)
        } if length(var.marked_vm_names_to_attach_disks) == 0 || anytrue([for marked_vm in var.marked_vm_names_to_attach_disks : can(regex(marked_vm, format("%s.%s", vm_name, var.vpc_storage_cluster_dns_domain)))])
      })
    }
  }
}

/*
    Generate a map using storage vm name key and values of disks list, subnet and zone.
    Ex:
        storage_vm_zone_map = {
            "vm-tie" = {
                "zone"  = "us-east-2a"
                "disks" = {
                    "fs1-tie": {
                        device_name = "/dev/xvdf"
                        encrypted   = false
                        fs_name     = "fs1"
                        iops        = null
                        kms_key     = null
                        pool        = null
                        size        = "5"
                        termination = true
                        throughput  = null
                        type        = "Standard_LRS"
                        lun_no      = "1"
                    },
                    "fs2-tie": {
                        device_name = "/dev/xvdg"
                        encrypted   = false
                        fs_name     = "fs1"
                        iops        = null
                        kms_key     = null
                        pool        = null
                        size        = "5"
                        termination = true
                        throughput  = null
                        type        = "Standard_LRS"
                        lun_no      = "2"
                    }
                    "subnet" = "test-private-subnet-1"
                    "zone" = "eastus"
                    }
                }
            }
*/

locals {
  storage_tie_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_storage_tie_vm_name[*].triggers.vm_name :
    vm_name => {
      zone   = var.vpc_availability_zones[2]              # Consider only last element
      subnet = var.vpc_storage_cluster_private_subnets[2] # Consider only last element
      disks = tomap({
        for idx, disk in tolist(local.flatten_tie_disk) :
        format("%s-%s", vm_name, disk["name"]) => {
          size                   = disk["size"]
          type                   = disk["type"]
          termination            = disk["termination"]
          iops                   = disk["iops"]
          throughput             = disk["throughput"]
          encrypted              = disk["encrypted"]
          disk_encryption_set_id = disk["disk_encryption_set_id"]
          fs_name                = disk["fs_name"]
          pool                   = disk["pool"]
          device_name            = element(local.block_device_names, idx)
          lun_no                 = idx
        }
      })
    }
  }

  storage_instance_desc_ip_with_disk_mapping = {
    for idx, vm_ipaddr in [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details["private_ip"]] :
    vm_ipaddr => {
      zone = var.vpc_availability_zones[2]
      disks = tomap({
        for jdx, disk in tolist(local.flatten_tie_disk) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = "disk/azure/scsi1/lun0"
        }
      })
    }
  }
}
