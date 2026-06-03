/*
    VPC Peering Template Module for IBM Storage Scale Cloud Deployment

    This module creates Transit Gateway resources to enable VPC-to-VPC connectivity:

    1. Transit Gateway (optional - can use existing)
    2. Transit Gateway connection for the new VPC
    3. Transit Gateway connection for the peer VPC

    IBM Cloud uses Transit Gateway as the mechanism for VPC peering/connectivity.
    Transit Gateway can connect VPCs within the same region or across different regions
    when global routing is enabled.
*/

# Data source to get existing Transit Gateway if provided
data "ibm_tg_gateway" "existing" {
  count = var.transit_gateway_name != null ? 1 : 0
  name  = var.transit_gateway_name
}

# Create new Transit Gateway if not provided
resource "ibm_tg_gateway" "new" {
  count          = var.transit_gateway_name == null ? local.create_count : 0
  name           = var.transit_gateway_name != null ? var.transit_gateway_name : "${var.resource_prefix}-tgw"
  location       = var.vpc_region
  global         = var.transit_gateway_global_routing
  resource_group = var.resource_group_id
  tags           = var.tags
}

# Attach the new VPC to Transit Gateway
resource "ibm_tg_connection" "new_vpc" {
  count        = local.create_count
  gateway      = local.transit_gateway_id
  network_type = "vpc"
  name         = "${var.resource_prefix}-vpc-connection"
  network_id   = var.vpc_crn
}

# Attach the peer VPC to Transit Gateway
resource "ibm_tg_connection" "peer_vpc" {
  count        = var.peer_vpc_crn != null ? local.create_count : 0
  gateway      = local.transit_gateway_id
  network_type = "vpc"
  name         = "${var.resource_prefix}-peer-vpc-connection"
  network_id   = var.peer_vpc_crn
}
