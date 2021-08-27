/*
   Add custom resolver to IBM Cloud DNS resource instance.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "location_count" {}
variable "instance_guid" {}
variable "resolver_id" {}
variable "subnet_crn" {}

resource "ibm_dns_custom_resolver_location" "itself" {
  count       = var.location_count
  instance_id = var.instance_guid
  resolver_id = var.resolver_id
  subnet_crn  = var.subnet_crn
  enabled     = false
}
