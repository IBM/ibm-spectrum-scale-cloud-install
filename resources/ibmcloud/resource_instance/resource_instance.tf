/*
   Creates IBM Cloud Resource instance.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "resource_instance_name" {}
variable "service_count" {}
variable "target_location" {}
variable "service_name" {}
variable "plan_type" {}
variable "resource_group_id" {}

resource "ibm_resource_instance" "itself" {
  count             = var.service_count
  name              = element(var.resource_instance_name, count.index)
  resource_group_id = var.resource_group_id
  location          = var.target_location
  service           = var.service_name
  plan              = var.plan_type
}

output "resource_guid" {
  value = ibm_resource_instance.itself.*.guid
}
