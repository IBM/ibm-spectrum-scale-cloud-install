/*
    Creates IBM Cloud routing table route for protocol nodes.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "turn_on" {}
variable "clone_complete" {}
variable "storage_cluster_create_complete" {}
variable "create_scale_cluster" {}
variable "clone_path" {}

locals {
  client_inventory_path = format("%s/%s/client_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  client_playbook       = format("%s/%s/client_cloud_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "null_resource" "perform_mount_filesets" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${local.client_inventory_path} ${local.client_playbook}"
  }
  triggers = {
    build = timestamp()
  }
}
