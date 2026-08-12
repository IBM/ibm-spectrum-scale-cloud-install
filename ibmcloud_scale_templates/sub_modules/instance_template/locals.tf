locals {
  # Cluster type helpers
  compute_or_combined    = contains(["Compute-only", "Combined-compute-storage"], var.cluster_type) && var.total_compute_cluster_instances > 0
  storage_or_combined    = contains(["Storage-only", "Combined-compute-storage"], var.cluster_type) && var.total_storage_cluster_instances > 0
  storage_and_protocol   = contains(["Storage-only", "Combined-compute-storage"], var.cluster_type) && var.total_protocol_instances > 0
  storage_and_gateway    = contains(["Storage-only", "Combined-compute-storage"], var.cluster_type) && var.total_gateway_instances > 0
  create_placement_group = length(var.vpc_availability_zones) == 1 && var.enable_placement_group

  # Internode scale firewall ports
  tcp_port_scale_cluster = ["22", "1191", "47080", "4444", "4739", "9080", "9081", "80", "443", "50052"]
  udp_port_scale_cluster = ["47443", "4739"]

  # GPFS ephemeral RPC port range used for internode daemon traffic
  gpfs_ephemeral_port_range = {
    port_min = 60000
    port_max = 61000
  }

  # Internode protocol ports (CTDB traffic)
  protocol_traffic_ports = [4379]

  # Subnet/zone selection helpers - get first two or all if less than two
  first_two_zones           = length(var.vpc_availability_zones) > 1 ? slice(var.vpc_availability_zones, 0, 2) : var.vpc_availability_zones
  first_two_storage_subnets = length(var.vpc_storage_cluster_private_subnets) > 1 ? slice(var.vpc_storage_cluster_private_subnets, 0, 2) : var.vpc_storage_cluster_private_subnets

  # Compute vm name list
  compute_vm_names = local.compute_or_combined ? [
    for i in range(var.total_compute_cluster_instances) : format("%s-compute-%s", var.resource_prefix, i + 1)
  ] : []

  # Storage vm name list
  storage_vm_names = local.storage_or_combined ? [
    for i in range(var.total_storage_cluster_instances) : format("%s-storage-%s", var.resource_prefix, i + 1)
  ] : []

  # Protocol vm name list
  protocol_vm_names = local.storage_and_protocol ? [
    for i in range(var.total_protocol_instances) : format("%s-protocol-%s", var.resource_prefix, i + 1)
  ] : []

  # Gateway vm name list
  gateway_vm_names = local.storage_and_gateway ? [
    for i in range(var.total_gateway_instances) : format("%s-gateway-%s", var.resource_prefix, i + 1)
  ] : []

  # Storage tie-breaker vm name
  storage_tie_vm_name = local.storage_or_combined && length(var.vpc_availability_zones) > 1 ? format("%s-storage-tie", var.resource_prefix) : ""
}


locals {
  # Compute VM subnet mapping
  compute_vm_subnet_map = {
    for idx, vm_name in local.compute_vm_names :
    vm_name => {
      subnet = element(var.vpc_compute_cluster_private_subnets, idx)
    }
  }

  # Protocol VM subnet mapping - always use storage subnets for primary NIC
  protocol_vm_subnet_map = {
    for idx, vm_name in local.protocol_vm_names :
    vm_name => {
      subnet           = element(local.first_two_storage_subnets, idx)
      ces_ip_addresses = element(var.ces_ip_addresses, idx)
      zone             = element(local.first_two_zones, idx)
    }
  }

  # Storage volume distribution calculation
  has_storage_volumes = var.total_storage_volumes != null && var.total_storage_volumes > 0 && var.total_storage_cluster_instances > 0
  disks_per_vm        = local.has_storage_volumes ? floor(var.total_storage_volumes / var.total_storage_cluster_instances) : 0
  extra_disks         = local.has_storage_volumes ? var.total_storage_volumes % var.total_storage_cluster_instances : 0

  # Storage VM zone mapping
  storage_vm_zone_map = {
    for idx, vm_name in local.storage_vm_names :
    vm_name => {
      zone   = element(local.first_two_zones, idx)
      subnet = element(local.first_two_storage_subnets, idx)
      disks = local.has_storage_volumes ? {
        for disk_idx in range(local.disks_per_vm + (idx < local.extra_disks ? 1 : 0)) :
        "disk-${disk_idx + 1}" => {
          size = tostring(var.storage_volume_size)
          type = var.storage_volume_profile
          iops = var.storage_volume_iops != null ? tostring(var.storage_volume_iops) : ""
        }
      } : {}
    }
  }

  # Storage instance IPs with disk mapping (using FQDN)
  storage_instance_ips_with_disk_mapping = {
    for idx, vm_name in local.storage_vm_names :
    "${vm_name}.${var.vpc_storage_cluster_dns_domain}" => {
      zone = element(local.first_two_zones, idx)
      disks = local.has_storage_volumes ? {
        for disk_idx in range(local.disks_per_vm + (idx < local.extra_disks ? 1 : 0)) :
        "disk-${disk_idx + 1}" => {
          size = tostring(var.storage_volume_size)
          type = var.storage_volume_profile
          iops = var.storage_volume_iops != null ? tostring(var.storage_volume_iops) : ""
        }
      } : {}
    }
  }

  # Storage tie-breaker VM zone mapping
  storage_tie_vm_zone_map = local.storage_tie_vm_name != "" ? {
    (local.storage_tie_vm_name) = {
      zone   = var.vpc_availability_zones[2]
      subnet = var.vpc_storage_cluster_private_subnets[2]
      disks  = {}
    }
  } : {}

  storage_instance_desc_ip_with_disk_mapping = {
    for idx, vm_dns in [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details["dns"]] :
    vm_dns => {
      zone  = var.vpc_availability_zones[2]
      disks = {}
    }
  }

  # Gateway VM subnet mapping
  gateway_vm_subnet_map = {
    for idx, vm_name in local.gateway_vm_names :
    vm_name => {
      subnet = element(local.first_two_storage_subnets, idx)
    }
  }
}

locals {
  # Effective storage volume bandwidth passed to each NSD VSI.
  # Priority: explicit user input (storage_vol_bandwidth) > formula > null (50/50 profile default in vsi_multiple_vol.tf).
  # Formula: (vols_per_vsi * storage_volume_mbps) + 393
  effective_storage_vol_bandwidth = (
    var.storage_vol_bandwidth != null
    ? var.storage_vol_bandwidth
    : (
      var.storage_volume_mbps != null && local.disks_per_vm > 0
      ? (local.disks_per_vm * var.storage_volume_mbps) + 393
      : null
    )
  )

  # Protocol nodes: user input or default 800 Mbps.
  effective_protocol_vol_bandwidth = var.protocol_vol_bandwidth
}
