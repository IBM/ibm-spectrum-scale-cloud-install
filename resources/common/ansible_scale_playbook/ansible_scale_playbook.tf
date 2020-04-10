/*
    Creates Ansible inventory and excutes ansible playbook to
    install IBM Spectrum Scale.
*/

variable "tf_data_path" {
  type        = string
  default     = "~/tf_data_path"
  description = "Data path to be used by terraform for storing ssh keys."
}

variable "tf_ansible_data" {
  type        = string
  default     = "~/tf_data_path/keyring"
  description = "Ansible vault keyring file path."
}

variable "region" {}
variable "create_scale_cluster" {}
variable "avail_zones" {}
variable "filesystem_mountpoint" {}
variable "filesystem_block_size" {}
variable "ansible_scale_repo_clone_path" {}
variable "cloud_env" {}
variable "cloud_platform" {}
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
  tf_inv_path                   = "${path.module}/tf_inventory"
  ansible_inv_script_path       = "${path.module}/prepare_scale_inv.py"
  instance_ssh_wait_script_path = "${path.module}/wait_instance_ok_state.py"
  ansible_scale_repo_path       = format("%s/%s", var.ansible_scale_repo_clone_path, "ibm-spectrum-scale-install-infra")
  cloud_playbook_path           = format("%s/%s", local.ansible_scale_repo_path, "cloud_playbook.yml")
}

resource "null_resource" "check_tf_data_existence" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "if [[ -d ${var.tf_data_path} ]] && [[ -f ${var.tf_ansible_data} ]]; then exit 0; else exit 1; fi"
  }
}

resource "null_resource" "remove_existing_tf_inv" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -rf ${local.tf_inv_path}"
  }
}

resource "null_resource" "dump_tf_inventory" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /*
	Don't use EOT syntax here. It adds additions blackslashs and makes comparison fail.
    */
    command = "echo cloud_env=${var.cloud_env} >> ${local.tf_inv_path}; echo cloud_platform=${var.cloud_platform} >> ${local.tf_inv_path}; echo filesystem_mountpoint=${var.filesystem_mountpoint} >> ${local.tf_inv_path}; echo filesystem_block_size=${var.filesystem_block_size} >> ${local.tf_inv_path}; echo availability_zones=${var.avail_zones} >> ${local.tf_inv_path}; echo compute_instances_by_ip=${var.compute_instances_by_ip} >> ${local.tf_inv_path}; echo compute_instances_by_id=${var.compute_instances_by_id} >> ${local.tf_inv_path}; echo compute_instance_desc_map=${var.compute_instance_desc_map} >> ${local.tf_inv_path}; echo compute_instance_desc_id=${var.compute_instance_desc_id} >> ${local.tf_inv_path}; if [[ ${var.storage_instance_ids_with_0_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_0_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_1_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_1_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_2_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_2_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_3_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_3_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_4_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_4_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_5_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_5_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_6_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_6_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_7_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_7_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_8_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_8_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_9_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_9_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_10_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_10_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_11_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_11_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_12_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_12_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_13_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_13_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_14_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_14_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ids_with_15_datadisks} != \"[]\" ]]; then echo storage_instances_by_id=\"${var.storage_instance_ids_with_15_datadisks}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_0_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_0_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_1_datadisks_device_names_map} != \"\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_1_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_2_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_2_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_3_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_3_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_4_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_4_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_5_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_5_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_6_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_6_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_7_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_7_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_8_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_8_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_9_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_9_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_10_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_10_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_11_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_11_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_12_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_12_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_13_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_13_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_14_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_14_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_15_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_15_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi;"
  }

  depends_on = [null_resource.remove_existing_tf_inv]
}

resource "null_resource" "gitclone_ibm_spectrum_scale_install_infra" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "if [ ! -d ${var.ansible_scale_repo_clone_path} ]; then mkdir -p ${var.ansible_scale_repo_clone_path}; cd ${var.ansible_scale_repo_clone_path}; git clone https://github.com/IBM/ibm-spectrum-scale-install-infra.git; fi;"
  }

  depends_on = [null_resource.dump_tf_inventory]
}

resource "null_resource" "prepare_ansible_inventory" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${local.tf_inv_path} --ansible_scale_repo_path ${local.ansible_scale_repo_path} --ansible_ssh_private_key_file ${var.tf_data_path}/id_rsa"
  }

  depends_on = [null_resource.gitclone_ibm_spectrum_scale_install_infra]
}

resource "null_resource" "decrypt_ansible_ssh_private_key" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-vault decrypt --vault-password-file ${var.tf_ansible_data} ${var.tf_data_path}/id_rsa"
  }

  depends_on = [null_resource.prepare_ansible_inventory]
}

resource "null_resource" "wait_for_instances_to_boot" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.instance_ssh_wait_script_path} --tf_inv_path ${local.tf_inv_path} --region_name ${var.region}"
  }

  depends_on = [null_resource.decrypt_ansible_ssh_private_key]
}

resource "null_resource" "call_scale_install_playbook" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook ${local.cloud_playbook_path}"
  }

  depends_on = [null_resource.wait_for_instances_to_boot]
}

resource "null_resource" "encrypt_ansible_ssh_private_key" {
  count = var.create_scale_cluster == true ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-vault encrypt --vault-password-file ${var.tf_ansible_data} ${var.tf_data_path}/id_rsa"
  }

  depends_on = [null_resource.call_scale_install_playbook]
}
