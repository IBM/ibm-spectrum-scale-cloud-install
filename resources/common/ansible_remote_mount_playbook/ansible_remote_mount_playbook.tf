variable "filesystem_mountpoint" {}
variable "invoke_count" {}
variable "scale_infra_repo_clone_path" {}

locals {
  tf_inv_path                    = format("%s/%s", "/tmp/.schematics/IBM", "remote_mount_tf_inventory.json")
  scripts_path                  = replace(path.module, "ansible_remote_mount_playbook", "scripts")
  ansible_inv_script_path       = "${local.scripts_path}/prepare_remote_mount_inv.py"
  scale_infra_path               = format("%s/%s", var.scale_infra_repo_clone_path, "ibm-spectrum-scale-install-infra")
  remote_mount_def_path         = format("%s/%s/%s", local.scale_infra_path,  "vars", "remote_mount.json")
  compute_def_path              = format("%s/%s/%s", local.scale_infra_path,  "vars", "compute_clusterdefinition.json")
  storage_def_path              = format("%s/%s/%s", local.scale_infra_path,  "vars", "storage_clusterdefinition.json")
}

resource "local_file" "create_remote_mount" {
   count      = var.invoke_count == 1 ? 1 : 0
   content    = <<EOT
 {
    "client_gui_username": "admin",
    "client_gui_password": "admin001",
    "client_filesystem_name": "remotefs1",
    "client_remotemount_path": "/mnt",
    "storage_gui_username": "admin",
    "storage_gui_password": "admin001",
    "storage_filesystem_mountpoint": "${var.filesystem_mountpoint}"
 }
 EOT
  filename   = local.tf_inv_path
}

resource "null_resource" "prepare_ansible_inventory" {
  count = var.invoke_count == 1 ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ansible_inv_script_path} --tf_inv_path ${local.tf_inv_path} --remote_mount ${local.remote_mount_def_path} --computetf_inv_path ${local.compute_def_path} --storagetf_inv_path ${local.storage_def_path}"
  }
}
