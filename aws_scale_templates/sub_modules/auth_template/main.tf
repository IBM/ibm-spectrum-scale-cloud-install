/*
    Creates auth service resources required for IBM Spectrum scale protocol configuration
*/

# Create cloud managed ad service
module "managed_ad" {
  source             = "../../../resources/aws/managed_ad"
  turn_on            = var.create_cloud_managed_auth ? true : false
  ad_password        = var.managed_ad_password
  directory_dns_name = var.managed_ad_dns_name
  directory_size     = var.managed_ad_size
  subnet_ids         = var.managed_ad_subnet_refs
  vpc_ref            = var.vpc_ref
}
