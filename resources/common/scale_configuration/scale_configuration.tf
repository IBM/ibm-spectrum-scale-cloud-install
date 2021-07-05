/*
    Excutes ansible playbook to install IBM Spectrum Scale compute and storage cluster.
*/

variable "turn_on" {}
variable "clone_complete" {}
variable "write_inventory_complete" {}
variable "clone_path" {}
variable "inventory_path" {}
variable "using_packer_image" {}
variable "using_direct_connection" {}
variable "storage_cluster_gui_username" {}
variable "storage_cluster_gui_password" {}
variable "memory_size" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key" {}
variable "meta_private_key" {}
variable "scale_version" {}
variable "spectrumscale_rpms_path" {}

locals {
  scripts_path             = replace(path.module, "scale_configuration", "scripts")
  ansible_inv_script_path  = format("%s/prepare_scale_inv.py", local.scripts_path)
  wait_for_ssh_script_path = format("%s/wait_for_ssh_availability.py", local.scripts_path)
  scale_tuning_config_path = format("%s/%s", var.clone_path, "scalesncparams.profile")
  combined_private_key     = format("%s/storage_key/id_rsa", var.clone_path) #tfsec:ignore:GEN002
  combined_inventory_path  = format("%s/%s/combined_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  combined_playbook_path   = format("%s/%s/combined_cloud_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "local_file" "create_storage_tuning_parameters" {
  count    = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true) ? 1 : 0
  content  = <<EOT
%cluster:
 maxblocksize=16M
 restripeOnDiskFailure=yes
 unmountOnDiskFail=meta
 readReplicaPolicy=local
 workerThreads=128
 maxStatCache=0
 maxFilesToCache=64k
 ignorePrefetchLUNCount=yes
 prefetchaggressivenesswrite=0
 prefetchaggressivenessread=2
 autoload=yes
EOT
  filename = local.scale_tuning_config_path
}

resource "local_file" "write_meta_private_key" {
  count             = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true) ? 1 : 0
  sensitive_content = var.meta_private_key
  filename          = local.combined_private_key
  file_permission   = "0600"
}

resource "null_resource" "prepare_ansible_inventory" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true && tobool(var.using_direct_connection) == false) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${var.inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.combined_private_key} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key} --memory_size ${var.memory_size} --using_packer_image ${var.using_packer_image} --gui_username ${var.storage_cluster_gui_username} --gui_password ${var.storage_cluster_gui_password}"
  }
  depends_on = [local_file.create_storage_tuning_parameters, local_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "prepare_ansible_inventory_wo_bastion" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true && tobool(var.using_direct_connection) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${var.inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.combined_private_key} --memory_size ${var.memory_size} --using_packer_image ${var.using_packer_image} --gui_username ${var.storage_cluster_gui_username} --gui_password ${var.storage_cluster_gui_password}"
  }
  depends_on = [local_file.create_storage_tuning_parameters, local_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "wait_for_ssh_availability" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.wait_for_ssh_script_path} --tf_inv_path ${var.inventory_path} --cluster_type combined"
  }
  depends_on = [null_resource.prepare_ansible_inventory, null_resource.prepare_ansible_inventory_wo_bastion]
  triggers = {
    build = timestamp()
  }
}

resource "time_sleep" "wait_60_seconds" {
  count           = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true) ? 1 : 0
  create_duration = "60s"
  depends_on      = [null_resource.wait_for_ssh_availability]
}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.write_inventory_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${local.combined_inventory_path} ${local.combined_playbook_path} --extra-vars \"scale_version=${var.scale_version}\" --extra-vars \"scale_install_directory_pkg_path=${var.spectrumscale_rpms_path}\""
  }
  depends_on = [time_sleep.wait_60_seconds, null_resource.wait_for_ssh_availability, null_resource.prepare_ansible_inventory, null_resource.prepare_ansible_inventory_wo_bastion]
  triggers = {
    build = timestamp()
  }
}
