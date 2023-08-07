/*
    Ansible playbook to enable scnryption using SGKLM.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "encryption_private_key" {}
variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "combined_cluster_create_complete" {}
variable "remote_mount_create_complete" {}

locals {
  encryption_private_key      = format("%s/%s/id_rsa", var.clone_path, var.encryption_private_key)
  compute_inventory_path      = format("%s/%s/compute_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  storage_inventory_path      = format("%s/%s/storage_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  combined_inventory_path     = format("%s/%s/combined_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  encryption_sgklm_playbook   = format("%s/%s/encryption_sgklm_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
  encryption_cluster_playbook = format("%s/%s/encryption_cluster_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "null_resource" "perform_encryption_prepare" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 ${local.encryption_sgklm_playbook}"
  }
}

resource "null_resource" "perform_encryption_storage" {
  count = (tobool(var.turn_on) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.storage_inventory_path} ${local.encryption_cluster_playbook} -e ansible_ssh_private_key_file=${local.encryption_private_key}"
  }
}

resource "null_resource" "perform_encryption_compute" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.compute_inventory_path} ${local.encryption_cluster_playbook}"
  }
}

resource "null_resource" "perform_encryption_combined" {
  count = (tobool(var.turn_on) == true && tobool(var.combined_cluster_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.combined_inventory_path} ${local.encryption_cluster_playbook}"
  }
}
