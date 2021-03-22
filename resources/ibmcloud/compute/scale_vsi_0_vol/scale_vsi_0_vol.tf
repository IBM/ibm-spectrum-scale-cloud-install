/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

variable "total_vsis" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zones" {}
variable "vsi_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_public_key" {}
variable "vsi_user_private_key_path" {}
variable "vsi_user_public_key_path" {}


data local_file "id_rsa_template" {
  filename   = pathexpand(var.vsi_user_private_key_path)
  depends_on = [var.vsi_user_private_key_path]
}

data local_file "id_rsa_pub_template" {
  filename   = pathexpand(var.vsi_user_public_key_path)
  depends_on = [var.vsi_user_public_key_path]
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
mkdir -p ~/.ssh/
echo "${data.local_file.id_rsa_template.content}" > ~/.ssh/id_rsa
echo "${data.local_file.id_rsa_pub_template.content}" > ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
EOF
}

resource "ibm_is_instance" "vsi" {
  count   = var.total_vsis
  name    = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = element(var.vsi_subnet_id, count.index)
    security_groups = var.vsi_security_group
  }

  vpc       = var.vpc_id
  zone      = element(var.zones, count.index)
  keys      = var.vsi_public_key
  user_data = data.template_file.metadata_startup_script.rendered
}

output "vsi_ids" {
  value = ibm_is_instance.vsi.*.id
}

output "vsi_ips" {
  value = ibm_is_instance.vsi[*].primary_network_interface[0]["primary_ipv4_address"]
}
