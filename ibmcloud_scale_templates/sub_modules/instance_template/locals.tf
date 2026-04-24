/*
    Notes:
    1. Data disks/Volumes alone as a module (for_each) alone needs keys (instance id) to be statically available, which cannot be determined before apply-time.
*/

locals {
  # Cluster type helpers - simplified boolean logic
  is_compute_cluster = contains(["Compute-only", "Combined-compute-storage"], var.cluster_type)
  is_storage_cluster = contains(["Storage-only", "Combined-compute-storage"], var.cluster_type)

  compute_or_combined    = local.is_compute_cluster && var.total_compute_cluster_instances > 0
  storage_or_combined    = local.is_storage_cluster && var.total_storage_cluster_instances > 0
  storage_and_protocol   = local.is_storage_cluster && var.total_protocol_instances > 0
  storage_and_gateway    = local.is_storage_cluster && var.total_gateway_instances > 0
  create_placement_group = length(var.vpc_availability_zones) == 1 && var.enable_placement_group

  # Internode scale firewall ports
  tcp_port_scale_cluster = ["22", "1191", "60000", "61000", "47080", "4444", "4739", "9080", "9081", "80", "443"]
  udp_port_scale_cluster = ["47443", "4739"]

  # Device names
  block_device_names            = ["/dev/vdd", "/dev/vde", "/dev/vdf", "/dev/vdg", "/dev/vdh", "/dev/vdi"]
  instance_storage_device_names = ["/dev/vdb", "/dev/vdc", "/dev/vdd", "/dev/vde", "/dev/vdf", "/dev/vdg"]

  scale_version      = "6.0.0.1"
  filesystem_details = local.storage_or_combined ? { for fs_config in var.filesystem_parameters : fs_config.name => fs_config.filesystem_config_file } : {}

  # Internode protocol ports
  protocol_traffic_ports                   = [4379]
  protocol_traffic_to_ports                = [4379]
  protocol_traffic_protocol                = ["TCP"]
  protocol_nodes_security_rule_description = ["Allow CTDB traffic within protocol instances"]

  # Common subnet/zone selection helpers
  is_multi_az               = length(var.vpc_availability_zones) > 1
  is_multi_subnet           = length(var.vpc_storage_cluster_private_subnets) > 1
  first_two_zones           = local.is_multi_az ? slice(var.vpc_availability_zones, 0, 2) : var.vpc_availability_zones
  first_two_storage_subnets = local.is_multi_subnet ? slice(var.vpc_storage_cluster_private_subnets, 0, 2) : var.vpc_storage_cluster_private_subnets
  filesystem_params_safe    = coalesce(var.filesystem_parameters, [])
  should_attach_disks_to_vm = length(var.marked_vm_names_to_attach_disks) == 0
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
    Generate a map using protocol vm name key and values of subnet.
    Ex:
        protocol_vm_subnet_map = {
            "vm-protocol-1" = {
                "base_subnet" = "test-private-subnet-1"
                "ces_subnet" = "ces-private-subnet-1"
            }
            "vm-protocol-2" = {
                "base_subnet" = "test-private-subnet-2"
                "ces_subnet" = "ces-private-subnet-2"
            }
        }
*/
locals {
  protocol_vm_subnet_map = {
    for idx, vm_name in resource.null_resource.generate_protocol_vm_name[*].triggers.vm_name :
    vm_name => {
      subnet         = element(local.first_two_storage_subnets, idx)
      ces_ip_address = element(var.ces_ip_address, idx)
      zone           = element(local.first_two_zones, idx)
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
  # Helper for disk count calculation
  disk_count_per_instance = local.local_block_device_count > 0 ? local.local_block_device_count : null

  inflate_disks_per_fs_pool = flatten([
    for fs_config in local.filesystem_params_safe : [
      for disk_details in fs_config.disk_config : {
        for i in range(coalesce(local.disk_count_per_instance, disk_details.block_devices_per_storage_instance)) :
        "${fs_config.name}-${disk_details.filesystem_pool}-${i + 1}" => {
          fs_name     = fs_config.name
          config_file = fs_config.filesystem_config_file
          encrypted   = fs_config.filesystem_encrypted
          kms_key     = fs_config.filesystem_kms_key_ref
          termination = fs_config.device_delete_on_termination
          pool        = disk_details.filesystem_pool
          size        = disk_details.block_device_volume_size
          type        = disk_details.block_device_volume_type
          iops        = disk_details.block_device_iops
          throughput  = disk_details.block_device_throughput
        }
      }
    ]
  ])

  flatten_disks_per_vm = flatten([
    for pool in local.inflate_disks_per_fs_pool : [
      for disk, properties in pool : {
        name        = disk
        fs_name     = properties.fs_name
        pool        = properties.pool
        config      = properties.config_file
        encrypted   = properties.encrypted
        kms_key     = properties.kms_key
        termination = properties.termination
        size        = properties.size
        type        = properties.type
        iops        = properties.iops
        throughput  = properties.throughput
      }
    ]
  ])

  flatten_tie_disk = flatten([
    for fs_config in local.filesystem_params_safe : [
      for disk_config in fs_config.disk_config : {
        name        = "${fs_config.name}-tie"
        fs_name     = fs_config.name
        pool        = "system"
        config      = fs_config.filesystem_config_file
        encrypted   = fs_config.filesystem_encrypted
        kms_key     = fs_config.filesystem_kms_key_ref
        termination = fs_config.device_delete_on_termination
        size        = "10"
        type        = "general-purpose"
        throughput  = null
        iops        = null
      }
    ]
  ])

  storage_vm_zone_map = {
    for idx, vm_name in resource.null_resource.generate_storage_vm_name[*].triggers.vm_name :
    vm_name => {
      zone   = element(local.first_two_zones, idx)
      subnet = element(local.first_two_storage_subnets, idx)
      # In case of nitro instances, the disk list to provision is empty
      disks = local.local_block_device_count > 0 ? {} : {
        for disk_idx, disk in local.flatten_disks_per_vm :
        disk.name => {
          size        = disk.size
          type        = disk.type
          termination = disk.termination
          iops        = disk.iops
          throughput  = disk.throughput
          encrypted   = disk.encrypted
          kms_key     = disk.kms_key
          fs_name     = disk.fs_name
          pool        = disk.pool
          device_name = element(local.block_device_names, disk_idx)
        } if local.should_attach_disks_to_vm || contains(var.marked_vm_names_to_attach_disks, vm_name)
      }
    }
  }

  storage_instance_ips_with_disk_mapping = {
    for idx, vm_name in resource.null_resource.generate_storage_vm_name[*].triggers.vm_name :
    "${vm_name}.${var.vpc_storage_cluster_dns_domain}" => {
      zone = element(local.first_two_zones, idx)
      disks = {
        for disk_idx, disk in local.flatten_disks_per_vm :
        disk.name => {
          fs_name = disk.fs_name
          pool    = disk.pool
          device_name = element(
            local.local_block_device_count > 0 ? local.instance_storage_device_names : local.block_device_names,
            disk_idx
          )
          } if local.should_attach_disks_to_vm || anytrue([
            for marked_vm in var.marked_vm_names_to_attach_disks :
            can(regex(marked_vm, "${vm_name}.${var.vpc_storage_cluster_dns_domain}"))
        ])
      }
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
      zone   = var.vpc_availability_zones[2]
      subnet = var.vpc_storage_cluster_private_subnets[2]
      disks = {
        for disk_idx, disk in local.flatten_tie_disk :
        disk.name => {
          size        = disk.size
          type        = disk.type
          termination = disk.termination
          iops        = disk.iops
          throughput  = disk.throughput
          encrypted   = disk.encrypted
          kms_key     = disk.kms_key
          fs_name     = disk.fs_name
          pool        = disk.pool
          device_name = element(local.block_device_names, disk_idx)
        }
      }
    }
  }

  storage_instance_desc_ip_with_disk_mapping = {
    for idx, vm_dns in [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details["dns"]] :
    vm_dns => {
      zone = var.vpc_availability_zones[2]
      disks = {
        for disk_idx, disk in local.flatten_tie_disk :
        disk.name => {
          fs_name     = disk.fs_name
          pool        = disk.pool
          device_name = element(local.block_device_names, disk_idx)
        }
      }
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
      subnet = element(local.first_two_storage_subnets, idx)
    }
  }
}
