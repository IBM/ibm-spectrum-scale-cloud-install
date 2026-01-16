/*
    IBM Spectrum scale cloud deployment requires below DNS resources.

    1. Compute DNS zone
    2. Storage DNS zone
    3. Reverse DNS zone
*/

# Create a new compute private DNS Zone in route53.
# Note: In the case of new private DNS create, it needs to be associated with atleast
# 1 vpc during its creation.
module "compute_dns_zone" {
  source       = "../../../resources/aws/network/route53_zone"
  turn_on      = var.create_dns_zone && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_name    = var.vpc_compute_cluster_dns_zone
  description  = var.vpc_compute_cluster_dns_zone_description
  vpc_id       = var.vpc_ref
  vpc_region   = var.vpc_region
  vpc_dns_tags = var.vpc_dns_tags
}

# Create a new storage storage private DNS Zone in route53.
# Note: In the case of new private DNS create, it needs to be associated with atleast
# 1 vpc during its creation.
module "storage_dns_zone" {
  source       = "../../../resources/aws/network/route53_zone"
  turn_on      = var.create_dns_zone && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_name    = var.vpc_storage_cluster_dns_zone
  description  = var.vpc_storage_cluster_dns_zone_description
  vpc_id       = var.vpc_ref
  vpc_region   = var.vpc_region
  vpc_dns_tags = var.vpc_dns_tags
}

# Create a new private reverse DNS Zone in route53.
module "reverse_dns_zone" {
  source       = "../../../resources/aws/network/route53_zone"
  turn_on      = var.create_dns_zone ? true : false
  zone_name    = var.vpc_reverse_dns_zone # Ex: "10.in-addr.arpa."
  description  = var.vpc_reverse_dns_zone_description
  vpc_id       = var.vpc_ref
  vpc_region   = var.vpc_region
  vpc_dns_tags = var.vpc_dns_tags
}

# Associate compute zone with vpc (incase of reusing an existing dns zone)
module "associate_compute_dns" {
  source  = "../../../resources/aws/network/route53_vpc_association"
  turn_on = var.create_dns_zone == false && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_id = var.vpc_compute_cluster_dns_zone
  vpc_id  = var.vpc_ref
}

# Associate storage zone with vpc (incase of reusing an existing dns zone)
module "associate_storage_dns" {
  source  = "../../../resources/aws/network/route53_vpc_association"
  turn_on = var.create_dns_zone == false && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  zone_id = var.vpc_storage_cluster_dns_zone
  vpc_id  = var.vpc_ref
}

# Associate reverse zone with vpc (incase of reusing an existing dns zone)
module "associate_reverse_dns" {
  source  = "../../../resources/aws/network/route53_vpc_association"
  turn_on = var.create_dns_zone == false ? true : false
  zone_id = var.vpc_reverse_dns_zone
  vpc_id  = var.vpc_ref
}
