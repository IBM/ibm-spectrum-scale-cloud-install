/*
  Local variables for the vpc module.
 */
locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets_cidr_blocks != null && var.vpc_compute_cluster_private_subnets_cidr_blocks == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets_cidr_blocks == null && var.vpc_compute_cluster_private_subnets_cidr_blocks != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets_cidr_blocks != null && var.vpc_compute_cluster_private_subnets_cidr_blocks != null) ? "combined" : "none"
  )
}
