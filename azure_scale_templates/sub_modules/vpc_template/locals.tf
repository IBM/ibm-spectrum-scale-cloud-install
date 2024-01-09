/*
  Local variables for the vpc module.
 */
locals {
  cluster_type = (
    (var.vpc_strg_priv_subnet_address_spaces != null && var.vpc_comp_priv_subnet_address_spaces == null) ? "storage" :
    (var.vpc_strg_priv_subnet_address_spaces == null && var.vpc_comp_priv_subnet_address_spaces != null) ? "compute" :
    (var.vpc_strg_priv_subnet_address_spaces != null && var.vpc_comp_priv_subnet_address_spaces != null) ? "combined" : "none"
  )
}
