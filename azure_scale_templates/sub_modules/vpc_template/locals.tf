/*
  Local variables for the vnet module.
 */
locals {
  cluster_type = (
    (var.vnet_strg_priv_subnet_address_spaces != null && var.vnet_comp_priv_subnet_address_spaces == null) ? "storage" :
    (var.vnet_strg_priv_subnet_address_spaces == null && var.vnet_comp_priv_subnet_address_spaces != null) ? "compute" :
    (var.vnet_strg_priv_subnet_address_spaces != null && var.vnet_comp_priv_subnet_address_spaces != null) ? "combined" : "none"
  )
}
