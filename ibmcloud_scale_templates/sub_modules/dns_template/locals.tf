locals {
  # Cluster type flags for reusability
  is_storage_cluster = contains(["Storage-only", "Combined-compute-storage"], var.cluster_type)
  is_compute_cluster = contains(["Compute-only", "Combined-compute-storage"], var.cluster_type)

  # Protocol cluster flag - enabled when protocol DNS domain is provided
  is_protocol_cluster = var.vpc_protocol_cluster_dns_domain != null

  # Optimized single-pass zone lookup using a map
  dns_zone_map = {
    for zone in data.ibm_dns_zones.all_zones.dns_zones : zone.name => zone.zone_id
  }

  # DNS zone IDs from existing zones (only lookup if domain is provided)
  storage_dns_zone_id  = var.vpc_storage_cluster_dns_domain != null ? lookup(local.dns_zone_map, var.vpc_storage_cluster_dns_domain, null) : null
  compute_dns_zone_id  = var.vpc_compute_cluster_dns_domain != null ? lookup(local.dns_zone_map, var.vpc_compute_cluster_dns_domain, null) : null
  protocol_dns_zone_id = local.is_protocol_cluster ? lookup(local.dns_zone_map, var.vpc_protocol_cluster_dns_domain, null) : null

  # DNS zone existence flags
  storage_dns_zone_exists  = local.storage_dns_zone_id != null
  compute_dns_zone_exists  = local.compute_dns_zone_id != null
  protocol_dns_zone_exists = local.protocol_dns_zone_id != null

  # Determine if VPC data source is needed
  needs_vpc_data = var.create_dns_zone || local.storage_dns_zone_exists || local.compute_dns_zone_exists || local.protocol_dns_zone_exists

  # Per-cluster-type DNS zone configuration, used to create one zone + permitted network per enabled cluster type
  dns_zone_configs = {
    storage = {
      enabled     = local.is_storage_cluster
      domain      = var.vpc_storage_cluster_dns_domain
      exists      = local.storage_dns_zone_exists
      existing_id = local.storage_dns_zone_id
      description = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
    }
    compute = {
      enabled     = local.is_compute_cluster
      domain      = var.vpc_compute_cluster_dns_domain
      exists      = local.compute_dns_zone_exists
      existing_id = local.compute_dns_zone_id
      description = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
    }
    protocol = {
      enabled     = local.is_protocol_cluster
      domain      = var.vpc_protocol_cluster_dns_domain
      exists      = local.protocol_dns_zone_exists
      existing_id = local.protocol_dns_zone_id
      description = "Private DNS Zone for Spectrum Scale protocol VPC DNS communication."
    }
  }

  enabled_dns_zone_configs = { for k, v in local.dns_zone_configs : k => v if v.enabled }
}
