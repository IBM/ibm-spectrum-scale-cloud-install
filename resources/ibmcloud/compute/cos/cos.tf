terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}


/**
#################################################################################################################
*                           Resources Section for the COS Bucket Module.
#################################################################################################################
*/

variable "prefix" {}
variable "resource_group_id" {}
variable "cos_bucket_plan" {}
variable "region_location" {}
variable "storage_class" {}
# variable "bucket_location" {}
# variable "obj_key" {}
# variable "obj_content" {}

/**
* COS Instance
* Element : resource_instance
* This resource will be used to create a resource instance.
**/

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}instance"
  resource_group_id = var.resource_group_id
  plan              = var.cos_bucket_plan
  location          = "global"
  service           = "cloud-object-storage"
}

/**
* COS Bucket
* Element : cos_bucket
* This resource will be used to create a COS Bucket.
**/
resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.prefix}bucket"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region_location
  storage_class        = var.storage_class
  depends_on           = [ibm_resource_instance.cos_instance]
}

/**
* COS Bucket Object
* Element : cos_object
* This resource will be used to create a COS Bucket Object.
**/
# resource "ibm_cos_bucket_object" "cos_object" {
#   bucket_crn      = ibm_cos_bucket.cos_bucket.crn
#   bucket_location = var.bucket_location
#   key             = var.obj_key
#   content         = var.obj_content
#   depends_on      = [ibm_cos_bucket.cos_bucket]
# }
