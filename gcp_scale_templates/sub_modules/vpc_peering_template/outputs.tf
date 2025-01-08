output "parent_vpc_pairs_state" {
  value = {
    for key, resource in module.parent_vpc_peering :
    resource.peer_details.name => resource.peer_details
  }
  description = "vpc peer names to its state."
}

output "child_vpc_pairs_state" {
  value = {
    for key, resource in module.child_vpc_peering :
    resource.peer_details.name => resource.peer_details
  }
  description = "vpc peer names to its state."
}
