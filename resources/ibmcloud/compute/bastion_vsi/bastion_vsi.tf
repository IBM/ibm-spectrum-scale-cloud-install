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
variable "vsi_subnet_id" {}
variable "vpc_zone" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "resource_grp_id" {}

/*
data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
if grep -q "Red Hat\|CentOS" /etc/os-release
then
    USER=vpcuser
    yum --security update
elif grep -q "Ubuntu" /etc/os-release
then
    USER=ubuntu
fi
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
sed -i "s/#MaxSessions 10/MaxSessions 32/" /etc/ssh/sshd_config
sed -i "s/#MaxStartups 10:30:100/MaxStartups 30:30:100/" /etc/ssh/sshd_config
systemctl restart sshd.service
EOF
}
*/

locals {
  win_userdata = <<-EOUD
    #!/usr/bin/env bash
    if grep -q "Red Hat\|CentOS" /etc/os-release
    then
        USER=vpcuser
        yum --security update
    elif grep -q "Ubuntu" /etc/os-release
    then
        USER=ubuntu
    fi
    sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
    sed -i "s/#MaxSessions 10/MaxSessions 32/" /etc/ssh/sshd_config
    sed -i "s/#MaxStartups 10:30:100/MaxStartups 30:30:100/" /etc/ssh/sshd_config
    systemctl restart sshd.service
    EOF
      EOUD
}

resource "ibm_is_instance" "itself" {
  name    = var.vsi_name_prefix
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = var.vsi_subnet_id
    security_groups = var.vsi_security_group
  }

  vpc            = var.vpc_id
  zone           = var.vpc_zone
  resource_group = var.resource_grp_id
  keys           = var.vsi_user_public_key
  #user_data      = data.template_file.metadata_startup_script.rendered
  user_data = local.win_userdata

  boot_volume {
    name = format("%s-boot-vol", var.vsi_name_prefix)
  }
}

output "vsi_id" {
  value = ibm_is_instance.itself.id
}

output "vsi_private_ip" {
  value = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address
}

output "vsi_nw_id" {
  value = ibm_is_instance.itself.primary_network_interface[0].id
}
