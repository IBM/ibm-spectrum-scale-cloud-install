/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

variable "total_vsis" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zone" {}
variable "dns_service_id" {}
variable "dns_zone_id" {}
variable "dns_domain" {}
variable "vsi_primary_subnet_id" {}
variable "vsi_secondary_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_volumes" {}
variable "vsi_data_volumes_count" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "vsi_tuning_file_path" {}
variable "resource_grp_id" {}


locals {
  instance_storage_1volume_profiles = ["bx2d-2x8", "bx2d-4x16", "bx2d-8x32", "bx2d-16x64",
    "cx2d-2x4", "cx2d-4x8", "cx2d-8x16", "cx2d-16x32",
  "mx2d-2x16", "mx2d-4x32", "mx2d-8x64", "mx2d-16x128"]
  instance_storage_2volume_profiles = ["cx2d-32x64", "cx2d-48x96", "cx2d-64x128", "cx2d-96x192", "cx2d-128x256",
    "bx2d-32x128", "bx2d-48x192", "bx2d-64x256", "bx2d-96x384", "bx2d-128x512",
  "mx2d-32x256", "mx2d-48x384", "mx2d-64x512", "mx2d-96x768", "mx2d-128x1024"]
}

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
systemctl start firewalld
EOF
}

resource "ibm_is_instance" "vsi_1_nic" {
  count   = var.vsi_secondary_subnet_id == false ? var.total_vsis : 0
  name    = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = var.vsi_primary_subnet_id
    security_groups = var.vsi_security_group
  }

  boot_volume {
    name = "${var.vsi_name_prefix}-vsi-${count.index + 1}-vol"
  }

  vpc       = var.vpc_id
  zone      = var.zone
  keys      = var.vsi_user_public_key
  user_data = data.template_file.metadata_startup_script.rendered

  volumes = var.vsi_data_volumes_count == 0 ? null : element(chunklist(var.vsi_volumes, var.vsi_data_volumes_count), count.index)
}

resource "ibm_dns_resource_record" "a_1_nic_records" {
  count       = var.vsi_secondary_subnet_id == false ? var.total_vsis : 0
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  rdata       = element(ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  ttl         = 300
}

resource "ibm_dns_resource_record" "ptr_1_nic_records" {
  count       = var.vsi_secondary_subnet_id == false ? var.total_vsis : 0
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = element(ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  rdata       = format("%s.%s", element(ibm_is_instance.vsi_1_nic.*.name, count.index), var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a_1_nic_records]
}

resource "ibm_is_instance" "vsi_2_nic" {
  count   = var.vsi_secondary_subnet_id == false ? 0 : var.total_vsis
  name    = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  image   = var.vsi_image_id
  profile = var.vsi_profile

  primary_network_interface {
    subnet            = var.vsi_primary_subnet_id
    security_groups   = var.vsi_security_group
    allow_ip_spoofing = false
  }

  boot_volume {
    name = "${var.vsi_name_prefix}-vsi-${count.index + 1}-vol"
  }

  network_interfaces {
    name              = "eth1"
    subnet            = var.vsi_secondary_subnet_id
    security_groups   = var.vsi_security_group
    allow_ip_spoofing = false
  }

  vpc            = var.vpc_id
  zone           = var.zone
  keys           = var.vsi_user_public_key
  resource_group = var.resource_grp_id
  user_data      = data.template_file.metadata_startup_script.rendered

  volumes = var.vsi_data_volumes_count == 0 ? null : element(chunklist(var.vsi_volumes, var.vsi_data_volumes_count), count.index)
}

resource "ibm_dns_resource_record" "a_2_nic_records" {
  count       = var.vsi_secondary_subnet_id == false ? 0 : var.total_vsis
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  rdata       = element(ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  ttl         = 300
}

resource "ibm_dns_resource_record" "ptr_2_nic_records" {
  count       = var.vsi_secondary_subnet_id == false ? 0 : var.total_vsis
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = element(ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  rdata       = format("%s.%s", element(ibm_is_instance.vsi_2_nic.*.name, count.index), var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a_2_nic_records]
}

output "vsi_ids" {
  value = var.vsi_secondary_subnet_id == false ? ibm_is_instance.vsi_1_nic.*.id : ibm_is_instance.vsi_2_nic.*.id
}

output "vsi_primary_ips" {
  value = var.vsi_secondary_subnet_id == false ? ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"] : ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"]
}

output "vsi_secondary_ips" {
  value = var.vsi_secondary_subnet_id == false ? null : ibm_is_instance.vsi_2_nic[*].network_interfaces[0]["primary_ipv4_address"]
}

output "vsi_instance_storage_volumes" {
  value = var.vsi_data_volumes_count == 0 ? contains(local.instance_storage_1volume_profiles, var.vsi_profile) == true ? ["/dev/vdb"] : ["/dev/vdb", "/dev/vdc"] : null
}
