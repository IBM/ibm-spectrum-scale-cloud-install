/*
    IBM Spectrum scale cloud deployment requires below DNS resources.

    1. Compute DNS zone
    2. Storage DNS zone
    3. Reverse DNS zone
*/

# Create a new compute private DNS Zone.
module "compute_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = var.create_dns_zone && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_name           = var.vpc_compute_cluster_dns_zone
  resource_group_name = var.resource_group_name
}

# Create a new storage private DNS Zone.
module "storage_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = var.create_dns_zone && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_name           = var.vpc_storage_cluster_dns_zone
  resource_group_name = var.resource_group_name
}

# Create a new private reverse DNS Zone.
module "reverse_dns_zone" {
  source              = "../../../resources/azure/network/private_dns_zone"
  turn_on             = var.create_dns_zone ? true : false
  zone_name           = var.vpc_reverse_dns_zone # Ex: "10.in-addr.arpa."
  resource_group_name = var.resource_group_name
}

# Associate compute zone with vpc (incase of reusing an existing dns zone)
module "associate_compute_dns" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage" ? true : false
  private_dns_zone_name = var.vpc_compute_cluster_dns_zone
  resource_group_name   = var.resource_group_name
  vnet_id               = var.vpc_ref
  vnet_zone_link_name   = format("%s-comp-link", basename(var.vpc_ref))
  depends_on            = [module.compute_dns_zone]
}

# Associate storage zone with vpc (incase of reusing an existing dns zone)
module "associate_storage_dns" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage" ? true : false
  private_dns_zone_name = var.vpc_storage_cluster_dns_zone
  resource_group_name   = var.resource_group_name
  vnet_id               = var.vpc_ref
  vnet_zone_link_name   = format("%s-strg-link", basename(var.vpc_ref))
  depends_on            = [module.storage_dns_zone]
}

# Associate reverse zone with vpc (incase of reusing an existing dns zone)
module "associate_reverse_dns" {
  source                = "../../../resources/azure/network/private_dns_zone_vpc_link"
  turn_on               = true
  private_dns_zone_name = var.vpc_reverse_dns_zone
  resource_group_name   = var.resource_group_name
  vnet_id               = var.vpc_ref
  vnet_zone_link_name   = format("%s-strg-link", basename(var.vpc_ref))
  depends_on            = [module.reverse_dns_zone]
}
