/*
    IBM Storage Scale cloud deployment requires below resources.

    1.  Forward zone
    2.  Reverse zone
*/

# Create a new compute private DNS Zone in cloud DNS.
module "compute_dns_zone" {
  source      = "../../../resources/gcp/network/cloud_dns"
  turn_on     = var.create_dns_zone && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_name   = var.vpc_compute_cluster_dns_zone
  dns_name    = format("%s.", var.vpc_compute_cluster_forward_dns_zone) # Trailing dot is required.
  vpc_network = var.vpc_ref
  description = var.vpc_compute_cluster_dns_zone_description
}

# Create a new storage private DNS Zone in cloud DNS.
module "storage_dns_zone" {
  source      = "../../../resources/gcp/network/cloud_dns"
  turn_on     = var.create_dns_zone && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_name   = var.vpc_storage_cluster_dns_zone
  dns_name    = format("%s.", var.vpc_storage_cluster_forward_dns_zone) # Trailing dot is required.
  vpc_network = var.vpc_ref
  description = var.vpc_storage_cluster_dns_zone_description
}

# Create a new reverse private DNS Zone in cloud DNS.
module "reverse_dns_zone" {
  source      = "../../../resources/gcp/network/cloud_dns"
  turn_on     = var.create_dns_zone ? true : false
  zone_name   = var.vpc_reverse_dns_zone
  dns_name    = format("%s.", var.vpc_reverse_dns_name) # Trailing dot is required (Ex: "10.in-addr.arpa.")
  vpc_network = var.vpc_ref
  description = var.vpc_reverse_dns_zone_description
}
