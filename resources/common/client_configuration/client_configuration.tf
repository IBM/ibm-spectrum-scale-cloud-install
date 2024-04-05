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
variable "using_jumphost_connection" {}
variable "client_inventory_path" {}
variable "bastion_user" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key" {}
variable "client_meta_private_key" {}
variable "write_inventory_complete" {}
variable "enable_ldap" {}
variable "ldap_basedns" {}
variable "ldap_server" {}
variable "ldap_admin_password" {}

locals {
  client_inventory_path   = format("%s/%s/client_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  client_playbook         = format("%s/%s/client_cloud_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
  scripts_path            = replace(path.module, "client_configuration", "scripts")
  ansible_inv_script_path = format("%s/prepare_client_inv.py", local.scripts_path)
  client_private_key      = format("%s/client_key/id_rsa", var.clone_path)
}

resource "local_sensitive_file" "write_client_meta_private_key" {
  count           = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true) ? 1 : 0
  content         = var.client_meta_private_key
  filename        = local.client_private_key
  file_permission = "0600"
}

resource "null_resource" "prepare_client_inventory_using_jumphost_connection" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.using_jumphost_connection) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --client_tf_inv_path ${var.client_inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.client_private_key} --bastion_user ${var.bastion_user} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key} --enable_ldap ${var.enable_ldap} --ldap_basedns ${var.ldap_basedns} --ldap_server ${var.ldap_server} --ldap_admin_password ${var.ldap_admin_password}"
  }
  triggers = {
    build = timestamp()
  }
  depends_on = [resource.local_sensitive_file.write_client_meta_private_key]
}

resource "null_resource" "prepare_client_inventory" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.using_jumphost_connection) == false && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --client_tf_inv_path ${var.client_inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.client_private_key} --enable_ldap ${var.enable_ldap} --ldap_basedns ${var.ldap_basedns} --ldap_server ${var.ldap_server} --ldap_admin_password ${var.ldap_admin_password}"
  }
  triggers = {
    build = timestamp()
  }
  depends_on = [resource.local_sensitive_file.write_client_meta_private_key]
}

resource "null_resource" "perform_client_configuration" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${local.client_inventory_path} ${local.client_playbook}"
  }
  triggers = {
    build = timestamp()
  }
  depends_on = [resource.local_sensitive_file.write_client_meta_private_key, resource.null_resource.prepare_client_inventory_using_jumphost_connection, resource.null_resource.prepare_client_inventory]
}

output "client_create_complete" {
  value      = true
  depends_on = [resource.local_sensitive_file.write_client_meta_private_key, resource.null_resource.prepare_client_inventory_using_jumphost_connection, resource.null_resource.prepare_client_inventory, resource.null_resource.perform_client_configuration]
}