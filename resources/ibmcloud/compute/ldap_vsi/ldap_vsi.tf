/*
    Creates a Bastion/Jump Host Instance.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zones" {}
variable "vsi_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "resource_group_id" {}
variable "resource_tags" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "ldap_basedns" {}
variable "ldap_admin_password" {}


data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
USER=ubuntu
basedns="${var.ldap_basedns}"  # Replace with your variable containing "testing.com"

basedomain=$(echo "$basedns" | awk -F'.' '{print $1}')
rootdomain=$(echo "$basedns" | awk -F'.' '{print $2}')

apt-get update -y
export DEBIAN_FRONTEND='non-interactive'
echo -e "slapd slapd/root_password password ${var.ldap_admin_password}" |debconf-set-selections
echo -e "slapd slapd/root_password_again password ${var.ldap_admin_password}" |debconf-set-selections
apt-get install -y slapd ldap-utils

echo -e "slapd slapd/internal/adminpw password ${var.ldap_admin_password}" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password ${var.ldap_admin_password}" |debconf-set-selections
echo -e "slapd slapd/password2 password ${var.ldap_admin_password}" |debconf-set-selections
echo -e "slapd slapd/password1 password ${var.ldap_admin_password}" |debconf-set-selections
echo -e "slapd slapd/domain string ${var.ldap_basedns}" |debconf-set-selections
echo -e "slapd shared/organization string ${var.ldap_basedns}" |debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections
dpkg-reconfigure slapd
echo "BASE   dc=$basedomain,dc=$rootdomain" >> /etc/ldap/ldap.conf
echo "URI    ldap://localhost" >> /etc/ldap/ldap.conf
systemctl restart slapd

sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
sed -i "s/#MaxSessions 10/MaxSessions 32/" /etc/ssh/sshd_config
sed -i "s/#MaxStartups 10:30:100/MaxStartups 30:30:100/" /etc/ssh/sshd_config
systemctl restart sshd.service

#Copying SSH for passwordless authentication
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
EOF
}

resource "ibm_is_instance" "itself" {
  name    = var.vsi_name_prefix
  image   = var.vsi_image_id
  profile = var.vsi_profile
  tags    = var.resource_tags

  primary_network_interface {
    subnet          = var.vsi_subnet_id
    security_groups = var.vsi_security_group
  }

  vpc            = var.vpc_id
  zone           = var.zones
  resource_group = var.resource_group_id
  keys           = var.vsi_user_public_key
  user_data      = data.template_file.metadata_startup_script.rendered

  boot_volume {
    name = format("%s-boot-vol", var.vsi_name_prefix)
  }
}

output "vsi_id" {
  value = ibm_is_instance.itself.id
}

output "vsi_private_ip" {
  value = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
}

output "vsi_nw_id" {
  value = ibm_is_instance.itself.primary_network_interface[0].id
}
