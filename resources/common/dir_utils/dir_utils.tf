/*
    Directory operations.
*/

variable "ansible_path" {}

resource "null_resource" "create_ansible_path" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p ${var.ansible_path}"
  }
}

output "clone_complete" {
  value      = true
  depends_on = [null_resource.create_ansible_path]
}
