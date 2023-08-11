/*
    Excutes ansible playbook to configure mrot on IBM Spectrum Scale compute and storage cluster.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "remote_mount_create_complete" {}

locals {
  compute_inventory_path   = format("%s/%s/compute_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  storage_inventory_path   = format("%s/%s/storage_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  mrot_playbook_path       = format("%s/%s/mrot_config_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
  startup_cluster_playbook = format("%s/%s/%s/startup_cluster.yaml", var.clone_path, "ibm-spectrum-scale-install-infra", "samples")
}

resource "null_resource" "perform_mrot_config_compute" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.compute_inventory_path} ${local.mrot_playbook_path}"
  }
}

resource "null_resource" "perform_mrot_config_storage" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.storage_inventory_path} ${local.mrot_playbook_path}"
  }
  depends_on = [null_resource.perform_mrot_config_compute]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "startup_storage_cluster" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.storage_inventory_path} ${local.startup_cluster_playbook}"
  }
  depends_on = [null_resource.perform_mrot_config_compute, null_resource.perform_mrot_config_storage]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "startup_compute_cluster" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.compute_inventory_path} ${local.startup_cluster_playbook}"
  }
  depends_on = [null_resource.perform_mrot_config_compute, null_resource.perform_mrot_config_storage, null_resource.startup_storage_cluster]
  triggers = {
    build = timestamp()
  }
}
