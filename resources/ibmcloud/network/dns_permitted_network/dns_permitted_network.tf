/*
   Add Permitted_network to IBM Cloud DNS Zone.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "permitted_count" {}
variable "instance_id" {}
variable "zone_id" {}
variable "vpc_crn" {}

resource "time_sleep" "wait_30_seconds" {
  count           = var.permitted_count
  create_duration = "30s"
}

resource "ibm_dns_permitted_network" "itself" {
  count       = var.permitted_count
  instance_id = var.instance_id
  zone_id     = var.zone_id
  vpc_crn     = var.vpc_crn
  type        = "vpc"
  depends_on  = [time_sleep.wait_30_seconds]
}
