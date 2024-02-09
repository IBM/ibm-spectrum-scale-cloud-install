/*
    Notes:

*/

locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets == null && var.vpc_compute_cluster_private_subnets != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets != null) ? "combined" : null
  )
  compute_or_combined  = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.total_compute_cluster_instances != null) ? true : false
  storage_or_combined  = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.total_storage_cluster_instances != null) ? true : false
  storage_and_protocol = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.total_protocol_instances != null) ? true : false
  storage_and_gateway  = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.total_gateway_instances != null) ? true : false

  create_placement_group = (length(var.vpc_availability_zones) == 1 && var.enable_placement_group == true) ? true : false # Placement group does not spread across multiple availability zones
  ebs_device_names = ["/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj",
  "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt"]
  instance_storage_device_names = ["/dev/nvme0n1", "/dev/nvme1n1", "/dev/nvme2n1", "/dev/nvme3n1", "/dev/nvme4n1", "/dev/nvme5n1", "/dev/nvme6n1", "/dev/nvme7n1"]
  gpfs_base_rpm_path            = var.spectrumscale_rpms_path != null ? fileset(var.spectrumscale_rpms_path, "gpfs.base-*") : null
  scale_version                 = local.gpfs_base_rpm_path != null ? regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0] : null
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
    Generate a list of protocol vm name(s).
    Ex: vm_list = ["vm-protocol-1", "vm-protocol-2",]
*/
resource "null_resource" "generate_protocol_vm_name" {
  count = local.storage_and_protocol ? var.total_protocol_instances : 0
  triggers = {
    vm_name = format("%s-protocol-%s", var.resource_prefix, count.index + 1)
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
    Generate a map using compute vm name key and values of subnet.
    Ex:
        compute_vm_zone_map = {
            "vm-compute-1" = {
                "subnet" = "test-private-subnet-1"
            }
            "vm-compute-2" = {
                "subnet" = "test-private-subnet-2"
            }
        }
*/
locals {
  compute_vm_subnet_map = {
    for idx, vm_name in resource.null_resource.generate_compute_vm_name[*].triggers.vm_name :
    vm_name => {
      subnet = element(var.vpc_compute_cluster_private_subnets, idx)
    }
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
      subnet = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx)
    }
  }
}

/*
    Generate a map using protocol vm name key and values of subnet.
    Ex:
        protocol_vm_subnet_map = {
            "vm-protocol-1" = {
                "subnet" = "test-private-subnet-1"
            }
            "vm-protocol-2" = {
                "subnet" = "test-private-subnet-2"
            }
        }
*/
locals {
  protocol_vm_subnet_map = {
    for idx, vm_name in resource.null_resource.generate_protocol_vm_name[*].triggers.vm_name :
    vm_name => {
      # Consider only first 2 elements
      subnet = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx)
    }
  }
}

/*
    Notes:
    1. One additional ENI will be provisioned per protocol node
    2. Each ENI will only have 1 secondary ip
*/
locals {
  protocol_vm_ces_map = {
    for idx, vm_name in resource.null_resource.generate_protocol_vm_name[*].triggers.vm_name :
    vm_name => {
      subnet      = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx) # Consider only first 2 elements
      private_ips = var.ces_private_ips == null ? null : element(var.ces_private_ips, idx)
      description = format("%s-ces", vm_name)
    }
  }
}

/*
    Generate a map using storage vm name key and values of disks list, subnet.
    Ex:
        storage_vm_zone_map = {
          subnet = "test-subnet-1"
          zone   = "us-east-1a"
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
                    type        = "gp2"
                }
                "fs1-system-1" = {
                    device_name = "/dev/xvdi"
                    encrypted   = false
                    iops        = null
                    kms_key     = null
                    size        = "500"
                    termination = true
                    throughput  = null
                    type        = "gp2"
                }
                "fs1-system-2" = {
                  device_name = "/dev/xvdi"
                  encrypted   = false
                  iops        = null
                  kms_key     = null
                  size        = "500"
                  termination = true
                  throughput  = null
                  type        = "gp2"
                }
                "fs2-system-1" = {
                  device_name = "/dev/xvdi"
                  encrypted   = false
                  iops        = null
                  kms_key     = null
                  size        = "500"
                  termination = true
                  throughput  = null
                  type        = "gp2"
                }
            }
        }
*/
locals {
  inflate_disks_per_fs_pool = flatten([
    for fs_config in var.filesystem_parameters != null ? var.filesystem_parameters : [] : [
      for disk_details in fs_config.disk_config : {
        for i in range(local.nvme_block_device_count > 0 ? local.nvme_block_device_count : disk_details.block_devices_per_storage_instance) :
        "${fs_config.name}-${disk_details.filesystem_pool}-${i + 1}" => {
          "fs_name"     = fs_config.name
          "config_file" = fs_config.filesystem_config_file
          "encrypted"   = fs_config.filesystem_encrypted
          "kms_key"     = fs_config.filesystem_kms_key_ref
          "termination" = fs_config.device_delete_on_termination
          "pool"        = disk_details.filesystem_pool
          "size"        = disk_details.block_device_volume_size
          "type"        = disk_details.block_device_volume_type
          "iops"        = disk_details.block_device_iops
          "throughput"  = disk_details.block_device_throughput
        }
      }
    ]
  ])
  flatten_disks_per_vm = flatten([
    for pool in local.inflate_disks_per_fs_pool :
    [for disk, properties in pool :
      {
        name        = disk
        fs_name     = properties["fs_name"]
        pool        = properties["pool"]
        config      = properties["config_file"]
        encrypted   = properties["encrypted"]
        kms_key     = properties["kms_key"]
        termination = properties["termination"]
        size        = properties["size"]
        type        = properties["type"]
        iops        = properties["iops"]
        throughput  = properties["throughput"]
      }
    ]
  ])
  flatten_tie_disk = flatten([
    for fs_config in var.filesystem_parameters != null ? var.filesystem_parameters : [] : [
      [for disk_config in fs_config.disk_config :
        {
          name        = format("%s-tie", fs_config.name)
          fs_name     = fs_config.name
          pool        = "system"
          config      = fs_config.filesystem_config_file
          encrypted   = fs_config.filesystem_encrypted
          kms_key     = fs_config.filesystem_kms_key_ref
          termination = fs_config.device_delete_on_termination
          size        = "5"
          type        = "gp2"
          throughput  = null
          iops        = null
        }
      ]
    ]
  ])

  storage_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_storage_vm_name[*].triggers.vm_name :
    vm_name => {
      # Consider only first 2 elements in multi-az
      zone   = length(var.vpc_availability_zones) > 1 ? element(slice(var.vpc_availability_zones, 0, 2), idx) : element(var.vpc_availability_zones, idx)
      subnet = length(var.vpc_storage_cluster_private_subnets) > 1 ? element(slice(var.vpc_storage_cluster_private_subnets, 0, 2), idx) : element(var.vpc_storage_cluster_private_subnets, idx)
      # In case of nitro instances, the disk list to provision is empty
      disks = local.nvme_block_device_count > 0 ? {} : tomap({
        for idx, disk in tolist(local.flatten_disks_per_vm) :
        disk["name"] => {
          size        = disk["size"]
          type        = disk["type"]
          termination = disk["termination"]
          iops        = disk["iops"]
          throughput  = disk["throughput"]
          encrypted   = disk["encrypted"]
          kms_key     = disk["kms_key"]
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.ebs_device_names, idx)
        }
      })
    }
  }

  filesystem_details = local.storage_or_combined ? { for fs_config in var.filesystem_parameters : fs_config.name => fs_config.filesystem_config_file } : {}
  storage_instance_ips_with_disk_mapping = {
    for idx, vm_ipaddr in local.storage_cluster_private_ips :
    vm_ipaddr => {
      zone = length(var.vpc_availability_zones) > 1 ? element(slice(var.vpc_availability_zones, 0, 2), idx) : element(var.vpc_availability_zones, idx)
      disks = local.nvme_block_device_count > 0 ? tomap({
        for jdx, disk in tolist(local.flatten_disks_per_vm) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.instance_storage_device_names, jdx)
        }
        }) : local.is_nitro_instance ? tomap({
        for jdx, disk in tolist(local.flatten_disks_per_vm) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.instance_storage_device_names, jdx + 1)
        }
        }) : tomap({
        for jdx, disk in tolist(local.flatten_disks_per_vm) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.ebs_device_names, jdx)
        }
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
                        type        = "gp2"
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
                        type        = "gp2"
                    }
                    "subnet" = "test-private-subnet-1"
                    "zone" = "us-east-1c"
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
        disk["name"] => {
          size        = disk["size"]
          type        = disk["type"]
          termination = disk["termination"]
          iops        = disk["iops"]
          throughput  = disk["throughput"]
          encrypted   = disk["encrypted"]
          kms_key     = disk["kms_key"]
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.ebs_device_names, idx)
        }
      })
    }
  }
  storage_instance_desc_ip_with_disk_mapping = {
    for idx, vm_ipaddr in local.storage_cluster_desc_private_ips :
    vm_ipaddr => {
      zone = var.vpc_availability_zones[2]
      disks = tomap({
        for jdx, disk in tolist(local.flatten_tie_disk) :
        disk["name"] => {
          fs_name     = disk["fs_name"]
          pool        = disk["pool"]
          device_name = element(local.ebs_device_names, jdx)
        }
      })
    }
  }
}
