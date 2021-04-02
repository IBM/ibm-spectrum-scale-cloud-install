/*
    Creates IBM Cloud Resource Instance resource.
*/

variable "resource_instance_name" {}
variable "target_location" {}
variable "service_name" {}
variable "plan_type" {}
variable "resource_grp_id" {}


resource "ibm_resource_instance" "resource_instance" {
  name              = var.resource_instance_name
  resource_group_id = var.resource_grp_id
  location          = var.target_location
  service           = var.service_name
  plan              = var.plan_type
}

output "resource_guid" {
  value = ibm_resource_instance.resource_instance.guid
}
