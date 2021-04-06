/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

variable "total_vsis" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zones" {}
variable "dns_service_id" {}
variable "dns_zone_id" {}
variable "vsi_primary_subnet_id" {}
variable "vsi_secondary_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}


data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
mkdir -p ~/.ssh/
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" > ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
if grep -q "Red Hat" /etc/os-release
then
    if grep -q "platform:el8" /etc/os-release
    then
        PKG_MGR=dnf
    else
        PKG_MGR=yum
    fi
fi
$PKG_MGR install -y python3 unzip kernel-devel-$(uname -r) kernel-headers-$(uname -r)
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

  vpc       = var.vpc_id
  zone      = element(var.zones, count.index)
  keys      = var.vsi_user_public_key
  user_data = data.template_file.metadata_startup_script.rendered
}

resource "ibm_dns_resource_record" "a_1_nic_records" {
  count       = var.vsi_secondary_subnet_id == null ? var.total_vsis : 0
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  rdata       = element(ibm_is_instance.vsi_1_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  ttl         = 300
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

  network_interfaces {
    name              = "eth1"
    subnet            = element(var.vsi_secondary_subnet_id, count.index)
    security_groups   = var.vsi_security_group
    allow_ip_spoofing = false
  }

  vpc       = var.vpc_id
  zone      = element(var.zones, count.index)
  keys      = var.vsi_user_public_key
  user_data = data.template_file.metadata_startup_script.rendered
}

/* Only secondary address will be registered to DNS */
resource "ibm_dns_resource_record" "a_2_nic_records" {
  count       = var.vsi_secondary_subnet_id == null ? 0 : var.total_vsis
  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = "${var.vsi_name_prefix}-vsi-${count.index + 1}"
  rdata       = element(ibm_is_instance.vsi_2_nic[*].primary_network_interface[0]["primary_ipv4_address"], count.index)
  ttl         = 300
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
