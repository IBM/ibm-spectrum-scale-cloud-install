/*
    Creates IBM Cloud Resource Instance resource.
*/

variable "resource_instance_name" {}
variable "dns_service_count" {}
variable "target_location" {}
variable "service_name" {}
variable "plan_type" {}
variable "resource_grp_id" {}


resource "ibm_resource_instance" "resource_instance" {
  count             = var.dns_service_count
  name              = element(var.resource_instance_name, count.index)
  resource_group_id = var.resource_grp_id
  location          = var.target_location
  service           = var.service_name
  plan              = var.plan_type
}

output "resource_guid" {
  value = ibm_resource_instance.resource_instance.*.guid
}
