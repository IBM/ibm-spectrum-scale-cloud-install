/*
  This template assumes parent (storage) vpc and compute/client vpc's are already created.
*/

locals {
  vpc_pairs = flatten([
    for parent_vpc_name, parent_vpc_ref in var.storage_vpc_details : [
      for child_vpc_name, child_vpc_ref in var.compute_vpc_details :
      parent_vpc_name != child_vpc_name ? {
        vpc_A_name      = parent_vpc_name
        vpc_B_name      = child_vpc_name
        vpc_A_self_link = parent_vpc_ref
        vpc_B_self_link = child_vpc_ref
      } : null
    ]
  ])
  # Remove null
  valid_vpc_pairs = [for pair in local.vpc_pairs : pair if pair != null]
}

module "parent_vpc_peering" {
  for_each  = { for idx, pair in local.valid_vpc_pairs : format("pair-%d", idx) => pair }
  source    = "../../../resources/gcp/network/peering"
  pair_name = format("%s-%s", each.value.vpc_A_name, each.value.vpc_B_name)
  network_a = each.value.vpc_A_self_link
  network_b = each.value.vpc_B_self_link
}

# Bidirectional peering
module "child_vpc_peering" {
  for_each  = { for idx, pair in local.valid_vpc_pairs : format("pair-%d", idx) => pair }
  source    = "../../../resources/gcp/network/peering"
  pair_name = format("%s-%s", each.value.vpc_B_name, each.value.vpc_A_name)
  network_a = each.value.vpc_B_self_link
  network_b = each.value.vpc_A_self_link
}
