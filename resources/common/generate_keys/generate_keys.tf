/*
    Creates new SSH key pair to enable passwordless SSH between scale nodes.
*/

variable "tf_data_path" {}

resource "null_resource" "check_tf_data_existence" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Create the directory only if it does not exist. */
    command = "if [[ ! -d ${var.tf_data_path} ]]; then mkdir -p ${var.tf_data_path}; fi"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "remove_orphan_ssh_keys" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Remove orphan SSH keys, we need a full pair to operate. */
    command = "if [[ ! -f ${var.tf_data_path}/id_rsa ]] || [[ ! -f ${var.tf_data_path}/id_rsa.pub ]]; then rm -rf ${var.tf_data_path}/id_rsa*; fi"
  }
  depends_on = [null_resource.check_tf_data_existence]
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "generate_local_ssh_key" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Don't overwrite of keys if both pub, private exists. */
    command = "if [[ ! -f ${var.tf_data_path}/id_rsa ]] || [[ ! -f ${var.tf_data_path}/id_rsa.pub ]]; then echo -e 'n\n' | ssh-keygen -q -b 4096 -t rsa -N \"\" -f ${var.tf_data_path}/id_rsa; fi"
  }
  depends_on = [null_resource.remove_orphan_ssh_keys]
  triggers = {
    always_run = "${timestamp()}"
  }
}

output "private_key_path" {
  value      = format("%s/%s", var.tf_data_path, "id_rsa")
  depends_on = [null_resource.generate_local_ssh_key]
}

output "public_key_path" {
  value      = format("%s/%s", var.tf_data_path, "id_rsa.pub")
  depends_on = [null_resource.generate_local_ssh_key]
}
