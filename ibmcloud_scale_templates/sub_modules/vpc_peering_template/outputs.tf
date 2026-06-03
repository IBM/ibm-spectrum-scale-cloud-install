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
  value       = try(ibm_tg_connection.peer_vpc[0].id, null)
  description = "ID of the Transit Gateway connection for the peer VPC."
}

output "transit_gateway_status" {
  value       = try(var.transit_gateway_name != null ? data.ibm_tg_gateway.existing[0].status : ibm_tg_gateway.new[0].status, null)
  description = "Status of the Transit Gateway."
}
