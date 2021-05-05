variable "invoke_count" {}
variable "scale_infra_repo_clone_path" {}

locals {
  scripts_path          = replace(path.module, "ansible_remote_mount_playbook", "scripts")
  scale_infra_path      = format("%s/%s", var.scale_infra_repo_clone_path, "ibm-spectrum-scale-install-infra")
  remote_mount_def_path = format("%s/%s/%s", local.scale_infra_path, "vars", "remote_mount.json")
  compute_tf_inv_path   = format("%s/%s", "/tmp/.schematics/IBM", "compute_tf_inventory.json")
  storage_tf_inv_path   = format("%s/%s", "/tmp/.schematics/IBM", "storage_tf_inventory.json")
  ansible_inv_script_path         = "${local.scripts_path}/prepare_remote_mount_inv.py"
}

resource "null_resource" "prepare_remote_mount_ansible_inv" {
  count = var.invoke_count == 1 ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --compute_tf_inv_path ${local.compute_tf_inv_path} --storage_tf_inv_path ${local.storage_tf_inv_path} --remote_mount_def_path ${local.remote_mount_def_path}"
  }
}
