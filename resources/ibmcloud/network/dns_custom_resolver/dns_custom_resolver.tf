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

variable "customer_resolver_name" {}
variable "instance_guid" {}
variable "subnet_crn" {}
variable "description" {}

resource "ibm_dns_custom_resolver" "itself" {
  name        = var.customer_resolver_name
  instance_id = var.instance_guid
  description = var.description
  locations {
    subnet_crn = var.subnet_crn
    enabled    = true
  }
}

output "custom_resolver_id" {
  value = ibm_dns_custom_resolver.itself.id
}
