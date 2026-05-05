/*
    DNS Template Module for IBM Storage Scale Cloud Deployment

    This module manages private DNS zones and permitted networks for IBM Storage Scale clusters.
    It supports three cluster types: Storage-only, Compute-only, and Combined-compute-storage.

    Prerequisites:
    - Existing VPC (vpc_ref)
    - Optional: Existing IBM Cloud DNS Service instance (dns_service_instance_id)
      If not provided, a new DNS service instance will be created.

    Resources created (conditionally based on cluster_type and create_dns_zone):
    0. DNS Service instance (if dns_service_instance_id is not provided)
    1. Storage DNS zone (for Storage-only and Combined-compute-storage)
    2. Storage DNS permitted network (associates VPC with storage zone)
    3. Compute DNS zone (for Compute-only and Combined-compute-storage)
    4. Compute DNS permitted network (associates VPC with compute zone)
    5. Protocol DNS zone (optional, if vpc_protocol_cluster_dns_domain is provided)
    6. Protocol DNS permitted network (associates VPC with protocol zone)

    Note: If DNS zones already exist, the module will reuse them instead of creating new ones.
    Note: Reverse DNS (PTR records) can be added directly to the forward DNS zones as per IBM Cloud DNS documentation.
*/

# Create DNS service instance if not provided
resource "ibm_resource_instance" "dns_service" {
  count             = var.dns_service_instance_id == null ? 1 : 0
  name              = "${var.resource_prefix}-dns-service"
  service           = "dns-svcs"
  plan              = "standard-dns"
  location          = "global"
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

# Use provided instance ID or the newly created one
locals {
  dns_instance_id = var.dns_service_instance_id != null ? var.dns_service_instance_id : one(ibm_resource_instance.dns_service[*].guid)
}

data "ibm_dns_zones" "all_zones" {
  instance_id = local.dns_instance_id
}

# Creates a new storage private DNS zone in IBMCloud
module "storage_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && local.is_storage_cluster
  dns_domain     = var.vpc_storage_cluster_dns_domain
  dns_service_id = local.dns_instance_id
  description    = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
  dns_label      = var.resource_prefix
}

# Conditionally fetch VPC data only when DNS resources will be created
data "ibm_is_vpc" "vpc" {
  count      = local.needs_vpc_data ? 1 : 0
  identifier = var.vpc_ref
}

# Creates a storage DNS permitted network
module "storage_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = (var.create_dns_zone || local.storage_dns_zone_exists) && local.is_storage_cluster ? 1 : 0
  instance_id     = local.dns_instance_id
  zone_id         = local.storage_dns_zone_exists ? local.storage_dns_zone_id : module.storage_dns_zone.dns_zone_id
  vpc_crn         = one(data.ibm_is_vpc.vpc[*].crn)
}

# Creates a new compute private DNS zone in IBMCloud
module "compute_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && local.is_compute_cluster
  dns_domain     = var.vpc_compute_cluster_dns_domain
  dns_service_id = local.dns_instance_id
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
}

# Creates a compute DNS permitted network
module "compute_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = (var.create_dns_zone || local.compute_dns_zone_exists) && local.is_compute_cluster ? 1 : 0
  instance_id     = local.dns_instance_id
  zone_id         = local.compute_dns_zone_exists ? local.compute_dns_zone_id : module.compute_dns_zone.dns_zone_id
  vpc_crn         = one(data.ibm_is_vpc.vpc[*].crn)
}

# Creates a new protocol private DNS zone in IBMCloud
module "protocol_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && local.is_protocol_cluster
  dns_domain     = var.vpc_protocol_cluster_dns_domain
  dns_service_id = local.dns_instance_id
  description    = "Private DNS Zone for Spectrum Scale protocol VPC DNS communication."
  dns_label      = var.resource_prefix
}

# Creates a protocol DNS permitted network
module "protocol_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = (var.create_dns_zone || local.protocol_dns_zone_exists) && local.is_protocol_cluster ? 1 : 0
  instance_id     = local.dns_instance_id
  zone_id         = local.protocol_dns_zone_exists ? local.protocol_dns_zone_id : module.protocol_dns_zone.dns_zone_id
  vpc_crn         = one(data.ibm_is_vpc.vpc[*].crn)
}
