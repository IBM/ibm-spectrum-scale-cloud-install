terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

/*
    Creates specified IBM Cloud resource group name.
*/


variable "resource_group_name" {}

resource "ibm_resource_group" "itself" {
  name = var.resource_group_name
}

output "resource_group_id" {
  value = ibm_resource_group.itself.id
}
