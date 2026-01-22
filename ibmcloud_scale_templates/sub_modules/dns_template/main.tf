/*
    IBM Storage scale cloud deployment requires the below DNS resources.

    1. DNS service
    2. Storage DNS zone
    3. Storage DNS permitted network
    4. Compute DNS zone
    5. Compute DNS permitted network
    6. Reverse DNS zone
    7. Reverse DNS zone permitted network
*/

data "ibm_dns_zones" "all_zones" {
  instance_id = var.service_instance_ref
}

# Check if DNS Zones already exists
locals {
  storage_dns_zone_id = [
    for zone in data.ibm_dns_zones.all_zones.dns_zones : zone.zone_id
    if zone.name == var.vpc_storage_cluster_dns_zone
  ]

  compute_dns_zone_id = [
    for zone in data.ibm_dns_zones.all_zones.dns_zones : zone.zone_id
    if zone.name == var.vpc_compute_cluster_dns_zone
  ]

  reverse_dns_zone_id = [
    for zone in data.ibm_dns_zones.all_zones.dns_zones : zone.zone_id
    if zone.name == var.vpc_reverse_dns_zone
  ]

  storage_dns_zone_exists = length(local.storage_dns_zone_id) > 0

  compute_dns_zone_exists = length(local.compute_dns_zone_id) > 0

  reverse_dns_zone_exists = length(local.reverse_dns_zone_id) > 0
}

# Creates a new storage private DNS zone in IBMCloud
module "storage_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  dns_domain     = var.vpc_storage_cluster_dns_zone
  dns_service_id = var.service_instance_ref
  description    = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
  dns_label      = var.resource_prefix
}

data "ibm_is_vpc" "vpc" {
  name = var.vpc_ref
}

# Creates a storage DNS permitted network
module "storage_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = (var.create_dns_zone || local.storage_dns_zone_exists) && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? 1 : 0
  instance_id     = var.service_instance_ref
  zone_id         = local.storage_dns_zone_exists ? one(local.storage_dns_zone_id) : module.storage_dns_zone.dns_zone_id
  vpc_crn         = data.ibm_is_vpc.vpc.crn
}

# Creates a new compute private DNS zone in IBMCloud
module "compute_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  dns_domain     = var.vpc_compute_cluster_dns_zone
  dns_service_id = var.service_instance_ref
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
}

# Creates a compute DNS permitted network
module "compute_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = (var.create_dns_zone || local.compute_dns_zone_exists) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? 1 : 0
  instance_id     = var.service_instance_ref
  zone_id         = local.compute_dns_zone_exists ? one(local.compute_dns_zone_id) : module.compute_dns_zone.dns_zone_id
  vpc_crn         = data.ibm_is_vpc.vpc.crn
}

# Creates a new reverse private DNS zone in IBMCloud
module "reverse_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone ? true : false
  dns_domain     = var.vpc_reverse_dns_zone
  dns_service_id = var.service_instance_ref
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
}

module "reverse_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = (var.create_dns_zone || local.reverse_dns_zone_exists) && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? 1 : 0
  instance_id     = var.service_instance_ref
  zone_id         = local.reverse_dns_zone_exists ? one(local.reverse_dns_zone_id) : module.reverse_dns_zone.dns_zone_id
  vpc_crn         = data.ibm_is_vpc.vpc.crn
}
