/*
    Creates Ansible inventory and excutes ansible playbook to
    install IBM Spectrum Scale storage cluster.
*/

variable "region" {}
variable "stack_name" {}
variable "invoke_count" {}
variable "avail_zones" {}
variable "cloud_platform" {}
variable "tf_data_path" {}
variable "tf_input_json_root_path" {}
variable "tf_input_json_file_name" {}
variable "bucket_name" {}
variable "notification_arn" {}
variable "filesystem_mountpoint" {}
variable "filesystem_block_size" {}
variable "scale_infra_repo_clone_path" {}
variable "scale_install_directory_pkg_path" {}
variable "clone_complete" {}
variable "bastion_public_ip" {}
variable "bastion_os_flavor" {}
variable "scale_version" {}
variable "instances_ssh_private_key" {}
variable "compute_instance_desc_map" {}
variable "compute_instance_desc_id" {}
variable "storage_instances_by_id" {}
variable "storage_instance_disk_map" {}
variable "storage_gui_username" {}
variable "storage_gui_password" {}

locals {
  tf_inv_path                     = format("%s/%s", "/tmp/.schematics/IBM", "storage_tf_inventory.json")
  scripts_path                    = replace(path.module, "ansible_storage_playbook", "scripts")
  ansible_inv_script_path         = "${local.scripts_path}/prepare_scale_inv.py"
  instance_ssh_wait_script_path   = "${local.scripts_path}/wait_instance_ok_state.py"
  backup_to_backend_script_path   = "${local.scripts_path}/backup_to_backend.py"
  send_message_script_path        = "${local.scripts_path}/send_sns_notification.py"
  scale_tuning_param_path         = format("%s/%s", var.scale_infra_repo_clone_path, "storagesncparams.profile")
  scale_infra_path                = format("%s/%s", var.scale_infra_repo_clone_path, "ibm-spectrum-scale-install-infra")
  scale_cluster_def_path          = format("%s/%s/%s", local.scale_infra_path, "vars", "storage_clusterdefinition.json")
  cloud_playbook_path             = format("%s/%s", local.scale_infra_path, "cloud_playbook.yml")
  instances_ssh_private_key_path  = format("%s/%s", var.tf_data_path, "id_rsa")
  storage_instances_root_key_path = format("%s/%s/%s", var.tf_data_path, "storage", "id_rsa")
  infra_complete_message          = "Provisioning infrastructure required for IBM Spectrum Scale deployment completed successfully."
  cluster_complete_message        = "IBM Spectrum Scale cluster creation completed successfully."
  bastion_user                    = var.cloud_platform == "IBMCloud" ? (length(regexall("ubuntu", var.bastion_os_flavor)) > 0 ? "ubuntu" : "vpcuser") : "ec2-user"
}

resource "null_resource" "send_infra_complete_message" {
  count = (var.cloud_platform == "IBMCloud" && var.invoke_count == 1) ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.send_message_script_path} --cloud_platform ${var.cloud_platform} --message \"${local.infra_complete_message}\" --topic_arn ${var.notification_arn} --region_name ${var.region}"
  }
  depends_on = [var.compute_instance_desc_id, var.storage_instances_by_id, var.storage_instance_disk_map]
}

resource "null_resource" "remove_existing_tf_inv" {
  count = var.invoke_count == 1 ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -rf ${local.tf_inv_path}"
  }
}

resource "local_file" "dump_strg_tf_inventory" {
  count      = (var.invoke_count == 1 && var.clone_complete == true) ? 1 : 0
  content    = <<EOT
{
    "cloud_platform": "${var.cloud_platform}",
    "stack_name": "${var.stack_name}",
    "region": "${var.region}",
    "filesystem_mountpoint": "${var.filesystem_mountpoint}",
    "filesystem_block_size": "${var.filesystem_block_size}",
    "availability_zones": ${var.avail_zones},
    "compute_instances_by_ip": {},
    "compute_instances_by_id": {},
    "compute_instance_desc_map": ${var.compute_instance_desc_map},
    "compute_instance_desc_id": ${var.compute_instance_desc_id},
    "storage_instances_by_id": ${var.storage_instances_by_id},
    "storage_instance_disk_map": ${var.storage_instance_disk_map},
    "storage_gui_username": "${var.storage_gui_username}",
    "storage_gui_password": "${var.storage_gui_password}"
}
EOT
  filename   = local.tf_inv_path
  depends_on = [null_resource.remove_existing_tf_inv]
}

resource "null_resource" "prepare_ibm_spectrum_scale_install_infra" {
  count = (var.invoke_count == 1 && var.clone_complete == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p ${local.scale_infra_path}/vars; cp ${local.scale_infra_path}/samples/playbook_cloud.yml ${local.scale_infra_path}/cloud_playbook.yml; cp ${local.scale_infra_path}/samples/set_json_variables.yml ${local.scale_infra_path}/set_json_variables.yml;"
  }
}

resource "local_file" "create_scale_tuning_parameters" {
  count      = var.invoke_count == 1 ? 1 : 0
  content    = <<EOT
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
  filename   = local.scale_tuning_param_path
  depends_on = [null_resource.prepare_ibm_spectrum_scale_install_infra]
}

resource "null_resource" "prepare_ansible_inventory" {
  count = var.invoke_count == 1 ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${local.tf_inv_path} --scale_cluster_def_path ${local.scale_cluster_def_path} --scale_tuning_profile_file ${local.scale_tuning_param_path}"
  }
  depends_on = [local_file.dump_strg_tf_inventory]
}

resource "local_file" "prepare_jumphost_config" {
  count             = var.invoke_count == 1 ? 1 : 0
  sensitive_content = var.instances_ssh_private_key
  filename          = local.instances_ssh_private_key_path
  file_permission   = "0600"
  depends_on        = [null_resource.prepare_ansible_inventory]
}

resource "null_resource" "backup_ansible_inv" {
  count = (var.cloud_platform == "IBMCloud" && var.invoke_count == 1) ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.backup_to_backend_script_path} --local_file_path ${local.scale_infra_path}/vars/scale_clusterdefinition.json --bucket_name ${var.bucket_name} --obj_name ${var.stack_name}-scale_clusterdefinition.json --cloud_platform ${var.cloud_platform}"
  }
  depends_on = [null_resource.prepare_ansible_inventory]
}

resource "null_resource" "backup_tf_input_json" {
  count = (var.cloud_platform == "IBMCloud" && var.invoke_count == 1) ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.backup_to_backend_script_path} --local_file_path ${var.tf_input_json_root_path}/${var.tf_input_json_file_name} --bucket_name ${var.bucket_name} --obj_name ${var.stack_name}-${var.tf_input_json_file_name} --cloud_platform ${var.cloud_platform}"
  }
  depends_on = [null_resource.backup_ansible_inv]
}

resource "null_resource" "wait_for_instances_to_boot" {
  count = var.invoke_count == 1 ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.instance_ssh_wait_script_path} --tf_inv_path ${local.tf_inv_path} --region_name ${var.region} --cloud_platform ${var.cloud_platform}"
  }
  depends_on = [null_resource.prepare_ansible_inventory]
}

resource "time_sleep" "wait_for_metadata_execution" {
  count           = var.invoke_count == 1 ? 1 : 0
  depends_on      = [null_resource.wait_for_instances_to_boot]
  create_duration = "60s"
}

resource "null_resource" "call_scale_install_playbook" {
  count = var.invoke_count == 1 ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook --private-key ${local.storage_instances_root_key_path} -e \"ansible_python_interpreter=/usr/bin/python3\" -e \"scale_version=${var.scale_version}\" -e \"scale_cluster_definition_path=${local.scale_cluster_def_path}\" -e \"scale_install_directory_pkg_path=${var.scale_install_directory_pkg_path}\" --ssh-common-args \"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\\\"ssh -W %h:%p ${local.bastion_user}@${var.bastion_public_ip} -i ${local.instances_ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\\\"\" ${local.cloud_playbook_path}"
  }
  depends_on = [time_sleep.wait_for_metadata_execution, local_file.create_scale_tuning_parameters]
}

resource "null_resource" "send_cluster_complete_message" {
  count = (var.cloud_platform == "IBMCloud" && var.invoke_count == 1) ? 0 : 1
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.send_message_script_path} --cloud_platform ${var.cloud_platform} --message \"${local.cluster_complete_message}\" --topic_arn ${var.notification_arn} --region_name ${var.region}"
  }
  depends_on = [null_resource.call_scale_install_playbook]
}
