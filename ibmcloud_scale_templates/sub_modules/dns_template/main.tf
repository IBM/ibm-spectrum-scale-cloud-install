/*
    IBM Storage scale cloud deployment requires the below DNS resources.

    1. DNS service
    2. Compute DNS zone
    3. Storage DNS permitted network
    4. Storage DNS zone
    5. Compute DNS permitted network

*/


data "ibm_resource_group" "itself" {
  name = var.resource_group_name
}

# Create a new DNS service
module "dns_service" {
  source                 = "../../../resources/ibmcloud/resource_instance"
  resource_instance_name = format("%s-scaledns", var.resource_prefix)
  resource_group_id      = data.ibm_resource_group.itself.id
  resource_tags          = var.vpc_dns_tags
  target_location        = "global"
  service_name           = "dns-svcs"
  plan_type              = "standard-dns"
}

# Creates a new storage private DNS zone in IBMCloud
module "storage_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  dns_domain     = var.vpc_storage_cluster_dns_zone
  dns_service_id = module.dns_service.resource_guid
  description    = "Private DNS Zone for Spectrum Scale storage VPC DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

data "ibm_is_vpc" "vpc" {
  identifier = var.vpc_ref
}

# Creates a storage DNS permitted network
module "storage_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = var.create_dns_zone && (var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? 1 : 0
  instance_id     = module.dns_service.resource_guid
  zone_id         = module.storage_dns_zone.dns_zone_id
  vpc_crn         = data.ibm_is_vpc.vpc.crn
}

# Creates a new compute private DNS zone in IBMCloud
module "compute_dns_zone" {
  source         = "../../../resources/ibmcloud/network/dns_zone"
  turn_on        = var.create_dns_zone && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") ? true : false
  dns_domain     = var.vpc_compute_cluster_dns_zone
  dns_service_id = module.dns_service.resource_guid
  description    = "Private DNS Zone for Spectrum Scale compute VPC DNS communication."
  dns_label      = var.resource_prefix
  depends_on     = [module.dns_service]
}

# Creates a compute DNS permitted network
module "compute_dns_permitted_network" {
  source          = "../../../resources/ibmcloud/network/dns_permitted_network"
  permitted_count = var.create_dns_zone && (var.cluster_type == "Compute-only" || var.cluster_type == "Combined-compute-storage") && var.vpc_create_separate_subnets ? 1 : 0
  instance_id     = module.dns_service.resource_guid
  zone_id         = module.compute_dns_zone.dns_zone_id
  vpc_crn         = data.ibm_is_vpc.vpc.crn
  depends_on      = [module.storage_dns_permitted_network]
}
