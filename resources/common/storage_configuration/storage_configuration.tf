/*
    Excutes ansible playbook to install IBM Spectrum Scale storage cluster.
*/

variable "clone_path" {}
variable "inventory_path" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key" {}
variable "meta_private_key" {}

locals {
  scripts_path             = replace(path.module, "storage_configuration", "scripts")
  ansible_inv_script_path  = format("%s/prepare_scale_inv.py", local.scripts_path)
  scale_tuning_config_path = format("%s/%s", var.clone_path, "storagesncparams.profile")
  storage_private_key      = format("%s/storage_key/id_rsa", var.clone_path) #tfsec:ignore:GEN002
}

resource "local_file" "create_scale_tuning_parameters" {
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
  sensitive_content = var.meta_private_key
  filename          = local.storage_private_key
  file_permission   = "0600"
}

resource "null_resource" "prepare_ansible_inventory" {
  count = (var.bastion_instance_public_ip != null || var.bastion_ssh_private_key != null) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${var.inventory_path} --install_infra_path ${var.clone_path} --instance_private_key ${local.storage_private_key} --bastion_ip ${var.bastion_instance_public_ip} --bastion_ssh_private_key ${var.bastion_ssh_private_key}"
  }
  depends_on = [local_file.create_scale_tuning_parameters, local_file.write_meta_private_key]
  triggers = {
    build = timestamp()
  }
}
