/*
    Excutes network playbook.
*/

variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "remote_mount_create_complete" {}
variable "inventory_path" {}
variable "network_playbook_path" {}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${var.inventory_path} ${var.network_playbook_path}"
  }
  triggers = {
    build = timestamp()
  }
}
