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

# Data source to get peer VPC details including default security group
# Extract VPC ID from CRN (format: crn:v1:bluemix:public:is:region:account::vpc:VPC_ID)
data "ibm_is_vpc" "peer" {
  count = var.peer_vpc_crn != null && var.vpc_cidr_block != null ? 1 : 0
  # Extract VPC ID from CRN by taking the last segment after the last colon
  identifier = element(split(":", var.peer_vpc_crn), length(split(":", var.peer_vpc_crn)) - 1)
}

# Create security rule in peer VPC to allow inbound traffic from new VPC on port 57096
resource "ibm_is_security_group_rule" "peer_vpc_allow_inbound" {
  count     = var.peer_vpc_crn != null && var.vpc_cidr_block != null ? 1 : 0
  group     = data.ibm_is_vpc.peer[0].default_security_group
  direction = "inbound"
  remote    = var.vpc_cidr_block
  protocol  = "tcp"
  port_min  = 57096
  port_max  = 57096
}
