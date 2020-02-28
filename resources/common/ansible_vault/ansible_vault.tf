/*
    Creates new Ansible vault to store SSH keys.

    Security Note: There will be fraction of seconds key file(s) will remain unencrypted.
*/

variable "tf_data_path" {
    type    = string
    default = "~/tf_data_path"
    description = "Data path to be used by terraform for storing ssh keys."
}

variable "tf_ansible_data" {
    type    = string
    default = "~/tf_data_path/keyring"
    description = "Ansible vault keyring file path."
}

resource "null_resource" "check_tf_data_existence" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command     = "if [[ -d ${var.tf_data_path} ]] && [[ -f ${var.tf_ansible_data} ]]; then exit 0; else exit 1; fi"
    }
}

resource "null_resource" "generate_local_ssh_key" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        /* Note: This will overwrite of keys if both pub, private exists. */
        command     = "echo -e 'y\n' | ssh-keygen -q -b 4096 -t rsa -N \"\" -f ${var.tf_data_path}/id_rsa"
        on_failure  = fail
    }
    depends_on = [null_resource.check_tf_data_existence]
}

data local_file "id_rsa_content"  {
    filename = pathexpand("${var.tf_data_path}/id_rsa")
    depends_on = [null_resource.generate_local_ssh_key]
}

data local_file "id_rsa_pub_content"  {
    filename = pathexpand("${var.tf_data_path}/id_rsa.pub")
    depends_on = [null_resource.generate_local_ssh_key]
}

resource "null_resource" "id_rsa_create_vault" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command     = "/usr/local/bin/ansible-vault encrypt ${var.tf_data_path}/id_rsa --vault-password-file=${var.tf_ansible_data}; /usr/local/bin/ansible-vault encrypt ${var.tf_data_path}/id_rsa.pub --vault-password-file=${var.tf_ansible_data}"
        /* Note: Returns '1' in case of error. */
        on_failure  = fail
    }

    depends_on = [null_resource.check_tf_data_existence, null_resource.generate_local_ssh_key,
        data.local_file.id_rsa_content, data.local_file.id_rsa_pub_content]
}

output "id_rsa_content" {
    value = data.local_file.id_rsa_content.content
}

output "id_rsa_pub_content" {
    value = data.local_file.id_rsa_pub_content.content
}
