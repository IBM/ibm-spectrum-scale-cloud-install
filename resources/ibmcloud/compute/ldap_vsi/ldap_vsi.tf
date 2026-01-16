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

data "template_file" "metadata_startup_script" {
  template = <<-EOF
#!/usr/bin/env bash

USER=ubuntu
logfile="/tmp/user_data.log"

# Configure SSH settings
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo 'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
sed -i "s/#MaxSessions 10/MaxSessions 32/" /etc/ssh/sshd_config
sed -i "s/#MaxStartups 10:30:100/MaxStartups 30:30:100/" /etc/ssh/sshd_config
systemctl restart sshd.service
echo "Restarted SSHD service" >> $logfile

# Set up passwordless SSH authentication
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "Keys added to the server for passwordless authentication !!" >> $logfile
EOF
}

# Resource definition for the VSI instance
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