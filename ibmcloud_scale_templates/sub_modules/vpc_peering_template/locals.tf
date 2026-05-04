locals {
  # Simplified count value for all resources
  create_count = var.enable_transit_gateway ? 1 : 0

  # Determine which Transit Gateway to use
  transit_gateway_id  = var.transit_gateway_id != null ? try(data.ibm_tg_gateway.existing[0].id, null) : try(ibm_tg_gateway.new[0].id, null)
  transit_gateway_crn = var.transit_gateway_id != null ? try(data.ibm_tg_gateway.existing[0].crn, null) : try(ibm_tg_gateway.new[0].crn, null)
}
