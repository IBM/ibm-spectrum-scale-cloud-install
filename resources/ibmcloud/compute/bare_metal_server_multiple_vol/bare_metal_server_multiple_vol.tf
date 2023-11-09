/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "total_vsis" {}
variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "zones" {}
variable "dns_service_id" {}
variable "dns_zone_id" {}
variable "dns_domain" {}
variable "vsi_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "resource_group_id" {}
variable "resource_tags" {}

data "ibm_is_bare_metal_server_profile" "itself" {
  name = var.vsi_profile
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
if grep -q "Red Hat" /etc/os-release
then
    USER=vpcuser
    yum install -y jq python3 kernel-devel-$(uname -r) kernel-headers-$(uname -r) firewalld numactl
    yum install -y make gcc-c++ elfutils-libelf-devel bind-utils iptables nfs-utils elfutils elfutils-devel
    yum install 'dnf-command(versionlock)' -y
    yum update --security -y
    yum versionlock add python38 kernel-devel-`uname -r` kernel-headers-`uname -r`
    yum versionlock add make gcc-c++ elfutils-libelf-devel bind-utils iptables nfs-utils elfutils elfutils-devel
    yum versionlock list
    echo 'export PATH=$PATH:/usr/lpp/mmfs/bin' >> /root/.bashrc
elif grep -q "Ubuntu" /etc/os-release
then
    USER=ubuntu
fi
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" ~/.ssh/authorized_keys
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "DOMAIN=\"${var.dns_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
echo "MTU=9000" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
sed -i -e "s#QUEUE_COUNT=3#QUEUE_COUNT=\`ethtool -l \$iface | echo \$(awk '\$1 ~ /Combined:/ {print \$2;exit}')\`#g" /var/lib/cloud/scripts/per-boot/iface-config
ethtool -L ens1 combined 16
chage -I -1 -m 0 -M 99999 -E -1 -W 14 vpcuser
systemctl restart NetworkManager
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
systemctl enable firewalld
EOF
}



resource "ibm_is_bare_metal_server" "itself" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      subnet_id       = element(var.vsi_subnet_id, idx)
      zone            = element(var.zones, idx)
    }
  }
  profile = var.vsi_profile
  name    = format("%s-%03s", var.vsi_name_prefix, each.value.sequence_string)
  image   = var.vsi_image_id
  zone    = each.value.zone
  keys    = var.vsi_user_public_key
  tags    = var.resource_tags
  primary_network_interface {
    subnet          = each.value.subnet_id
    security_groups = var.vsi_security_group
  }
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
  user_data      = data.template_file.metadata_startup_script.rendered
  timeouts {
    create = "90m"
  }
}


resource "ibm_dns_resource_record" "a_itself" {
  for_each = {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist([for name_details in ibm_is_bare_metal_server.itself : name_details.name]), idx)
      network_ip = element(tolist([for ip_details in ibm_is_bare_metal_server.itself : ip_details.primary_network_interface[0]["primary_ip"][0]["address"]]), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = each.value.name
  #rdata       = each.value.network_ip
  rdata = format("%s", each.value.network_ip)
  ttl   = 300
}

resource "ibm_dns_resource_record" "ptr_itself" {
  for_each = {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist([for name_details in ibm_is_bare_metal_server.itself : name_details.name]), idx)
      network_ip = element(tolist([for ip_details in ibm_is_bare_metal_server.itself : ip_details.primary_network_interface[0]["primary_ip"][0]["address"]]), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = each.value.network_ip
  rdata       = format("%s.%s", each.value.name, var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.a_itself]
}


output "instance_ids" {
  value      = try(toset([for instance_details in ibm_is_bare_metal_server.itself : instance_details.id]), [])
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_private_ips" {
  value      = try(toset([for instance_details in ibm_is_bare_metal_server.itself : instance_details.primary_network_interface[0]["primary_ip"][0]["address"]]), [])
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_ips_with_vol_mapping" {
  value = try({ for instance_details in ibm_is_bare_metal_server.itself : instance_details.name =>
  data.ibm_is_bare_metal_server_profile.itself.disks[1].quantity[0].value == 8 ? ["/dev/nvme0n1", "/dev/nvme1n1", "/dev/nvme2n1", "/dev/nvme3n1", "/dev/nvme4n1", "/dev/nvme5n1", "/dev/nvme6n1", "/dev/nvme7n1"] : ["/dev/nvme0n1", "/dev/nvme1n1", "/dev/nvme2n1", "/dev/nvme3n1", "/dev/nvme4n1", "/dev/nvme5n1", "/dev/nvme6n1", "/dev/nvme7n1", "/dev/nvme8n1", "/dev/nvme9n1", "/dev/nvme10n1", "/dev/nvme11n1", "/dev/nvme12n1", "/dev/nvme13n1", "/dev/nvme14n1", "/dev/nvme15n1"] }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_private_dns_ip_map" {
  value = try({ for instance_details in ibm_is_bare_metal_server.itself : instance_details.primary_network_interface[0]["primary_ip"][0]["address"] => instance_details.private_dns }, {})
}

output "storage_cluster_instance_name_id_map" {
  value      = try({ for instance_details in ibm_is_bare_metal_server.itself : "${instance_details.name}.${var.dns_domain}" => instance_details.id }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "storage_cluster_instance_name_ip_map" {
  value      = try({ for instance_details in ibm_is_bare_metal_server.itself : instance_details.name => instance_details.primary_network_interface[0]["primary_ip"][0]["address"] }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}
