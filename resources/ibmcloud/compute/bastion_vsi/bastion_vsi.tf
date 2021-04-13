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
variable "vsi_user_public_key" {}


data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
if grep -q "Red Hat" /etc/os-release
then
    USER=vpcuser
    if grep -q "platform:el8" /etc/os-release
    then
        PKG_MGR=dnf
    else
        PKG_MGR=yum
    fi
elif grep -q "Ubuntu" /etc/os-release
then
    USER=ubuntu
    PKG_MGR=apt-get
fi
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
$PKG_MGR install -y python3 unzip kernel-devel-$(uname -r) kernel-headers-$(uname -r)
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

  boot_volume {
    name = "${var.vsi_name_prefix}-vsi-${count.index + 1}-vol"
  }

  vpc       = var.vpc_id
  zone      = element(var.zones, count.index)
  keys      = var.vsi_user_public_key
  user_data = data.template_file.metadata_startup_script.rendered
}

output "vsi_ids" {
  value = ibm_is_instance.vsi.*.id
}

output "vsi_nw_ids" {
  value = ibm_is_instance.vsi[*].primary_network_interface[0]
}
