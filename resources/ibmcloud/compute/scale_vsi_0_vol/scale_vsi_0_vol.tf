/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

variable "total_vsis" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zones" {}
variable "dns_service_id" {}
variable "dns_zone_id" {}
variable "dns_domain" {}
variable "vsi_primary_subnet_id" {}
variable "vsi_secondary_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "vsi_tuning_file_path" {}
variable "resource_grp_id" {}


data "local_file" "tuned_config" {
  filename = var.vsi_tuning_file_path
}

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
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" ~/.ssh/authorized_keys
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
mkdir -p "/usr/lib/tuned/virtual-gpfs-guest"
echo "${data.local_file.tuned_config.content}" > "/usr/lib/tuned/virtual-gpfs-guest/tuned.conf"
tuned-adm profile virtual-gpfs-guest
echo "DOMAIN=\"${var.dns_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
systemctl restart NetworkManager
$PKG_MGR install -y python3 kernel-devel-$(uname -r) kernel-headers-$(uname -r)
systemctl stop firewalld
firewall-offline-cmd --zone=public --add-port=1191/tcp
firewall-offline-cmd --zone=public --add-port=60000-61000/tcp
firewall-offline-cmd --zone=public --add-port=47080/tcp
firewall-offline-cmd --zone=public --add-port=47080/udp
firewall-offline-cmd --zone=public --add-port=47443/tcp
firewall-offline-cmd --zone=public --add-port=47443/udp
firewall-offline-cmd --zone=public --add-port=4444/tcp
firewall-offline-cmd --zone=public --add-port=4444/udp
firewall-offline-cmd --zone=public --add-port=4739/udp
firewall-offline-cmd --zone=public --add-port=4739/tcp
firewall-offline-cmd --zone=public --add-port=9084/tcp
firewall-offline-cmd --zone=public --add-port=9085/tcp
firewall-offline-cmd --zone=public --add-service=http
firewall-offline-cmd --zone=public --add-service=https
systemctl start firewalld
EOF
}

resource "ibm_is_instance" "vsi_1_nic" {
  count   = var.vsi_secondary_subnet_id == null ? var.total_vsis : 0
  name    = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = element(var.vsi_primary_subnet_id, count.index)
    security_groups = var.vsi_security_group
  }

  vpc            = var.vpc_id
  zone           = element(var.zones, count.index)
  resource_group = var.resource_grp_id
  keys           = var.vsi_user_public_key
  user_data      = data.template_file.metadata_startup_script.rendered

  boot_volume {
    name = "${var.vsi_name_prefix}-vsi-${count.index + 1}-vol"
  }
}

resource "ibm_dns_resource_record" "a_1_nic_records" {
  count       = var.vsi_secondary_subnet_id == null ? var.total_vsis : 0
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = element(ibm_is_instance.vsi_1_nic.*.name, count.index)
  rdata       = element(ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  ttl         = 300
}

resource "ibm_dns_resource_record" "ptr_1_nic_records" {
  count       = var.vsi_secondary_subnet_id == null ? var.total_vsis : 0
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = element(ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  rdata       = format("%s.%s", element(ibm_is_instance.vsi_1_nic.*.name, count.index), var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a_1_nic_records]
}

resource "ibm_is_instance" "vsi_2_nic" {
  count   = var.vsi_secondary_subnet_id == null ? 0 : var.total_vsis
  name    = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = element(var.vsi_primary_subnet_id, count.index)
    security_groups = var.vsi_security_group
  }

  boot_volume {
    name = "${var.vsi_name_prefix}-vsi-${count.index + 1}-vol"
  }

  network_interfaces {
    name              = "eth1"
    subnet            = element(var.vsi_secondary_subnet_id, count.index)
    security_groups   = var.vsi_security_group
    allow_ip_spoofing = false
  }

  vpc            = var.vpc_id
  zone           = element(var.zones, count.index)
  keys           = var.vsi_user_public_key
  user_data      = data.template_file.metadata_startup_script.rendered
  resource_group = var.resource_grp_id
}

/* Only secondary address will be registered to DNS */
resource "ibm_dns_resource_record" "a_2_nic_records" {
  count       = var.vsi_secondary_subnet_id == null ? 0 : var.total_vsis
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = element(ibm_is_instance.vsi_2_nic.*.name, count.index)
  rdata       = element(ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  ttl         = 300
}

resource "ibm_dns_resource_record" "ptr_2_nic_records" {
  count       = var.vsi_secondary_subnet_id == null ? 0 : var.total_vsis
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = element(ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  rdata       = format("%s.%s", element(ibm_is_instance.vsi_2_nic.*.name, count.index), var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a_2_nic_records]
}

output "vsi_ids" {
  value = var.vsi_secondary_subnet_id == null ? ibm_is_instance.vsi_1_nic.*.id : ibm_is_instance.vsi_2_nic.*.id
}

output "vsi_primary_ips" {
  value = var.vsi_secondary_subnet_id == null ? ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"] : ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"]
}

output "vsi_secondary_ips" {
  value = var.vsi_secondary_subnet_id == null ? null : ibm_is_instance.vsi_2_nic[*].network_interfaces[0]["primary_ipv4_address"]
}
