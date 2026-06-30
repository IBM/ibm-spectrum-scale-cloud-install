locals {
  # Simplified count value for all resources
  create_count = var.enable_transit_gateway ? 1 : 0

  # Determine which Transit Gateway to use
  transit_gateway_id  = var.transit_gateway_name != null ? try(data.ibm_tg_gateway.existing[0].id, null) : try(ibm_tg_gateway.new[0].id, null)
  transit_gateway_crn = var.transit_gateway_name != null ? try(data.ibm_tg_gateway.existing[0].crn, null) : try(ibm_tg_gateway.new[0].crn, null)

  # Check if peer VPC is already attached to the existing Transit Gateway
  # This prevents duplicate connections when using an existing transit gateway
  existing_peer_vpc_connections = var.transit_gateway_name != null && var.peer_vpc_crn != null ? [
    for conn in try(data.ibm_tg_gateway.existing[0].connections, []) :
    conn if conn.network_id == var.peer_vpc_crn
  ] : []

  peer_vpc_already_attached = length(local.existing_peer_vpc_connections) > 0

  # Get the existing peer VPC connection ID if it exists
  existing_peer_vpc_connection_id = local.peer_vpc_already_attached ? local.existing_peer_vpc_connections[0].id : null
}
