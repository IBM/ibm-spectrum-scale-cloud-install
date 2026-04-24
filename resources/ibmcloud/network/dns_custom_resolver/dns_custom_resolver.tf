terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

/*
   Add custom resolver to IBM Cloud DNS resource instance.
*/


variable "custom_resolver_name" {}
variable "instance_guid" {}
variable "subnet_crn" {}
variable "description" {}

resource "ibm_dns_custom_resolver" "itself" {
  name        = var.custom_resolver_name
  instance_id = var.instance_guid
  description = var.description
  dynamic "locations" {
    for_each = var.subnet_crn
    content {
      subnet_crn = locations.value
      enabled    = true
    }
  }
}

output "custom_resolver_id" {
  value = ibm_dns_custom_resolver.itself.custom_resolver_id
}
