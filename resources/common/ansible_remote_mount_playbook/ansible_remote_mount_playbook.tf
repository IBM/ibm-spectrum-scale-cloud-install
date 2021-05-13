/*
     Creates Ansible inventory and excutes ansible playbook to
     remote mount filesystem from storage cluster to compute cluster.
*/

variable "invoke_count" {}
variable "clone_complete" {}
variable "cloud_platform" {}
variable "tf_data_path" {}
variable "bastion_os_flavor" {}
variable "bastion_public_ip" {}
variable "scale_infra_repo_clone_path" {}

locals {
  scripts_path                    = replace(path.module, "ansible_remote_mount_playbook", "scripts")
  scale_infra_path                = format("%s/%s", var.scale_infra_repo_clone_path, "ibm-spectrum-scale-install-infra")
  remote_mount_def_path           = format("%s/%s/%s", local.scale_infra_path, "vars", "remote_mount.json")
  compute_tf_inv_path             = format("%s/%s", "/tmp/.schematics/IBM", "compute_tf_inventory.json")
  storage_tf_inv_path             = format("%s/%s", "/tmp/.schematics/IBM", "storage_tf_inventory.json")
  ansible_inv_script_path         = format("%s/%s", local.scripts_path, "prepare_remote_mount_inv.py")
  instances_ssh_private_key_path  = format("%s/%s", var.tf_data_path, "id_rsa")
  storage_instances_root_key_path = format("%s/%s/%s", var.tf_data_path, "storage", "id_rsa")
  rmt_mnt_playbook_path           = format("%s/%s", local.scale_infra_path, "playbook_cloud_remote_mount.yml")
  bastion_user                    = var.cloud_platform == "IBMCloud" ? (length(regexall("ubuntu", var.bastion_os_flavor)) > 0 ? "ubuntu" : "vpcuser") : "ec2-user"
}

resource "null_resource" "prepare_remote_mount_ansible_inv" {
  count = (var.invoke_count == 1 && var.clone_complete) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --compute_tf_inv_path ${local.compute_tf_inv_path} --storage_tf_inv_path ${local.storage_tf_inv_path} --remote_mount_def_path ${local.remote_mount_def_path}"
  }
}

resource "time_sleep" "wait_for_gui_db_initializion" {
  count           = (var.invoke_count == 1 && var.clone_complete) ? 1 : 0
  depends_on      = [null_resource.prepare_remote_mount_ansible_inv]
  create_duration = "90s"
}

resource "null_resource" "call_remote_mnt_playbook" {
  count = (var.invoke_count == 1 && var.clone_complete) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook --private-key ${local.storage_instances_root_key_path} -e \"scale_cluster_definition_path=${local.remote_mount_def_path}\" --ssh-common-args \"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\\\"ssh -W %h:%p ${local.bastion_user}@${var.bastion_public_ip} -i ${local.instances_ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\\\"\" ${local.rmt_mnt_playbook_path}"
  }
  depends_on = [time_sleep.wait_for_gui_db_initializion]
}
