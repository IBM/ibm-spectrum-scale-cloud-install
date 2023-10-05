/*
    Ansible playbook to enable scnryption using ldap.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "clone_complete" {}
variable "create_scale_cluster" {}
variable "meta_private_key" {}
variable "scale_cluster_clustername" {}
variable "ldap_server" {}
variable "ldap_admin_password" {}
variable "ldap_user_name" {}
variable "ldap_user_password" {}
#variable "compute_cluster_create_complete" {}
#variable "storage_cluster_create_complete" {}
#variable "combined_cluster_create_complete" {}
#variable "remote_mount_create_complete" {}
#variable "compute_cluster_encryption" {}
#variable "storage_cluster_encryption" {}
#variable "combined_cluster_encryption" {}

locals {
  ldap_private_key        = format("%s/ldap_key/id_rsa", var.clone_path)
  ldap_server             = jsonencode(var.ldap_server)
  compute_inventory_path  = format("%s/%s/compute_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  storage_inventory_path  = format("%s/%s/storage_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  combined_inventory_path = format("%s/%s/combined_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  ldap_configure_playbook = format("%s/%s/ldap_configure_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
  ldap_cluster_playbook   = format("%s/%s/ldap_cluster_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "local_sensitive_file" "write_meta_private_key" {
  count           = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true) ? 1 : 0
  content         = var.meta_private_key
  filename        = local.ldap_private_key
  file_permission = "0600"
}

resource "null_resource" "perform_encryption_prepare" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 ${local.ldap_configure_playbook} -e scale_cluster_clustername=${var.scale_cluster_clustername} -e ansible_ssh_private_key_file=${local.ldap_private_key} -e ldap_admin_password=${var.ldap_admin_password} -e ldap_user_name=${var.ldap_user_name} -e ldap_user_password=${var.ldap_user_password} -e ldap_server_list=${local.ldap_server} && echo ${local.ldap_cluster_playbook} ${local.compute_inventory_path} ${local.storage_inventory_path} ${local.combined_inventory_path}"
  }
  depends_on = [local_sensitive_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}
