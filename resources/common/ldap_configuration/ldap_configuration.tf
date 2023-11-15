/*
    Ansible playbook to enable scnryption using ldap.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "script_path" {}
variable "clone_complete" {}
variable "create_scale_cluster" {}
variable "meta_private_key" {}
variable "ldap_cluster_prefix" {}
variable "using_jumphost_connection" {}
variable "write_inventory_complete" {}
variable "ldap_basedns" {}
variable "ldap_server" {}
variable "ldap_admin_password" {}
variable "ldap_user_name" {}
variable "ldap_user_password" {}
variable "bastion_user" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key" {}

locals {
  ldap_private_key        = format("%s/ldap_key/id_rsa", var.clone_path)
  ldap_server             = jsonencode(var.ldap_server)
  ldap_inventory_path     = format("%s/%s/ldap_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  ldap_configure_playbook = format("%s/%s/ldap_configure_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "local_sensitive_file" "write_meta_private_key" {
  count           = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true) ? 1 : 0
  content         = var.meta_private_key
  filename        = local.ldap_private_key
  file_permission = "0600"
}

resource "null_resource" "prepare_ansible_inventory" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true && tobool(var.using_jumphost_connection) == false) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${var.script_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.ldap_private_key} --ldap_nodes ${local.ldap_server} --ldap_basedns ${var.ldap_basedns} --ldap_admin_password ${var.ldap_admin_password} --ldap_user_name ${var.ldap_user_name} --ldap_user_password ${var.ldap_user_password} --resource_prefix ${var.ldap_cluster_prefix}"
  }
  depends_on = [local_sensitive_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "prepare_ansible_inventory_using_jumphost_connection" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true && tobool(var.using_jumphost_connection) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${var.script_path} --install_infra_path ${var.clone_path} --bastion_user ${var.bastion_user} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key} --instance_private_key ${local.ldap_private_key} --ldap_nodes ${local.ldap_server} --ldap_basedns ${var.ldap_basedns} --ldap_admin_password ${var.ldap_admin_password} --ldap_user_name ${var.ldap_user_name} --ldap_user_password ${var.ldap_user_password} --resource_prefix ${var.ldap_cluster_prefix}"
  }
  depends_on = [local_sensitive_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "perform_ldap_prepare" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${local.ldap_inventory_path} ${local.ldap_configure_playbook} -e ldap_server=${local.ldap_server}"
  }
  depends_on = [local_sensitive_file.write_meta_private_key, null_resource.prepare_ansible_inventory, null_resource.prepare_ansible_inventory_using_jumphost_connection]
  triggers = {
    build = timestamp()
  }
}
