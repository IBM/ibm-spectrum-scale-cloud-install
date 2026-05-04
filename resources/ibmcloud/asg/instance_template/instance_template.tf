/*
    Creates a Instance group template.
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "resource_group_id" {}
variable "launch_template_name" {}
variable "instance_type" {}
variable "image_id" {}
variable "vpc" {}
variable "zone" {}
variable "subnet" {}
variable "key_name" {}
variable "security_groups" {}

resource "ibm_is_instance_template" "itself" {
  name           = var.launch_template_name
  vpc            = var.vpc
  zone           = var.zone
  resource_group = var.resource_group_id
  image          = var.image_id
  profile        = var.instance_type

  primary_network_interface {
    name            = format("%s-nic", var.launch_template_name)
    subnet          = var.subnet
    security_groups = var.security_groups
  }

  boot_volume {
    name                             = format("%s-boot", var.launch_template_name)
    delete_volume_on_instance_delete = true
  }

  keys = var.key_name
}

output "instance_template_id" {
  value = ibm_is_instance_template.itself.id
}
