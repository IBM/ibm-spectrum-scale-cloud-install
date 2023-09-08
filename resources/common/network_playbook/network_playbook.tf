/*
    Excutes network playbook.
*/

variable "turn_on" {}
variable "clone_complete" {}
variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "create_scale_cluster" {}
variable "inventory_path" {}
variable "network_playbook_path" {}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.turn_on) == true && tobool(var.clone_complete) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.create_scale_cluster) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-playbook -i ${var.inventory_path} ${var.network_playbook_path}"
  }
  triggers = {
    build = timestamp()
  }
}
