/*
    Excutes network playbook.
*/

variable "clone_path" {}
variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "remote_mount_create_complete" {}

locals {
  inventory_path        = format("%s/%s/compute_inventory.ini", var.clone_path, "ibm-spectrum-scale-install-infra")
  network_playbook_path = format("%s/%s/samples/playbook_cloud_network_config.yaml", var.clone_path, "ibm-spectrum-scale-install-infra")
}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${local.inventory_path} ${local.network_playbook_path}"
  }
  triggers = {
    build = timestamp()
  }
}
