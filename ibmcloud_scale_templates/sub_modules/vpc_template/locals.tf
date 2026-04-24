locals {
  # Calculate address prefix CIDRs dynamically
  newbits              = ceil(log(max(length(var.vpc_availability_zones), 1), 2))
  address_prefix_cidrs = [for idx in range(length(var.vpc_availability_zones)) : cidrsubnet(var.vpc_cidr_block, local.newbits, idx)]

  # Resource naming
  vpc_sg_name     = "${var.resource_prefix}-vpc-sg"
  vpc_rt_name     = "${var.resource_prefix}-vpc-rt"
  vpc_nw_acl_name = "${var.resource_prefix}-vpc-nwacl"
  address_name    = "${var.resource_prefix}-addr"
  public_gw_name  = "${var.resource_prefix}-gw"

  # Subnet naming
  public_subnet_name   = "${var.resource_prefix}-public"
  storage_subnet_name  = "${var.resource_prefix}-strg-pvt"
  compute_subnet_name  = "${var.resource_prefix}-comp-pvt"
  protocol_subnet_name = "${var.resource_prefix}-protocol-pvt"

  # Cluster type flags
  is_storage_cluster = contains(["Storage-only", "Combined-compute-storage"], var.cluster_type)
  is_compute_cluster = contains(["Compute-only", "Combined-compute-storage"], var.cluster_type)

  # Feature flags
  enable_public_subnets  = var.vpc_public_subnets_cidr_blocks != null
  enable_protocol_subnet = local.is_storage_cluster && var.vpc_protocol_private_subnets_cidr_blocks != null
}
