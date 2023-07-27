/*
    Excutes ansible playbook to configure mrot on IBM Spectrum Scale compute and storage cluster.
*/

variable "compute_inventory_path" {}
variable "storage_inventory_path" {}
variable "playbook_path" {}
variable "turn_on" {}
variable "compute_cluster_create_complete" {}
variable "storage_cluster_create_complete" {}
variable "remote_mount_create_complete" {}

resource "null_resource" "perform_scale_deployment" {
  count = (tobool(var.turn_on) == true && tobool(var.compute_cluster_create_complete) == true && tobool(var.storage_cluster_create_complete) == true && tobool(var.remote_mount_create_complete) == true) ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "/usr/local/bin/ansible-playbook -f 32 -i ${var.compute_inventory_path} -i ${var.storage_inventory_path} ${var.playbook_path}"
  }
}