/*
This template provides;

1. Integrated Mode: The new vpc(s) will be created and paired with each other.
2. Custom Mode:
    a. The created vpc(s) will be paired with custom vpc(s).
    b. The custom vpc(s) will be paired among them self.
*/

module "create_vpc_networks" {
  source                                          = "../vpc_template"
  for_each                                        = var.vpc_template_inputs
  cluster_type                                    = each.value.cluster_type
  project_id                                      = each.value.project_id
  credential_json_path                            = each.value.credential_json_path
  resource_prefix                                 = each.value.resource_prefix
  vpc_cidr_block                                  = each.value.vpc_cidr_block
  vpc_compute_cluster_private_subnets_cidr_blocks = each.value.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_description                                 = each.value.vpc_description
  vpc_public_subnets_cidr_blocks                  = each.value.vpc_public_subnets_cidr_blocks
  vpc_region                                      = each.value.vpc_region
  vpc_routing_mode                                = each.value.vpc_routing_mode
  vpc_storage_cluster_private_subnets_cidr_blocks = each.value.vpc_storage_cluster_private_subnets_cidr_blocks
}

locals {
  custom_vpc_object = { for k, v in var.custom_vpc : k => v }

  vpc_pairs = flatten([
    for key_A, vpc_A_resource in module.create_vpc_networks : [
      for key_B, vpc_B_resource in length(local.custom_vpc_object) == 0 ? module.create_vpc_networks : local.custom_vpc_object :
      key_A != key_B ? {
        vpc_A_name      = basename(vpc_A_resource.vpc_ref)
        vpc_B_name      = basename(vpc_B_resource.vpc_ref)
        vpc_A_self_link = vpc_A_resource.vpc_ref
        vpc_B_self_link = vpc_B_resource.vpc_ref
      } : null
    ]
  ])
  # Remove null
  valid_vpc_pairs = [for pair in local.vpc_pairs : pair if pair != null]
}

module "vpc_peering" {
  for_each  = { for idx, pair in local.valid_vpc_pairs : format("pair-%d", idx) => pair }
  source    = "../../../resources/gcp/network/peering"
  pair_name = format("%s-%s", each.value.vpc_A_name, each.value.vpc_B_name)
  network_a = each.value.vpc_A_self_link
  network_b = each.value.vpc_B_self_link
}
