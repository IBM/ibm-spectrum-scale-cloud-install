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
variable "inventory_path" {}
variable "playbook_path" {}
variable "tamplate" {}

resource "null_resource" "prepare_client_inventory" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = var.tamplate
  }
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "mount_filesets" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${var.inventory_path} ${var.playbook_path}"
  }
  triggers = {
    build = timestamp()
  }
  depends_on = [resource.null_resource.prepare_client_inventory]
}
