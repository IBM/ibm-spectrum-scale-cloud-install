/*
    Creates IBM Cloud failover for protocol nodes.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "ic_region" {}
variable "ic_zone" {}
variable "ic_rg" {}
variable "ic_vpc" {}
variable "ic_rt" {}
variable "file" {}
variable "turn_on" {}
variable "create_scale_cluster" {}

resource "null_resource" "update_script" {
  count = (tobool(var.turn_on) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
      sed -i 's|IC_REGION=|IC_REGION=${var.ic_region}|g' ${var.file}
      sed -i 's|IC_ZONE=|IC_ZONE=${var.ic_zone}|g' ${var.file}
      sed -i 's|IC_RG=|IC_RG=${var.ic_rg}|g' ${var.file}
      sed -i 's|IC_VPC=|IC_VPC=${var.ic_vpc}|g' ${var.file}
      sed -i 's|IC_RT=|IC_RT=${var.ic_rt}|g' ${var.file}
    EOT
  }
}
