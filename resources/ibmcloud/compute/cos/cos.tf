terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "prefix" {}
variable "resource_group_id" {}
variable "cos_instance_plan" {}
variable "cos_instance_location" {}
variable "cos_instance_service" {}
variable "cos_hmac_role" {}
variable "new_instance_bucket_hmac" {}
variable "exstng_instance_new_bucket_hmac" {}
variable "exstng_instance_bucket_new_hmac" {}
variable "exstng_instance_hmac_new_bucket" {}
variable "exstng_instance_bucket_hmac" {}
variable "filesystem" {}

#############################################################################################################
# 1. It creates new COS instance, Bucket and Hmac Key
#############################################################################################################

locals {
  path_elements = split("/", var.filesystem)
  filesystem    = element(local.path_elements, length(local.path_elements) - 1)

  new_cos_instance = distinct([for instance in var.new_instance_bucket_hmac : instance.cos_instance])
  # New bucket single Site
  new_bucket_single_site_region = [for region in var.new_instance_bucket_hmac : region.bucket_region if region.bucket_type == "single_site_location"]
  storage_class_single_site     = [for class in var.new_instance_bucket_hmac : class.bucket_storage_class if class.bucket_type == "single_site_location"]
  mode_single_site              = [for mode in var.new_instance_bucket_hmac : mode.mode if mode.bucket_type == "single_site_location"]
  afm_fileset_single_site       = [for fileset in var.new_instance_bucket_hmac : fileset.afm_fileset if fileset.bucket_type == "single_site_location"]
  # New bucket regional
  new_bucket_regional_region = [for region in var.new_instance_bucket_hmac : region.bucket_region if region.bucket_type == "region_location" || region.bucket_type == ""]
  storage_class_regional     = [for class in var.new_instance_bucket_hmac : class.bucket_storage_class if class.bucket_type == "region_location" || class.bucket_type == ""]
  mode_regional              = [for mode in var.new_instance_bucket_hmac : mode.mode if mode.bucket_type == "region_location" || mode.bucket_type == ""]
  afm_fileset_regional       = [for fileset in var.new_instance_bucket_hmac : fileset.afm_fileset if fileset.bucket_type == "region_location" || fileset.bucket_type == ""]
  # New bucket cross region
  new_bucket_cross_region      = [for region in var.new_instance_bucket_hmac : region.bucket_region if region.bucket_type == "cross_region_location"]
  storage_class_cross_regional = [for class in var.new_instance_bucket_hmac : class.bucket_storage_class if class.bucket_type == "cross_region_location"]
  mode_cross_regional          = [for mode in var.new_instance_bucket_hmac : mode.mode if mode.bucket_type == "cross_region_location"]
  fileset_cross_regional       = [for fileset in var.new_instance_bucket_hmac : fileset.afm_fileset if fileset.bucket_type == "cross_region_location"]
}

resource "ibm_resource_instance" "cos_instance" {
  for_each = {
    for idx, count_number in range(1, length(local.new_cos_instance) + 1) : idx => {
      sequence_string = tostring(count_number)
    }
  }
  name              = format("%s-%03s", "${var.prefix}instance", each.value.sequence_string)
  resource_group_id = var.resource_group_id
  plan              = var.cos_instance_plan
  location          = var.cos_instance_location
  service           = var.cos_instance_service
}

resource "ibm_cos_bucket" "cos_bucket_single_site" {
  for_each = {
    for idx, count_number in range(1, length(local.new_bucket_single_site_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in ibm_resource_instance.cos_instance : instance_id[*].id]), idx)
      region_location = element(local.new_bucket_single_site_region, idx)
      storage_class   = element(local.storage_class_single_site, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}bucket-new", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  single_site_location = each.value.region_location
  storage_class        = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on           = [ibm_resource_instance.cos_instance]
}

resource "ibm_cos_bucket" "cos_bucket_regional" {
  for_each = {
    for idx, count_number in range(1, length(local.new_bucket_regional_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in ibm_resource_instance.cos_instance : instance_id[*].id]), idx)
      region_location = element(local.new_bucket_regional_region, idx)
      storage_class   = element(local.storage_class_regional, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}bucket-new", (each.value.sequence_string + length(local.new_bucket_single_site_region)))
  resource_instance_id = each.value.cos_instance
  region_location      = each.value.region_location
  storage_class        = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on           = [ibm_resource_instance.cos_instance]
}

resource "ibm_cos_bucket" "cos_bucket_cross_region" {
  for_each = {
    for idx, count_number in range(1, length(local.new_bucket_cross_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in ibm_resource_instance.cos_instance : instance_id[*].id]), idx)
      region_location = element(local.new_bucket_cross_region, idx)
      storage_class   = element(local.storage_class_cross_regional, idx)
    }
  }
  bucket_name           = format("%s-%03s", "${var.prefix}bucket-new", (each.value.sequence_string + (length(local.new_bucket_single_site_region) + length(local.new_bucket_regional_region))))
  resource_instance_id  = each.value.cos_instance
  cross_region_location = each.value.region_location
  storage_class         = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on            = [ibm_resource_instance.cos_instance]
}

resource "ibm_resource_key" "hmac_key" {
  for_each = {
    for idx, count_number in range(1, length(local.new_cos_instance) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in ibm_resource_instance.cos_instance : instance_id[*].id]), idx)
    }
  }
  name                 = format("%s-%03s", "${var.prefix}hmac-key-new", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  parameters           = { "HMAC" = true }
  role                 = var.cos_hmac_role
}

locals {
  buckets   = concat((flatten([for bucket in ibm_cos_bucket.cos_bucket_single_site : bucket[*].bucket_name])), (flatten([for bucket in ibm_cos_bucket.cos_bucket_regional : bucket[*].bucket_name])), (flatten([for bucket in ibm_cos_bucket.cos_bucket_cross_region : bucket[*].bucket_name])))
  endpoints = concat((flatten([for endpoint in ibm_cos_bucket.cos_bucket_single_site : endpoint[*].s3_endpoint_direct])), (flatten([for endpoint in ibm_cos_bucket.cos_bucket_regional : endpoint[*].s3_endpoint_direct])), (flatten([for endpoint in ibm_cos_bucket.cos_bucket_cross_region : endpoint[*].s3_endpoint_direct])))
  modes     = concat(local.mode_single_site, local.mode_regional, local.mode_cross_regional)
  filesets  = concat(local.afm_fileset_single_site, local.afm_fileset_regional, local.fileset_cross_regional)


  afm_cos_bucket_details_1 = [for idx, config in var.new_instance_bucket_hmac : {
    akey   = ibm_resource_key.hmac_key[0].credentials["cos_hmac_keys.access_key_id"]
    bucket = (local.buckets)[idx]
    skey   = ibm_resource_key.hmac_key[0].credentials["cos_hmac_keys.secret_access_key"]
  }]

  afm_config_details_1 = [for idx, config in var.new_instance_bucket_hmac : {
    bucket     = (local.buckets)[idx]
    filesystem = local.filesystem
    fileset    = (local.filesets)[idx]
    mode       = (local.modes)[idx]
    endpoint   = "https://${(local.endpoints)[idx]}"
  }]
}

#############################################################################################################
# 2. It uses existing COS instance and creates new COS Bucket and Hmac Key in that instance.
#############################################################################################################

locals {
  exstng_instance_new_bkt_hmac = [for instance in var.exstng_instance_new_bucket_hmac : instance.cos_instance]
  # New bucket single Site
  exstng_instance_new_bkt_hmac_single_site  = [for instance in var.exstng_instance_new_bucket_hmac : instance.cos_instance if instance.bucket_type == "single_site_location"]
  exstng_instance_single_site_region        = [for region in var.exstng_instance_new_bucket_hmac : region.bucket_region if region.bucket_type == "single_site_location"]
  exstng_instance_storage_class_single_site = [for class in var.exstng_instance_new_bucket_hmac : class.bucket_storage_class if class.bucket_type == "single_site_location"]
  exstng_instance_mode_single_site          = [for mode in var.exstng_instance_new_bucket_hmac : mode.mode if mode.bucket_type == "single_site_location"]
  exstng_instance_fileset_single_site       = [for fileset in var.exstng_instance_new_bucket_hmac : fileset.afm_fileset if fileset.bucket_type == "single_site_location"]
  # New bucket regional
  exstng_instance_new_bkt_hmac_regional  = [for instance in var.exstng_instance_new_bucket_hmac : instance.cos_instance if instance.bucket_type == "region_location" || instance.bucket_type == ""]
  exstng_instance_regional_region        = [for region in var.exstng_instance_new_bucket_hmac : region.bucket_region if region.bucket_type == "region_location" || region.bucket_type == ""]
  exstng_instance_storage_class_regional = [for class in var.exstng_instance_new_bucket_hmac : class.bucket_storage_class if class.bucket_type == "region_location" || class.bucket_type == ""]
  exstng_instance_mode_regional          = [for mode in var.exstng_instance_new_bucket_hmac : mode.mode if mode.bucket_type == "region_location" || mode.bucket_type == ""]
  exstng_instance_fileset_regional       = [for fileset in var.exstng_instance_new_bucket_hmac : fileset.afm_fileset if fileset.bucket_type == "region_location" || fileset.bucket_type == ""]
  # New bucket cross region
  exstng_instance_new_bkt_hmac_cross_regional  = [for instance in var.exstng_instance_new_bucket_hmac : instance.cos_instance if instance.bucket_type == "cross_region_location"]
  exstng_instance_cross_regional               = [for region in var.exstng_instance_new_bucket_hmac : region.bucket_region if region.bucket_type == "cross_region_location"]
  exstng_instance_storage_class_cross_regional = [for class in var.exstng_instance_new_bucket_hmac : class.bucket_storage_class if class.bucket_type == "cross_region_location"]
  exstng_instance_mode_cross_regional          = [for mode in var.exstng_instance_new_bucket_hmac : mode.mode if mode.bucket_type == "cross_region_location"]
  exstng_instance_fileset_cross_regional       = [for fileset in var.exstng_instance_new_bucket_hmac : fileset.afm_fileset if fileset.bucket_type == "cross_region_location"]
}

data "ibm_resource_instance" "existing_cos_instance_single_site" {
  for_each = {
    for idx, value in local.exstng_instance_new_bkt_hmac_single_site : idx => {
      cos_instance = element(local.exstng_instance_new_bkt_hmac_single_site, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_instance_new_cos_bucket_single_site" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_single_site_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.existing_cos_instance_single_site : instance_id[*].id]), idx)
      region_location = element(local.exstng_instance_single_site_region, idx)
      storage_class   = element(local.exstng_instance_storage_class_single_site, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}bucket", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  single_site_location = each.value.region_location
  storage_class        = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on           = [data.ibm_resource_instance.existing_cos_instance_single_site]
}

data "ibm_resource_instance" "existing_cos_instance_bucket_regional" {
  for_each = {
    for idx, value in local.exstng_instance_new_bkt_hmac_regional : idx => {
      cos_instance = element(local.exstng_instance_new_bkt_hmac_regional, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_instance_new_cos_bucket_regional" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_regional_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.existing_cos_instance_bucket_regional : instance_id[*].id]), idx)
      region_location = element(local.exstng_instance_regional_region, idx)
      storage_class   = element(local.exstng_instance_storage_class_regional, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}bucket", (each.value.sequence_string + length(local.exstng_instance_single_site_region)))
  resource_instance_id = each.value.cos_instance
  region_location      = each.value.region_location
  storage_class        = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on           = [data.ibm_resource_instance.existing_cos_instance_bucket_regional]
}

data "ibm_resource_instance" "existing_cos_instancecross_regional" {
  for_each = {
    for idx, value in local.exstng_instance_new_bkt_hmac_cross_regional : idx => {
      cos_instance = element(local.exstng_instance_new_bkt_hmac_cross_regional, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_instance_new_cos_bucket_cross_regional" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_cross_regional) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.existing_cos_instancecross_regional : instance_id[*].id]), idx)
      region_location = element(local.exstng_instance_cross_regional, idx)
      storage_class   = element(local.exstng_instance_storage_class_cross_regional, idx)
    }
  }
  bucket_name           = format("%s-%03s", "${var.prefix}bucket", (each.value.sequence_string + (length(local.exstng_instance_single_site_region) + length(local.exstng_instance_regional_region))))
  resource_instance_id  = each.value.cos_instance
  cross_region_location = each.value.region_location
  storage_class         = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on            = [data.ibm_resource_instance.existing_cos_instancecross_regional]
}

data "ibm_resource_instance" "existing_cos_instance" {
  for_each = {
    for idx, value in local.exstng_instance_new_bkt_hmac : idx => {
      cos_instance = element(local.exstng_instance_new_bkt_hmac, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_resource_key" "existing_instance_new_hmac_keys" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_new_bkt_hmac) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.existing_cos_instance : instance_id[*].id]), idx)
    }
  }
  name                 = format("%s-%03s", "${var.prefix}hmac-key", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  parameters           = { "HMAC" = true }
  role                 = var.cos_hmac_role
  depends_on           = [data.ibm_resource_instance.existing_cos_instance]
}

locals {
  exstng_instance_buckets   = concat((flatten([for bucket in ibm_cos_bucket.existing_instance_new_cos_bucket_single_site : bucket[*].bucket_name])), (flatten([for bucket in ibm_cos_bucket.existing_instance_new_cos_bucket_regional : bucket[*].bucket_name])), (flatten([for bucket in ibm_cos_bucket.existing_instance_new_cos_bucket_cross_regional : bucket[*].bucket_name])))
  exstng_instance_endpoints = concat((flatten([for endpoint in ibm_cos_bucket.existing_instance_new_cos_bucket_single_site : endpoint[*].s3_endpoint_direct])), (flatten([for endpoint in ibm_cos_bucket.existing_instance_new_cos_bucket_regional : endpoint[*].s3_endpoint_direct])), (flatten([for endpoint in ibm_cos_bucket.existing_instance_new_cos_bucket_cross_regional : endpoint[*].s3_endpoint_direct])))
  exstng_instance_modes     = concat(local.exstng_instance_mode_single_site, local.exstng_instance_mode_regional, local.exstng_instance_mode_cross_regional)
  exstng_instance_filesets  = concat(local.exstng_instance_fileset_single_site, local.exstng_instance_fileset_regional, local.exstng_instance_fileset_cross_regional)

  afm_cos_bucket_details_2 = [for idx, config in var.exstng_instance_new_bucket_hmac : {
    akey   = (flatten([for access_key in ibm_resource_key.existing_instance_new_hmac_keys : access_key[*].credentials["cos_hmac_keys.access_key_id"]]))[idx]
    bucket = (local.exstng_instance_buckets)[idx]
    skey   = (flatten([for secret_access_key in ibm_resource_key.existing_instance_new_hmac_keys : secret_access_key[*].credentials["cos_hmac_keys.secret_access_key"]]))[idx]
  }]

  afm_config_details_2 = [for idx, config in var.exstng_instance_new_bucket_hmac : {
    bucket     = (local.exstng_instance_buckets)[idx]
    filesystem = local.filesystem
    fileset    = (local.exstng_instance_filesets)[idx]
    mode       = (local.exstng_instance_modes)[idx]
    endpoint   = "https://${(local.exstng_instance_endpoints)[idx]}"
  }]
}

#############################################################################################################
# 3. It uses existing COS instance and existing Bucket and creates new Hmac Key in that instance.
#############################################################################################################

locals {
  exstng_instance_bkt_new_hmac           = [for instance in var.exstng_instance_bucket_new_hmac : instance.cos_instance]
  exstng_instance_exstng_bucket          = [for bucket in var.exstng_instance_bucket_new_hmac : bucket.bucket_name]
  region_exstng_instance_bucket_new_hmac = [for region in var.exstng_instance_bucket_new_hmac : region.bucket_region]
  exstng_instance_exstng_bucket_type     = [for type in var.exstng_instance_bucket_new_hmac : type.bucket_type]
}

data "ibm_resource_instance" "existing_cos_instance_bucket_new_hmac" {
  for_each = {
    for idx, value in var.exstng_instance_bucket_new_hmac : idx => {
      cos_instance = element(local.exstng_instance_bkt_new_hmac, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

data "ibm_cos_bucket" "existing_cos_instance_bucket" {
  for_each = {
    for idx, value in var.exstng_instance_bucket_new_hmac : idx => {
      bucket_name          = element(local.exstng_instance_exstng_bucket, idx)
      resource_instance_id = element(flatten([for instance in data.ibm_resource_instance.existing_cos_instance_bucket_new_hmac : instance[*].id]), idx)
      bucket_region        = element(local.region_exstng_instance_bucket_new_hmac, idx)
      bucket_type          = element(local.exstng_instance_exstng_bucket_type, idx)
    }
  }
  bucket_name          = each.value.bucket_name
  resource_instance_id = each.value.resource_instance_id
  bucket_region        = each.value.bucket_region
  bucket_type          = each.value.bucket_type
  depends_on           = [data.ibm_resource_instance.existing_cos_instance_bucket_new_hmac]
}

resource "ibm_resource_key" "existing_instance_bkt_new_hmac_keys" {
  for_each = {
    for idx, count_number in range(1, length(var.exstng_instance_bucket_new_hmac) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.existing_cos_instance_bucket_new_hmac : instance_id[*].id]), idx)
    }
  }
  name                 = format("%s-%03s", "${var.prefix}new-hmac-key", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  parameters           = { "HMAC" = true }
  role                 = var.cos_hmac_role
  depends_on           = [data.ibm_resource_instance.existing_cos_instance_bucket_new_hmac]
}

locals {
  afm_cos_bucket_details_3 = [for idx, config in var.exstng_instance_bucket_new_hmac : {
    akey   = (flatten([for access_key in ibm_resource_key.existing_instance_bkt_new_hmac_keys : access_key[*].credentials["cos_hmac_keys.access_key_id"]]))[idx]
    bucket = (flatten([for bucket in data.ibm_cos_bucket.existing_cos_instance_bucket : bucket[*].bucket_name]))[idx]
    skey   = (flatten([for secret_access_key in ibm_resource_key.existing_instance_bkt_new_hmac_keys : secret_access_key[*].credentials["cos_hmac_keys.secret_access_key"]]))[idx]
  }]

  afm_config_details_3 = [for idx, config in var.exstng_instance_bucket_new_hmac : {
    bucket     = (flatten([for bucket in data.ibm_cos_bucket.existing_cos_instance_bucket : bucket[*].bucket_name]))[idx]
    filesystem = local.filesystem
    fileset    = ([for fileset in var.exstng_instance_bucket_new_hmac : fileset.afm_fileset])[idx]
    mode       = ([for mode in var.exstng_instance_bucket_new_hmac : mode.mode])[idx]
    endpoint   = "https://${(flatten([for endpoint in data.ibm_cos_bucket.existing_cos_instance_bucket : endpoint[*].s3_endpoint_direct]))[idx]}"
  }]
}

#############################################################################################################
# 4. It uses existing COS instance and existing Hmac Key and creates new Bucket in that instance.
#############################################################################################################

locals {
  exstng_instance_hmac_new_bkt = [for instance in var.exstng_instance_hmac_new_bucket : instance.cos_instance]
  exstng_instance_exstng_hmac  = [for hmac in var.exstng_instance_hmac_new_bucket : hmac.cos_service_cred_key]

  # New bucket single Site
  exstng_instance_hmac_new_bkt_single_site       = [for instance in var.exstng_instance_hmac_new_bucket : instance.cos_instance if instance.bucket_type == "single_site_location"]
  exstng_instance_hmac_single_site_region        = [for region in var.exstng_instance_hmac_new_bucket : region.bucket_region if region.bucket_type == "single_site_location"]
  exstng_instance_hmac_storage_class_single_site = [for class in var.exstng_instance_hmac_new_bucket : class.bucket_storage_class if class.bucket_type == "single_site_location"]
  exstng_instance_hmac_mode_single_site          = [for mode in var.exstng_instance_hmac_new_bucket : mode.mode if mode.bucket_type == "single_site_location"]
  exstng_instance_hmac_fileset_single_site       = [for fileset in var.exstng_instance_hmac_new_bucket : fileset.afm_fileset if fileset.bucket_type == "single_site_location"]
  # New bucket regional
  exstng_instance_hmac_new_bkt_regional       = [for instance in var.exstng_instance_hmac_new_bucket : instance.cos_instance if instance.bucket_type == "region_location" || instance.bucket_type == ""]
  exstng_instance_hmac_regional_region        = [for region in var.exstng_instance_hmac_new_bucket : region.bucket_region if region.bucket_type == "region_location" || region.bucket_type == ""]
  exstng_instance_hmac_storage_class_regional = [for class in var.exstng_instance_hmac_new_bucket : class.bucket_storage_class if class.bucket_type == "region_location" || class.bucket_type == ""]
  exstng_instance_hmac_mode_regional          = [for mode in var.exstng_instance_hmac_new_bucket : mode.mode if mode.bucket_type == "region_location" || mode.bucket_type == ""]
  exstng_instance_hmac_fileset_regional       = [for fileset in var.exstng_instance_hmac_new_bucket : fileset.afm_fileset if fileset.bucket_type == "region_location" || fileset.bucket_type == ""]
  # New bucket cross region
  exstng_instance_hmac_new_bkt_cross_region         = [for instance in var.exstng_instance_hmac_new_bucket : instance.cos_instance if instance.bucket_type == "cross_region_location"]
  exstng_instance_hmac_cross_region                 = [for region in var.exstng_instance_hmac_new_bucket : region.bucket_region if region.bucket_type == "cross_region_location"]
  exstng_instance_hmac_storage_class_cross_regional = [for class in var.exstng_instance_hmac_new_bucket : class.bucket_storage_class if class.bucket_type == "cross_region_location"]
  exstng_instance_hmac_mode_cross_regional          = [for mode in var.exstng_instance_hmac_new_bucket : mode.mode if mode.bucket_type == "cross_region_location"]
  exstng_instance_hmac_fileset_cross_regional       = [for fileset in var.exstng_instance_hmac_new_bucket : fileset.afm_fileset if fileset.bucket_type == "cross_region_location"]
}

data "ibm_resource_instance" "exstng_cos_instance_hmac_new_bucket_single_site" {
  for_each = length(local.exstng_instance_hmac_new_bkt_single_site) == 0 ? {} : {
    for idx, value in local.exstng_instance_hmac_new_bkt_single_site : idx => {
      cos_instance = element(local.exstng_instance_hmac_new_bkt_single_site, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_cos_instance_hmac_new_cos_bucket_single_site" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_hmac_single_site_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket_single_site : instance_id[*].id]), idx)
      region_location = element(local.exstng_instance_hmac_single_site_region, idx)
      storage_class   = element(local.exstng_instance_hmac_storage_class_single_site, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}new-bucket", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  single_site_location = each.value.region_location
  storage_class        = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket_single_site]
}

data "ibm_resource_instance" "exstng_cos_instance_hmac_new_bucket_regional" {
  for_each = length(local.exstng_instance_hmac_new_bkt_regional) == 0 ? {} : {
    for idx, value in local.exstng_instance_hmac_new_bkt_regional : idx => {
      cos_instance = element(local.exstng_instance_hmac_new_bkt_regional, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_cos_instance_hmac_new_cos_bucket_regional" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_hmac_regional_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket_regional : instance_id[*].id]), idx)
      region_location = element(local.exstng_instance_hmac_regional_region, idx)
      storage_class   = element(local.exstng_instance_hmac_storage_class_regional, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}new-bucket", (each.value.sequence_string + length(local.exstng_instance_hmac_single_site_region)))
  resource_instance_id = each.value.cos_instance
  region_location      = each.value.region_location
  storage_class        = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket_regional]
}

data "ibm_resource_instance" "exstng_cos_instance_hmac_new_bucket_cross_region" {
  for_each = length(local.exstng_instance_hmac_new_bkt_cross_region) == 0 ? {} : {
    for idx, value in local.exstng_instance_hmac_new_bkt_cross_region : idx => {
      cos_instance = element(local.exstng_instance_hmac_new_bkt_cross_region, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_cos_instance_hmac_new_cos_bucket_cross_region" {
  for_each = {
    for idx, count_number in range(1, length(local.exstng_instance_hmac_cross_region) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket_cross_region : instance_id[*].id]), idx)
      region_location = element(local.exstng_instance_hmac_cross_region, idx)
      storage_class   = element(local.exstng_instance_hmac_storage_class_cross_regional, idx)
    }
  }
  bucket_name           = format("%s-%03s", "${var.prefix}new-bucket", (each.value.sequence_string + (length(local.exstng_instance_hmac_single_site_region) + length(local.exstng_instance_hmac_regional_region))))
  resource_instance_id  = each.value.cos_instance
  cross_region_location = each.value.region_location
  storage_class         = each.value.storage_class == "" ? "smart" : each.value.storage_class
  depends_on            = [data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket_cross_region]
}

data "ibm_resource_instance" "exstng_cos_instance_hmac_new_bucket" {
  for_each = {
    for idx, value in local.exstng_instance_hmac_new_bkt : idx => {
      cos_instance = element(local.exstng_instance_hmac_new_bkt, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

data "ibm_resource_key" "existing_hmac_key" {
  for_each = {
    for idx, value in local.exstng_instance_exstng_hmac : idx => {
      hmac_key             = element(local.exstng_instance_exstng_hmac, idx)
      resource_instance_id = element(flatten([for instance in data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket : instance[*].id]), idx)
    }
  }
  name                 = each.value.hmac_key
  resource_instance_id = each.value.resource_instance_id
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket]
}

locals {
  exstng_instance_hmac_buckets   = concat((flatten([for bucket in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket_single_site : bucket[*].bucket_name])), (flatten([for bucket in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket_regional : bucket[*].bucket_name])), (flatten([for bucket in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket_cross_region : bucket[*].bucket_name])))
  exstng_instance_hmac_endpoints = concat((flatten([for endpoint in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket_single_site : endpoint[*].s3_endpoint_direct])), (flatten([for endpoint in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket_regional : endpoint[*].s3_endpoint_direct])), (flatten([for endpoint in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket_cross_region : endpoint[*].s3_endpoint_direct])))
  exstng_instance_hmac_modes     = concat(local.exstng_instance_hmac_mode_single_site, local.exstng_instance_hmac_mode_regional, local.exstng_instance_hmac_mode_cross_regional)
  exstng_instance_hmac_filesets  = concat(local.exstng_instance_hmac_fileset_single_site, local.exstng_instance_hmac_fileset_regional, local.exstng_instance_hmac_fileset_cross_regional)

  afm_cos_bucket_details_4 = [for idx, config in var.exstng_instance_hmac_new_bucket : {
    akey   = (flatten([for access_key in data.ibm_resource_key.existing_hmac_key : access_key[*].credentials["cos_hmac_keys.access_key_id"]]))[idx]
    bucket = (local.exstng_instance_hmac_buckets)[idx]
    skey   = (flatten([for secret_access_key in data.ibm_resource_key.existing_hmac_key : secret_access_key[*].credentials["cos_hmac_keys.secret_access_key"]]))[idx]
  }]

  afm_config_details_4 = [for idx, config in var.exstng_instance_hmac_new_bucket : {
    bucket     = (local.exstng_instance_hmac_buckets)[idx]
    filesystem = local.filesystem
    fileset    = (local.exstng_instance_hmac_filesets)[idx]
    mode       = (local.exstng_instance_hmac_modes)[idx]
    endpoint   = "https://${(local.exstng_instance_hmac_endpoints)[idx]}"
  }]
}

#############################################################################################################
# 5. It uses existing COS instance, Bucket and Hmac Key
#############################################################################################################

locals {
  exstng_instance_bkt_hmac           = [for instance in var.exstng_instance_bucket_hmac : instance.cos_instance]
  exstng_instance_exstng_bkt         = [for bucket in var.exstng_instance_bucket_hmac : bucket.bucket_name]
  exstng_instance_hmac_bkt           = [for hmac in var.exstng_instance_bucket_hmac : hmac.cos_service_cred_key]
  region_exstng_instance_bucket_hmac = [for region in var.exstng_instance_bucket_hmac : region.bucket_region]
  exstng_instance_bkt_type           = [for type in var.exstng_instance_bucket_hmac : type.bucket_type]
}


data "ibm_resource_instance" "exstng_cos_instance_bucket_hmac" {
  for_each = {
    for idx, value in var.exstng_instance_bucket_hmac : idx => {
      cos_instance = element(local.exstng_instance_bkt_hmac, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

data "ibm_cos_bucket" "exstng_cos_instance_bucket" {
  for_each = {
    for idx, value in var.exstng_instance_bucket_hmac : idx => {
      bucket_name          = element(local.exstng_instance_exstng_bkt, idx)
      resource_instance_id = element(flatten([for instance in data.ibm_resource_instance.exstng_cos_instance_bucket_hmac : instance[*].id]), idx)
      bucket_region        = element(local.region_exstng_instance_bucket_hmac, idx)
      bucket_type          = element(local.exstng_instance_bkt_type, idx)
    }
  }
  bucket_name          = each.value.bucket_name
  resource_instance_id = each.value.resource_instance_id
  bucket_region        = each.value.bucket_region
  bucket_type          = each.value.bucket_type
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_bucket_hmac]
}

data "ibm_resource_key" "exstng_cos_instance_hmac" {
  for_each = {
    for idx, value in var.exstng_instance_bucket_hmac : idx => {
      hmac_key             = element(local.exstng_instance_hmac_bkt, idx)
      resource_instance_id = element(flatten([for instance in data.ibm_resource_instance.exstng_cos_instance_bucket_hmac : instance[*].id]), idx)
    }
  }
  name                 = each.value.hmac_key
  resource_instance_id = each.value.resource_instance_id
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_bucket_hmac]
}

locals {
  afm_cos_bucket_details_5 = [for idx, config in var.exstng_instance_bucket_hmac : {
    akey   = (flatten([for access_key in data.ibm_resource_key.exstng_cos_instance_hmac : access_key[*].credentials["cos_hmac_keys.access_key_id"]]))[idx]
    bucket = (flatten([for bucket in data.ibm_cos_bucket.exstng_cos_instance_bucket : bucket[*].bucket_name]))[idx]
    skey   = (flatten([for secret_access_key in data.ibm_resource_key.exstng_cos_instance_hmac : secret_access_key[*].credentials["cos_hmac_keys.secret_access_key"]]))[idx]
  }]

  afm_config_details_5 = [for idx, config in var.exstng_instance_bucket_hmac : {
    bucket     = (flatten([for bucket in data.ibm_cos_bucket.exstng_cos_instance_bucket : bucket[*].bucket_name]))[idx]
    filesystem = local.filesystem
    fileset    = ([for fileset in var.exstng_instance_bucket_hmac : fileset.afm_fileset])[idx]
    mode       = ([for mode in var.exstng_instance_bucket_hmac : mode.mode])[idx]
    endpoint   = "https://${(flatten([for endpoint in data.ibm_cos_bucket.exstng_cos_instance_bucket : endpoint[*].s3_endpoint_direct]))[idx]}"
  }]
}

output "afm_cos_bucket_details" {
  value = concat(local.afm_cos_bucket_details_1, local.afm_cos_bucket_details_2, local.afm_cos_bucket_details_3, local.afm_cos_bucket_details_4, local.afm_cos_bucket_details_5)
}

output "afm_config_details" {
  value = concat(local.afm_config_details_1, local.afm_config_details_2, local.afm_config_details_3, local.afm_config_details_4, local.afm_config_details_5)
}
