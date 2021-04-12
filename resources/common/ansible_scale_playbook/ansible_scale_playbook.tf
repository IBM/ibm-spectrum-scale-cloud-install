/*
    Creates Ansible inventory and excutes ansible playbook to
    install IBM Spectrum Scale.
*/

variable "tf_data_path" {}
variable "tf_input_json_root_path" {}
variable "tf_input_json_file_name" {}

variable "region" {}
variable "stack_name" {}
variable "bucket_name" {}
variable "notification_arn" {}

variable "create_scale_cluster" {}
variable "scale_version" {}
variable "generate_ansible_inv" {}
variable "avail_zones" {}
variable "filesystem_mountpoint" {}
variable "filesystem_block_size" {}
variable "scale_infra_repo_clone_path" {}
variable "generate_jumphost_ssh_config" {}
variable "cloud_platform" {}
variable "bastion_public_ip" {}
variable "instances_ssh_private_key" {}
variable "instances_ssh_user_name" {}
variable "private_subnet_cidr" {}
variable "compute_instances_by_ip" {}
variable "compute_instances_by_id" {}
variable "compute_instance_desc_map" {}
variable "compute_instance_desc_id" {}
variable "storage_instance_ids_with_0_datadisks" {}
variable "storage_instance_ids_with_1_datadisks" {}
variable "storage_instance_ids_with_2_datadisks" {}
variable "storage_instance_ids_with_3_datadisks" {}
variable "storage_instance_ids_with_4_datadisks" {}
variable "storage_instance_ids_with_5_datadisks" {}
variable "storage_instance_ids_with_6_datadisks" {}
variable "storage_instance_ids_with_7_datadisks" {}
variable "storage_instance_ids_with_8_datadisks" {}
variable "storage_instance_ids_with_9_datadisks" {}
variable "storage_instance_ids_with_10_datadisks" {}
variable "storage_instance_ids_with_11_datadisks" {}
variable "storage_instance_ids_with_12_datadisks" {}
variable "storage_instance_ids_with_13_datadisks" {}
variable "storage_instance_ids_with_14_datadisks" {}
variable "storage_instance_ids_with_15_datadisks" {}
variable "storage_instance_ips_with_0_datadisks_device_names_map" {}
variable "storage_instance_ips_with_1_datadisks_device_names_map" {}
variable "storage_instance_ips_with_2_datadisks_device_names_map" {}
variable "storage_instance_ips_with_3_datadisks_device_names_map" {}
variable "storage_instance_ips_with_4_datadisks_device_names_map" {}
variable "storage_instance_ips_with_5_datadisks_device_names_map" {}
variable "storage_instance_ips_with_6_datadisks_device_names_map" {}
variable "storage_instance_ips_with_7_datadisks_device_names_map" {}
variable "storage_instance_ips_with_8_datadisks_device_names_map" {}
variable "storage_instance_ips_with_9_datadisks_device_names_map" {}
variable "storage_instance_ips_with_10_datadisks_device_names_map" {}
variable "storage_instance_ips_with_11_datadisks_device_names_map" {}
variable "storage_instance_ips_with_12_datadisks_device_names_map" {}
variable "storage_instance_ips_with_13_datadisks_device_names_map" {}
variable "storage_instance_ips_with_14_datadisks_device_names_map" {}
variable "storage_instance_ips_with_15_datadisks_device_names_map" {}

locals {
  tf_inv_path                    = "${path.module}/tf_inventory"
  ansible_inv_script_path        = "${path.module}/prepare_scale_inv.py"
  instance_ssh_wait_script_path  = "${path.module}/wait_instance_ok_state.py"
  backup_to_backend_script_path  = "${path.module}/backup_to_backend.py"
  send_message_script_path       = "${path.module}/send_sns_notification.py"
  scale_tuning_param_path        = format("%s/%s", var.scale_infra_repo_clone_path, "scalesncparams.profile")
  scale_infra_path               = format("%s/%s", var.scale_infra_repo_clone_path, "ibm-spectrum-scale-install-infra")
  cloud_playbook_path            = format("%s/%s", local.scale_infra_path, "cloud_playbook.yml")
  instances_ssh_private_key_path = format("%s/%s", "/tmp/.schematics", "id_rsa")
  infra_complete_message         = "Provisioning infrastructure required for IBM Spectrum Scale deployment completed successfully."
  cluster_complete_message       = "IBM Spectrum Scale cluster creation completed successfully."
}

resource "null_resource" "send_infra_complete_message" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.send_message_script_path} --cloud_platform ${var.cloud_platform} --message \"${local.infra_complete_message}\" --topic_arn ${var.notification_arn} --region_name ${var.region}"
  }
  depends_on = [var.compute_instances_by_ip, var.storage_instance_ids_with_0_datadisks, var.storage_instance_ids_with_1_datadisks,
    var.storage_instance_ids_with_2_datadisks, var.storage_instance_ids_with_3_datadisks, var.storage_instance_ids_with_4_datadisks,
    var.storage_instance_ids_with_5_datadisks, var.storage_instance_ids_with_6_datadisks, var.storage_instance_ids_with_7_datadisks,
    var.storage_instance_ids_with_8_datadisks, var.storage_instance_ids_with_9_datadisks, var.storage_instance_ids_with_10_datadisks,
    var.storage_instance_ids_with_11_datadisks, var.storage_instance_ids_with_12_datadisks, var.storage_instance_ids_with_13_datadisks,
  var.storage_instance_ids_with_14_datadisks, var.storage_instance_ids_with_15_datadisks]
}

resource "null_resource" "remove_existing_tf_inv" {
  count = (var.create_scale_cluster == true || var.generate_ansible_inv == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -rf ${local.tf_inv_path}"
  }
}

resource "local_file" "dump_tf_inventory" {
  count      = (var.create_scale_cluster == true || var.generate_ansible_inv == true) ? 1 : 0
  content    = <<EOT
generate_jumphost_ssh_config=${var.generate_jumphost_ssh_config}
cloud_platform=${var.cloud_platform}
stack_name=${var.stack_name}
region=${var.region}
filesystem_mountpoint=${var.filesystem_mountpoint}
filesystem_block_size=${var.filesystem_block_size}
availability_zones=${var.avail_zones}
compute_instances_by_ip=${var.compute_instances_by_ip}
compute_instances_by_id=${var.compute_instances_by_id}
compute_instance_desc_map=${var.compute_instance_desc_map}
compute_instance_desc_id=${var.compute_instance_desc_id}
%{if var.storage_instance_ids_with_0_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_0_datadisks}%{endif}
%{if var.storage_instance_ids_with_1_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_1_datadisks}%{endif}
%{if var.storage_instance_ids_with_2_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_2_datadisks}%{endif}
%{if var.storage_instance_ids_with_3_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_3_datadisks}%{endif}
%{if var.storage_instance_ids_with_4_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_4_datadisks}%{endif}
%{if var.storage_instance_ids_with_5_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_5_datadisks}%{endif}
%{if var.storage_instance_ids_with_6_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_6_datadisks}%{endif}
%{if var.storage_instance_ids_with_7_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_7_datadisks}%{endif}
%{if var.storage_instance_ids_with_8_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_8_datadisks}%{endif}
%{if var.storage_instance_ids_with_9_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_9_datadisks}%{endif}
%{if var.storage_instance_ids_with_10_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_10_datadisks}%{endif}
%{if var.storage_instance_ids_with_11_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_11_datadisks}%{endif}
%{if var.storage_instance_ids_with_12_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_12_datadisks}%{endif}
%{if var.storage_instance_ids_with_13_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_13_datadisks}%{endif}
%{if var.storage_instance_ids_with_14_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_14_datadisks}%{endif}
%{if var.storage_instance_ids_with_15_datadisks != "[]"}storage_instances_by_id=${var.storage_instance_ids_with_15_datadisks}%{endif}
%{if var.storage_instance_ips_with_0_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_0_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_1_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_1_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_2_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_2_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_3_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_3_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_4_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_4_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_5_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_5_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_6_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_6_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_7_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_7_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_8_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_8_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_9_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_9_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_10_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_10_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_11_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_11_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_12_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_12_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_13_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_13_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_14_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_14_datadisks_device_names_map}%{endif}
%{if var.storage_instance_ips_with_15_datadisks_device_names_map != "[]"}storage_instance_disk_map=${var.storage_instance_ips_with_15_datadisks_device_names_map}%{endif}
EOT
  filename   = local.tf_inv_path
  depends_on = [null_resource.remove_existing_tf_inv]
}

resource "null_resource" "gitclone_ibm_spectrum_scale_install_infra" {
  count = (var.create_scale_cluster == true || var.generate_ansible_inv == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "if [ ! -d ${var.scale_infra_repo_clone_path} ]; then mkdir -p ${var.scale_infra_repo_clone_path}; cd ${var.scale_infra_repo_clone_path}; git clone https://github.com/IBM/ibm-spectrum-scale-install-infra.git; fi;"
  }
  depends_on = [local_file.dump_tf_inventory]
}

resource "null_resource" "prepare_ibm_spectrum_scale_install_infra" {
  count = (var.create_scale_cluster == true || var.generate_ansible_inv == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p ${local.scale_infra_path}/vars; cp ${local.scale_infra_path}/samples/playbook_cloud.yml ${local.scale_infra_path}/cloud_playbook.yml; cp ${local.scale_infra_path}/samples/set_json_variables.yml ${local.scale_infra_path}/set_json_variables.yml;"
  }
  depends_on = [null_resource.gitclone_ibm_spectrum_scale_install_infra]
}

resource "local_file" "create_scale_tuning_parameters" {
  count      = (var.create_scale_cluster == true || var.generate_ansible_inv == true) ? 1 : 0
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
  depends_on = [null_resource.gitclone_ibm_spectrum_scale_install_infra, null_resource.prepare_ibm_spectrum_scale_install_infra]
}

resource "null_resource" "prepare_ansible_inventory" {
  count = (var.create_scale_cluster == true || var.generate_ansible_inv == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${local.tf_inv_path} --ansible_scale_repo_path ${local.scale_infra_path} --ansible_ssh_private_key_file ${var.tf_data_path}/id_rsa --scale_tuning_profile_file ${local.scale_tuning_param_path}"
  }
  depends_on = [null_resource.gitclone_ibm_spectrum_scale_install_infra]
}

resource "local_file" "prepare_jumphost_config" {
  count             = (var.create_scale_cluster == true && var.generate_jumphost_ssh_config == true) ? 1 : 0
  sensitive_content = var.instances_ssh_private_key
  filename          = local.instances_ssh_private_key_path
  file_permission   = "0600"
  depends_on        = [null_resource.prepare_ansible_inventory]
}

resource "null_resource" "backup_ansible_inv" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.backup_to_backend_script_path} --local_file_path ${local.scale_infra_path}/vars/scale_clusterdefinition.json --bucket_name ${var.bucket_name} --obj_name ${var.stack_name}-scale_clusterdefinition.json --cloud_platform ${var.cloud_platform}"
  }
  depends_on = [null_resource.prepare_ansible_inventory]
}

resource "null_resource" "backup_tf_input_json" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.backup_to_backend_script_path} --local_file_path ${var.tf_input_json_root_path}/${var.tf_input_json_file_name} --bucket_name ${var.bucket_name} --obj_name ${var.stack_name}-${var.tf_input_json_file_name} --cloud_platform ${var.cloud_platform}"
  }
  depends_on = [null_resource.backup_ansible_inv]
}

resource "null_resource" "wait_for_instances_to_boot" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.instance_ssh_wait_script_path} --tf_inv_path ${local.tf_inv_path} --region_name ${var.region} --cloud_platform ${var.cloud_platform}"
  }
  depends_on = [null_resource.prepare_ansible_inventory]
}

resource "time_sleep" "wait_for_metadata_execution" {
  count = var.create_scale_cluster == true ? 1 : 0

  depends_on      = [null_resource.wait_for_instances_to_boot]
  create_duration = "60s"
}

resource "null_resource" "call_scale_install_playbook" {
  count = (var.create_scale_cluster == true && var.generate_jumphost_ssh_config == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook --private-key ${local.instances_ssh_private_key_path} -e \"ansible_python_interpreter=/usr/bin/python3\" --ssh-common-args \"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\\\"ssh -W %h:%p ${var.instances_ssh_user_name}@${var.bastion_public_ip} -i ${local.instances_ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\\\"\" ${local.cloud_playbook_path}"
  }
  depends_on = [time_sleep.wait_for_metadata_execution, local_file.create_scale_tuning_parameters]
}

resource "null_resource" "send_cluster_complete_message" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.send_message_script_path} --cloud_platform ${var.cloud_platform} --message \"${local.cluster_complete_message}\" --topic_arn ${var.notification_arn} --region_name ${var.region}"
  }
  depends_on = [null_resource.call_scale_install_playbook]
}
