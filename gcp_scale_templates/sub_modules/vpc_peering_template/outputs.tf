output "vpc_details" {
  value = {
    for key, resource in module.create_vpc_networks :
    key => resource.vpc_ref
  }
  description = "Key-Value of vpc to its self-link."
}

output "vpc_pairs_state" {
  value = {
    for key, resource in module.vpc_peering :
    key => resource.peer_state
  }
  description = "Key-Value of vpc peer names to its state."
}
