/*
    Excutes ansible playbook to configure remote mount between IBM Spectrum Scale compute and storage cluster.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "compute_inventory_path" {}
variable "compute_gui_inventory_path" {}
variable "storage_inventory_path" {}
variable "storage_gui_inventory_path" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key" {}

locals {
  scripts_path              = replace(path.module, "remote_mount_configuration", "scripts")
  ansible_inv_script_path   = format("%s/prepare_remote_mount_inv.py", local.scripts_path)
  storage_private_key       = format("%s/storage_key/id_rsa", var.clone_path) #tfsec:ignore:GEN002
  remote_mnt_inventory_path = format("%s/%s/remote_mount_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  remote_mnt_playbook_path  = format("%s/%s/remote_mount_cloud_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "null_resource" "prepare_remote_mnt_inventory" {
  count = (tobool(var.turn_on) == true && (var.bastion_instance_public_ip != null || var.bastion_ssh_private_key != null)) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --compute_tf_inv_path ${var.compute_inventory_path} --compute_gui_inv_path ${var.compute_gui_inventory_path} --storage_tf_inv_path ${var.storage_inventory_path} --storage_gui_inv_path ${var.storage_gui_inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.storage_private_key} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key}"
  }
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "prepare_remote_mnt_inventory_wo_bastion" {
  count = (tobool(var.turn_on) == true && (var.bastion_instance_public_ip == null || var.bastion_ssh_private_key == null)) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --compute_tf_inv_path ${var.compute_inventory_path} --compute_gui_inv_path ${var.compute_gui_inventory_path} --storage_tf_inv_path ${var.storage_inventory_path} --storage_gui_inv_path ${var.storage_gui_inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.storage_private_key} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key}"
  }
  triggers = {
    build = timestamp()
  }
}

resource "time_sleep" "wait_for_gui_db_initializion" {
  count           = tobool(var.turn_on) == true ? 1 : 0
  create_duration = "180s"
  depends_on      = [null_resource.prepare_remote_mnt_inventory, null_resource.prepare_remote_mnt_inventory_wo_bastion]
}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.turn_on) == true && (var.bastion_instance_public_ip != null || var.bastion_ssh_private_key != null)) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${local.remote_mnt_inventory_path} ${local.remote_mnt_playbook_path}"
  }
  depends_on = [time_sleep.wait_for_gui_db_initializion, null_resource.prepare_remote_mnt_inventory, null_resource.prepare_remote_mnt_inventory_wo_bastion]
  triggers = {
    build = timestamp()
  }
}
