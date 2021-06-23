/*
    Excutes ansible playbook to install IBM Spectrum Scale compute cluster.
*/

variable "turn_on" {}
variable "clone_path" {}
variable "inventory_path" {}
variable "memory_size" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key" {}
variable "meta_private_key" {}
variable "scale_version" {}
variable "spectrumscale_rpms_path" {}

locals {
  scripts_path             = replace(path.module, "compute_configuration", "scripts")
  ansible_inv_script_path  = format("%s/prepare_scale_inv.py", local.scripts_path)
  wait_for_ssh_script_path = format("%s/wait_for_ssh_availability.py", local.scripts_path)
  scale_tuning_config_path = format("%s/%s", var.clone_path, "computesncparams.profile")
  compute_private_key      = format("%s/compute_key/id_rsa", var.clone_path) #tfsec:ignore:GEN002
  compute_inventory_path   = format("%s/%s/compute_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  compute_playbook_path    = format("%s/%s/compute_cloud_playbook.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "local_file" "create_compute_tuning_parameters" {
  count    = tobool(var.turn_on) == true ? 1 : 0
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
  count             = tobool(var.turn_on) == true ? 1 : 0
  sensitive_content = var.meta_private_key
  filename          = local.compute_private_key
  file_permission   = "0600"
}

resource "null_resource" "prepare_ansible_inventory" {
  count = (tobool(var.turn_on) == true && (var.bastion_instance_public_ip != null || var.bastion_ssh_private_key != null)) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${var.inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.compute_private_key} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key} --memory_size ${var.memory_size}"
  }
  depends_on = [local_file.create_compute_tuning_parameters, local_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "prepare_ansible_inventory_wo_bastion" {
  count = (tobool(var.turn_on) == true && (var.bastion_instance_public_ip == null || var.bastion_ssh_private_key == null)) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${var.inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.compute_private_key} --memory_size ${var.memory_size}"
  }
  depends_on = [local_file.create_compute_tuning_parameters, local_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}

resource "null_resource" "wait_for_ssh_availability" {
  count = tobool(var.turn_on) == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.wait_for_ssh_script_path} --tf_inv_path ${var.inventory_path} --cluster_type compute"
  }
  depends_on = [null_resource.prepare_ansible_inventory, null_resource.prepare_ansible_inventory_wo_bastion]
  triggers = {
    build = timestamp()
  }
}

resource "time_sleep" "wait_60_seconds" {
  count           = tobool(var.turn_on) == true ? 1 : 0
  create_duration = "60s"
  depends_on      = [null_resource.wait_for_ssh_availability]
}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.turn_on) == true && (var.bastion_instance_public_ip != null || var.bastion_ssh_private_key != null)) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${local.compute_inventory_path} ${local.compute_playbook_path} --extra-vars \"scale_version=${var.scale_version}\" --extra-vars \"scale_install_directory_pkg_path=${var.spectrumscale_rpms_path}\""
  }
  depends_on = [time_sleep.wait_60_seconds]
  triggers = {
    build = timestamp()
  }
}
