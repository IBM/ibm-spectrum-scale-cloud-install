/*
    Creates new Ansible vault to store SSH keys.

    Security Note: There will be fraction of seconds key file(s) will remain unencrypted.
*/

variable "tf_data_path" {}

variable "tf_ansible_key" {}

resource "null_resource" "check_tf_data_existence" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Create the directory only if it does not exist. */
    command = "if [[ ! -d ${var.tf_data_path} ]]; then mkdir -p ${var.tf_data_path}; fi"
  }
}

resource "null_resource" "check_tf_ansible_key_existence" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Initialize with default only if it does not exist. */
    command = "if [[ ! -f ${var.tf_ansible_key} ]]; then echo 'Spectrumscale!' > ${var.tf_ansible_key}; fi"
  }
  depends_on = [null_resource.check_tf_data_existence]
}

resource "null_resource" "remove_orphan_ssh_keys" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Remove orphan SSH keys, we need a full pair to operate. */
    command = "if [[ ! -f ${var.tf_data_path}/id_rsa ]] || [[ ! -f ${var.tf_data_path}/id_rsa.pub ]]; then rm -rf ${var.tf_data_path}/id_rsa*; fi"
  }
  depends_on = [null_resource.check_tf_data_existence]
}

resource "null_resource" "generate_local_ssh_key" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Don't overwrite of keys if both pub, private exists. */
    command = "if [[ ! -f ${var.tf_data_path}/id_rsa ]] || [[ ! -f ${var.tf_data_path}/id_rsa.pub ]]; then echo -e 'n\n' | ssh-keygen -q -b 4096 -t rsa -N \"\" -f ${var.tf_data_path}/id_rsa; fi"
  }
  depends_on = [null_resource.remove_orphan_ssh_keys]
}

resource "null_resource" "encrypt_pri_key_using_vault" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /*
       Note: Encrypt only if left plain.
             file type verification can used, but ansible-vault encrypted
             file returns "ASCII text" and provides no gaurantee that is 
             vault encrypted.
             
    */
    command = "if cat ${var.tf_data_path}/id_rsa | grep -q ANSIBLE_VAULT; then exit 0; else /usr/local/bin/ansible-vault encrypt ${var.tf_data_path}/id_rsa --vault-password-file=${var.tf_ansible_key}; fi"
  }
  depends_on = [null_resource.generate_local_ssh_key, null_resource.check_tf_ansible_key_existence]
}

resource "null_resource" "encrypt_pub_key_using_vault" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    /* Note: Encrypt only if left plain. */
    command = "if cat ${var.tf_data_path}/id_rsa.pub | grep -q ANSIBLE_VAULT; then exit 0; else /usr/local/bin/ansible-vault encrypt ${var.tf_data_path}/id_rsa.pub --vault-password-file=${var.tf_ansible_key}; fi"
  }
  depends_on = [null_resource.generate_local_ssh_key, null_resource.check_tf_ansible_key_existence]
}

output "vault_pri_key_path" {
  value      = format("%s/%s", var.tf_data_path, "id_rsa")
  depends_on = [null_resource.encrypt_pri_key_using_vault]
}

output "vault_pub_key_path" {
  value      = format("%s/%s", var.tf_data_path, "id_rsa.pub")
  depends_on = [null_resource.encrypt_pub_key_using_vault]
}
