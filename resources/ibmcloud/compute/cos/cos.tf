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
#variable "cos_bucket_storage_class" {}
variable "cos_hmac_role" {}
#variable "bucket_type" {}
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
  new_cos_instance                = distinct([for instance in var.new_instance_bucket_hmac : instance.cos_instance])
  region_new_instance_bucket_hmac = [for region in var.new_instance_bucket_hmac : region.bucket_region]
  path_elements                   = split("/", var.filesystem)
  filesystem                      = element(local.path_elements, length(local.path_elements) - 1)
  new_bucket_storage_class        = [for class in var.new_instance_bucket_hmac : class.bucket_storage_class]
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

resource "ibm_cos_bucket" "cos_bucket" {
  for_each = {
    for idx, count_number in range(1, length(var.new_instance_bucket_hmac) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in ibm_resource_instance.cos_instance : instance_id[*].id]), idx)
      region_location = element(local.region_new_instance_bucket_hmac, idx)
      storage_class   = element(local.new_bucket_storage_class, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}bucket-new", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  region_location      = each.value.region_location
  storage_class        = each.value.storage_class
  depends_on           = [ibm_resource_instance.cos_instance]
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
  afm_cos_bucket_details_1 = [for idx, config in var.new_instance_bucket_hmac : {
    akey   = ibm_resource_key.hmac_key[0].credentials["cos_hmac_keys.access_key_id"]
    bucket = (flatten([for bucket in ibm_cos_bucket.cos_bucket : bucket[*].bucket_name]))[idx]
    skey   = ibm_resource_key.hmac_key[0].credentials["cos_hmac_keys.secret_access_key"]
  }]

  afm_config_details_1 = [for idx, config in var.new_instance_bucket_hmac : {
    bucket     = (flatten([for bucket in ibm_cos_bucket.cos_bucket : bucket[*].bucket_name]))[idx]
    filesystem = local.filesystem
    fileset    = ([for fileset in var.new_instance_bucket_hmac : fileset.afm_fileset])[idx]
    mode       = ([for mode in var.new_instance_bucket_hmac : mode.mode])[idx]
    endpoint   = "https://${(flatten([for endpoint in ibm_cos_bucket.cos_bucket : endpoint[*].s3_endpoint_direct]))[idx]}"
  }]
}

#############################################################################################################
# 2. It uses existing COS instance and creates new COS Bucket and Hmac Key in that instance.
#############################################################################################################

locals {
  exstng_instance_new_bkt_hmac           = [for instance in var.exstng_instance_new_bucket_hmac : instance.cos_instance]
  region_exstng_instance_new_bucket_hmac = [for region in var.exstng_instance_new_bucket_hmac : region.bucket_region]
  exstng_instance_new_bkt_storage_class  = [for class in var.exstng_instance_new_bucket_hmac : class.bucket_storage_class]
}

data "ibm_resource_instance" "existing_cos_instance" {
  for_each = {
    for idx, value in var.exstng_instance_new_bucket_hmac : idx => {
      cos_instance = element(local.exstng_instance_new_bkt_hmac, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_instance_new_cos_bucket" {
  for_each = {
    for idx, count_number in range(1, length(var.exstng_instance_new_bucket_hmac) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.existing_cos_instance : instance_id[*].id]), idx)
      region_location = element(local.region_exstng_instance_new_bucket_hmac, idx)
      storage_class   = element(local.exstng_instance_new_bkt_storage_class, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}bucket", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  region_location      = each.value.region_location
  storage_class        = each.value.storage_class
  depends_on           = [data.ibm_resource_instance.existing_cos_instance]
}

resource "ibm_resource_key" "existing_instance_new_hmac_keys" {
  for_each = {
    for idx, count_number in range(1, length(var.exstng_instance_new_bucket_hmac) + 1) : idx => {
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
  afm_cos_bucket_details_2 = [for idx, config in var.exstng_instance_new_bucket_hmac : {
    akey   = (flatten([for access_key in ibm_resource_key.existing_instance_new_hmac_keys : access_key[*].credentials["cos_hmac_keys.access_key_id"]]))[idx]
    bucket = (flatten([for bucket in ibm_cos_bucket.existing_instance_new_cos_bucket : bucket[*].bucket_name]))[idx]
    skey   = (flatten([for secret_access_key in ibm_resource_key.existing_instance_new_hmac_keys : secret_access_key[*].credentials["cos_hmac_keys.secret_access_key"]]))[idx]
  }]

  afm_config_details_2 = [for idx, config in var.exstng_instance_new_bucket_hmac : {
    bucket     = (flatten([for bucket in ibm_cos_bucket.existing_instance_new_cos_bucket : bucket[*].bucket_name]))[idx]
    filesystem = local.filesystem
    fileset    = ([for fileset in var.exstng_instance_new_bucket_hmac : fileset.afm_fileset])[idx]
    mode       = ([for mode in var.exstng_instance_new_bucket_hmac : mode.mode])[idx]
    endpoint   = "https://${(flatten([for endpoint in ibm_cos_bucket.existing_instance_new_cos_bucket : endpoint[*].s3_endpoint_direct]))[idx]}"
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
  exstng_instance_hmac_new_bkt         = [for instance in var.exstng_instance_hmac_new_bucket : instance.cos_instance]
  exstng_instance_exstng_hmac          = [for hmac in var.exstng_instance_hmac_new_bucket : hmac.hmac_key]
  region_exstng_instance_hmac_new_bkt  = [for region in var.exstng_instance_hmac_new_bucket : region.bucket_region]
  exstng_instnc_hmac_new_bkt_strg_clss = [for class in var.exstng_instance_hmac_new_bucket : class.bucket_storage_class]
}

data "ibm_resource_instance" "exstng_cos_instance_hmac_new_bucket" {
  for_each = {
    for idx, value in var.exstng_instance_hmac_new_bucket : idx => {
      cos_instance = element(local.exstng_instance_hmac_new_bkt, idx)
    }
  }
  name    = each.value.cos_instance
  service = var.cos_instance_service
}

resource "ibm_cos_bucket" "existing_cos_instance_hmac_new_cos_bucket" {
  for_each = {
    for idx, count_number in range(1, length(var.exstng_instance_hmac_new_bucket) + 1) : idx => {
      sequence_string = tostring(count_number)
      cos_instance    = element(flatten([for instance_id in data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket : instance_id[*].id]), idx)
      region_location = element(local.region_exstng_instance_hmac_new_bkt, idx)
      storage_class   = element(local.exstng_instnc_hmac_new_bkt_strg_clss, idx)
    }
  }
  bucket_name          = format("%s-%03s", "${var.prefix}new-bucket", each.value.sequence_string)
  resource_instance_id = each.value.cos_instance
  region_location      = each.value.region_location
  storage_class        = each.value.storage_class
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket]
}

data "ibm_resource_key" "existing_hmac_key" {
  for_each = {
    for idx, value in var.exstng_instance_hmac_new_bucket : idx => {
      hmac_key             = element(local.exstng_instance_exstng_hmac, idx)
      resource_instance_id = element(flatten([for instance in data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket : instance[*].id]), idx)
    }
  }
  name                 = each.value.hmac_key
  resource_instance_id = each.value.resource_instance_id
  depends_on           = [data.ibm_resource_instance.exstng_cos_instance_hmac_new_bucket]
}

locals {
  afm_cos_bucket_details_4 = [for idx, config in var.exstng_instance_hmac_new_bucket : {
    akey   = (flatten([for access_key in data.ibm_resource_key.existing_hmac_key : access_key[*].credentials["cos_hmac_keys.access_key_id"]]))[idx]
    bucket = (flatten([for bucket in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket : bucket[*].bucket_name]))[idx]
    skey   = (flatten([for secret_access_key in data.ibm_resource_key.existing_hmac_key : secret_access_key[*].credentials["cos_hmac_keys.secret_access_key"]]))[idx]
  }]

  afm_config_details_4 = [for idx, config in var.exstng_instance_hmac_new_bucket : {
    bucket     = (flatten([for bucket in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket : bucket[*].bucket_name]))[idx]
    filesystem = local.filesystem
    fileset    = ([for fileset in var.exstng_instance_hmac_new_bucket : fileset.afm_fileset])[idx]
    mode       = ([for mode in var.exstng_instance_hmac_new_bucket : mode.mode])[idx]
    endpoint   = "https://${(flatten([for endpoint in ibm_cos_bucket.existing_cos_instance_hmac_new_cos_bucket : endpoint[*].s3_endpoint_direct]))[idx]}"
  }]
}

#############################################################################################################
# 5. It uses existing COS instance, Bucket and Hmac Key
#############################################################################################################

locals {
  exstng_instance_bkt_hmac           = [for instance in var.exstng_instance_bucket_hmac : instance.cos_instance]
  exstng_instance_exstng_bkt         = [for bucket in var.exstng_instance_bucket_hmac : bucket.bucket_name]
  exstng_instance_hmac_bkt           = [for hmac in var.exstng_instance_bucket_hmac : hmac.hmac_key]
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
