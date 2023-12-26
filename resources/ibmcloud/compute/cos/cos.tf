terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "prefix" {}
variable "resource_group_id" {}
variable "region_location" {}

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}instance"
  resource_group_id = var.resource_group_id
  plan              = "standard"
  location          = "global"
  service           = "cloud-object-storage"
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.prefix}bucket"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region_location
  storage_class        = "standard"
  depends_on           = [ibm_resource_instance.cos_instance]
}

resource "ibm_resource_key" "hmac_key" {
  name                 = "${var.prefix}bucket"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  parameters           = { "HMAC" = true }
  role                 = "Manager"
}

output "bucket_name" {
  value = ibm_cos_bucket.cos_bucket.bucket_name
}

output "access_key_id" {
  value = ibm_resource_key.hmac_key.credentials["cos_hmac_keys.access_key_id"]
}

output "secret_access_key" {
  value = ibm_resource_key.hmac_key.credentials["cos_hmac_keys.secret_access_key"]
}

output "bucket_endpoint" {
  value = ibm_cos_bucket.cos_bucket.s3_endpoint_direct
}