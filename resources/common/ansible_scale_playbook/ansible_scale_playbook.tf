/*
    Creates Ansible inventory and excutes ansible playbook to
    install IBM Spectrum Scale.
*/

variable "create_scale_cluster" {}
variable "avail_zones" {}
variable "filesystem_mountpoint" {}
variable "filesystem_block_size" {}
variable "ansible_scale_repo_clone_path" {}
variable "cloud_env" {}
variable "cloud_platform" {}
variable "compute_instances_by_ip" {}
variable "compute_instance_desc_map" {}
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
  tf_inv_path = "${path.module}/tf_inventory"
  ansible_inv_script_path = "${path.module}/prepare_scale_inv.py"
  ansible_scale_repo_path = format("%s/%s", var.ansible_scale_repo_clone_path, "ibm-spectrum-scale-install-infra")
}


resource "null_resource" "remove_existing_tf_inv" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -rf ${local.tf_inv_path}"
  }
}

resource "null_resource" "dump_tf_inventory" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /*
	Don't use EOT syntax here. It adds additions blackslashs and makes comparison fail.
    */
    command     = "echo cloud_env=${var.cloud_env} >> ${local.tf_inv_path}; echo cloud_platform=${var.cloud_platform} >> ${local.tf_inv_path}; echo create_scale_cluster=${var.create_scale_cluster} >> ${local.tf_inv_path}; echo filesystem_mountpoint=${var.filesystem_mountpoint} >> ${local.tf_inv_path}; echo filesystem_block_size=${var.filesystem_block_size} >> ${local.tf_inv_path}; echo availability_zones=${var.avail_zones} >> ${local.tf_inv_path}; echo compute_instances_by_ip=${var.compute_instances_by_ip} >> ${local.tf_inv_path}; echo compute_instance_desc_map=${var.compute_instance_desc_map} >> ${local.tf_inv_path}; if [[ ${var.storage_instance_ips_with_0_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_0_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_1_datadisks_device_names_map} != \"\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_1_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_2_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_2_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_3_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_3_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_4_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_4_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_5_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_5_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_6_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_6_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_7_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_7_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_8_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_8_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_9_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_9_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_10_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_10_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_11_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_11_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_12_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_12_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_13_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_13_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_14_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_14_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi; if [[ ${var.storage_instance_ips_with_15_datadisks_device_names_map} != \"[]\" ]]; then echo storage_instance_disk_map=\"${var.storage_instance_ips_with_15_datadisks_device_names_map}\" >> ${local.tf_inv_path}; fi;"
  }

  depends_on = [null_resource.remove_existing_tf_inv]
}

resource "null_resource" "gitclone_ibm_spectrum_scale_install_infra" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "if [ ! -d ${var.ansible_scale_repo_clone_path} ]; then mkdir -p ${var.ansible_scale_repo_clone_path}; cd ${var.ansible_scale_repo_clone_path}; git clone https://github.com/IBM/ibm-spectrum-scale-install-infra.git; fi;"
  }

  depends_on = [null_resource.dump_tf_inventory]
}

resource "null_resource" "prepare_ansible_inventory" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${local.tf_inv_path} --ansible_scale_repo_path ${local.ansible_scale_repo_path}"
  }

  depends_on = [null_resource.gitclone_ibm_spectrum_scale_install_infra]
}
