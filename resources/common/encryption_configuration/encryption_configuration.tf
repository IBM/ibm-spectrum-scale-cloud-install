/*
    Ansible playbook to enable scnryption using SGKLM.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "clone_complete" {}
variable "meta_private_key" {}
variable "scale_encryption_servers" {}
variable "scale_encryption_admin_default_password" {}
variable "scale_encryption_admin_password" {}
variable "scale_encryption_admin_username" {}
variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "combined_cluster_create_complete" {}
variable "remote_mount_create_complete" {}
variable "compute_cluster_encryption" {}
variable "storage_cluster_encryption" {}
variable "combined_cluster_encryption" {}

locals {
  sgklm_private_key           = format("%s/sgklm_key/id_rsa", var.clone_path)
  scale_encryption_servers    = jsonencode(var.scale_encryption_servers)
  compute_inventory_path      = format("%s/%s/compute_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  storage_inventory_path      = format("%s/%s/storage_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  combined_inventory_path     = format("%s/%s/combined_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  encryption_sgklm_playbook   = format("%s/%s/encryption_sgklm_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
  encryption_cluster_playbook = format("%s/%s/encryption_cluster_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "local_sensitive_file" "write_meta_private_key" {
  count           = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true) ? 1 : 0
  content         = var.meta_private_key
  filename        = local.sgklm_private_key
  file_permission = "0600"
}

resource "null_resource" "perform_encryption_prepare" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 ${local.encryption_sgklm_playbook}  -e ansible_ssh_private_key_file=${local.sgklm_private_key} -e scale_encryption_admin_default_password=${var.scale_encryption_admin_default_password} -e scale_encryption_admin_password=${var.scale_encryption_admin_password} -e scale_encryption_admin_user=${var.scale_encryption_admin_username} -e scale_encryption_servers_list=${local.scale_encryption_servers}"
  }
}

resource "null_resource" "perform_encryption_storage" {
  count = (tobool(var.turn_on) == true && tobool(var.storage_cluster_encryption) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.storage_inventory_path} ${local.encryption_cluster_playbook}"
  }
}

resource "null_resource" "perform_encryption_compute" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_encryption) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.compute_inventory_path} ${local.encryption_cluster_playbook}"
  }
}

resource "null_resource" "perform_encryption_combined" {
  count = (tobool(var.turn_on) == true && tobool(var.combined_cluster_encryption) == true && tobool(var.combined_cluster_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.combined_inventory_path} ${local.encryption_cluster_playbook}"
  }
}
