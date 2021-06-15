/*
    Excutes ansible playbook to install IBM Spectrum Scale compute cluster.
*/

variable "clone_path" {}
variable "inventory_path" {}
variable "bastion_instance_public_ip" {}
variable "bastion_ssh_private_key_content" {}

locals {
  scripts_path             = replace(path.module, "compute_configuration", "scripts")
  ansible_inv_script_path  = format("%s/prepare_scale_inv.py", local.scripts_path)
  scale_tuning_config_path = format("%s/%s", var.clone_path, "computesncparams.profile")
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

resource "null_resource" "prepare_ansible_inventory" {
  count = (var.bastion_instance_public_ip != null || var.bastion_ssh_private_key_content != null) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${var.inventory_path} --install_infra_path ${var.clone_path}"
  }
}
