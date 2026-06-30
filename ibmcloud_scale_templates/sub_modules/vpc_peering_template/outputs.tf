output "transit_gateway_id" {
  value       = try(local.transit_gateway_id, null)
  description = "ID of the Transit Gateway (either existing or newly created)."
}

output "transit_gateway_crn" {
  value       = try(local.transit_gateway_crn, null)
  description = "CRN of the Transit Gateway (either existing or newly created)."
}

output "transit_gateway_name" {
  value       = try(var.transit_gateway_name != null ? data.ibm_tg_gateway.existing[0].name : ibm_tg_gateway.new[0].name, null)
  description = "Name of the Transit Gateway."
}

output "new_vpc_connection_id" {
  value       = try(ibm_tg_connection.new_vpc[0].id, null)
  description = "ID of the Transit Gateway connection for the new VPC."
}

output "peer_vpc_connection_id" {
  value       = local.peer_vpc_already_attached ? local.existing_peer_vpc_connection_id : try(ibm_tg_connection.peer_vpc[0].id, null)
  description = "ID of the Transit Gateway connection for the peer VPC (either existing or newly created)."
}

output "peer_vpc_already_attached" {
  value       = local.peer_vpc_already_attached
  description = "Boolean flag indicating if the peer VPC was already attached to the Transit Gateway."
}

output "peer_vpc_connection_status" {
  value       = local.peer_vpc_already_attached ? "existing" : (var.peer_vpc_crn != null ? "created" : "not_configured")
  description = "Status of peer VPC connection: 'existing' (already attached), 'created' (newly attached), or 'not_configured' (no peer VPC specified)."
}

output "transit_gateway_status" {
  value       = try(var.transit_gateway_name != null ? data.ibm_tg_gateway.existing[0].status : ibm_tg_gateway.new[0].status, null)
  description = "Status of the Transit Gateway."
}
