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
variable "enable_sec_interface_storage" {}
variable "protocol_domain" {}
variable "protocol_subnet_id" {}
variable "enable_protocol" {}
variable "vpc_region" {}

locals {
  protocol_subnet_id = var.enable_protocol == true ? var.protocol_subnet_id[0] : ""
}

data "ibm_is_instance_profile" "itself" {
  name = var.vsi_profile
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash

exec > >(tee /var/log/ibm_spectrumscale_user-data.log)
if grep -q "Red Hat" /etc/os-release
then
    USER=vpcuser
    REQ_PKG_INSTALLED=0
    if grep -q "platform:el9" /etc/os-release
    then
        PACKAGE_MGR=dnf
        package_list="python3 kernel-devel-$(uname -r) kernel-headers-$(uname -r) firewalld numactl make gcc-c++ elfutils-libelf-devel bind-utils iptables-nft nfs-utils elfutils elfutils-devel python3-dnf-plugin-versionlock"
    elif grep -q "platform:el8" /etc/os-release
    then
        PACKAGE_MGR=dnf
        package_list="python38 kernel-devel-$(uname -r) kernel-headers-$(uname -r) firewalld numactl jq make gcc-c++ elfutils-libelf-devel bind-utils iptables nfs-utils elfutils elfutils-devel python3-dnf-plugin-versionlock"
    else
        PACKAGE_MGR=yum
        package_list="python3 kernel-devel-$(uname -r) kernel-headers-$(uname -r) firewalld numactl make gcc-c++ elfutils-libelf-devel bind-utils iptables nfs-utils elfutils elfutils-devel yum-plugin-versionlock"
    fi

    RETRY_LIMIT=5
    retry_count=0
    all_pkg_installed=1

    while [[ $all_pkg_installed -ne 0 && $retry_count -lt $RETRY_LIMIT ]]
    do
        # Install all required packages
        echo "INFO: Attempting to install packages"
        $PACKAGE_MGR install -y $package_list

        # Check to ensure packages are installed
        pkg_installed=0
        for pkg in $package_list
        do
            pkg_query=$($PACKAGE_MGR list installed $pkg)
            pkg_installed=$(($? + $pkg_installed))
        done
        if [[ $pkg_installed -ne 0 ]]
        then
            # The minimum required packages have not been installed.
            echo "WARN: Required packages not installed. Sleeping for 60 seconds and retrying..."
            touch /var/log/scale-rerun-package-install
            echo "INFO: Cleaning and repopulating repository data"
            $PACKAGE_MGR clean all
            $PACKAGE_MGR makecache
            sleep 60
        else
            all_pkg_installed=0
        fi
        retry_count=$(( $retry_count+1 ))
    done

elif grep -q "Ubuntu" /etc/os-release
then
    USER=ubuntu
fi

yum update --security -y
yum versionlock $package_list
yum versionlock list
echo 'export PATH=$PATH:/usr/lpp/mmfs/bin' >> /root/.bashrc

sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" ~/.ssh/authorized_keys
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
if [[ "${data.ibm_is_instance_profile.itself.disks[0].quantity[0].type}" == "fixed" ]]
then
    echo "###########################################################################################" >> /etc/motd
    echo "# You have logged in to Instance storage virtual server.                                  #" >> /etc/motd
    echo "#   - Instance storage is temporary storage that's available only while your virtual      #" >> /etc/motd
    echo "#     server is running.                                                                  #" >> /etc/motd
    echo "#   - Data on the drive is unrecoverable after instance shutdown, disruptive maintenance, #" >> /etc/motd
    echo "#     or hardware failure.                                                                #" >> /etc/motd
    echo "#                                                                                         #" >> /etc/motd
    echo "# Refer: https://cloud.ibm.com/docs/vpc?topic=vpc-instance-storage                        #" >> /etc/motd
    echo "###########################################################################################" >> /etc/motd
fi
echo "DOMAIN=\"${var.dns_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
echo "MTU=9000" >> "/etc/sysconfig/network-scripts/ifcfg-eth0"
chage -I -1 -m 0 -M 99999 -E -1 -W 14 vpcuser
systemctl restart NetworkManager
systemctl stop firewalld
firewall-offline-cmd --zone=public --add-port=1191/tcp
firewall-offline-cmd --zone=public --add-port=4444/tcp
firewall-offline-cmd --zone=public --add-port=4444/udp
firewall-offline-cmd --zone=public --add-port=4739/udp
firewall-offline-cmd --zone=public --add-port=4739/tcp
firewall-offline-cmd --zone=public --add-port=9084/tcp
firewall-offline-cmd --zone=public --add-port=9085/tcp
firewall-offline-cmd --zone=public --add-service=http
firewall-offline-cmd --zone=public --add-service=https
firewall-offline-cmd --zone=public --add-port=2049/tcp
firewall-offline-cmd --zone=public --add-port=2049/udp
firewall-offline-cmd --zone=public --add-port=111/tcp
firewall-offline-cmd --zone=public --add-port=111/udp
firewall-offline-cmd --zone=public --add-port=30000-61000/tcp
firewall-offline-cmd --zone=public --add-port=30000-61000/udp
systemctl start firewalld
systemctl enable firewalld

if [ "${var.enable_sec_interface_storage}" == true ]; then
    sec_interface=$(nmcli -t con show --active | grep eth1 | cut -d ':' -f 1)
    nmcli conn del "$sec_interface"
    nmcli con add type ethernet con-name eth1 ifname eth1
    echo "DOMAIN=\"${var.dns_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth1"
    echo "MTU=9000" >> "/etc/sysconfig/network-scripts/ifcfg-eth1"
    systemctl restart NetworkManager
fi
if [ "${var.enable_protocol}" == true ]; then
    sec_interface=$(nmcli -t con show --active | grep eth1 | cut -d ':' -f 1)
    nmcli conn del "$sec_interface"
    nmcli con add type ethernet con-name eth1 ifname eth1
    echo "DOMAIN=\"${var.protocol_domain}\"" >> "/etc/sysconfig/network-scripts/ifcfg-eth1"
    echo "MTU=9000" >> "/etc/sysconfig/network-scripts/ifcfg-eth1"
    systemctl restart NetworkManager
    ###### TODO: Fix Me ######
    echo 'export IC_REGION=${var.vpc_region}' >> /root/.bashrc
    echo 'export IC_SUBNET=${local.protocol_subnet_id}' >> /root/.bashrc
    echo 'export IC_RG=${var.resource_group_id}' >> /root/.bashrc
fi
EOF
}

resource "ibm_is_virtual_network_interface" "vni" {
  for_each = var.enable_sec_interface_storage == false && var.enable_protocol == false ? {} : {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string    = tostring(count_number)
      subnet_id          = var.enable_sec_interface_storage == true ? element(var.vsi_subnet_id, idx) : ""
      protocol_subnet_id = var.enable_protocol == true ? element(var.protocol_subnet_id, idx) : ""
    }
  }
  name                      = format("%s-%03s-eth1", var.vsi_name_prefix, each.value.sequence_string)
  allow_ip_spoofing         = false
  enable_infrastructure_nat = true
  subnet                    = var.enable_sec_interface_storage ? each.value.subnet_id : each.value.protocol_subnet_id
  resource_group            = var.resource_group_id
  security_groups           = var.vsi_security_group
  primary_ip {
    auto_delete = true
  }
}

resource "ibm_is_instance" "itself" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      subnet_id       = element(var.vsi_subnet_id, idx)
      zone            = element(var.zones, idx)
      vni_id          = var.enable_sec_interface_storage == false && var.enable_protocol == false ? "" : element(tolist([for vni_id in ibm_is_virtual_network_interface.vni : vni_id.id]), idx)
    }
  }

  name    = format("%s-%03s", var.vsi_name_prefix, each.value.sequence_string)
  image   = var.vsi_image_id
  profile = var.vsi_profile
  tags    = var.resource_tags

  primary_network_attachment {
    name = format("%s-%03s-eth0", var.vsi_name_prefix, each.value.sequence_string)
    virtual_network_interface {
      name                      = format("%s-%03s-eth0", var.vsi_name_prefix, each.value.sequence_string)
      allow_ip_spoofing         = false
      auto_delete               = true
      enable_infrastructure_nat = true
      subnet                    = each.value.subnet_id
      security_groups           = var.vsi_security_group
    }
  }

  dynamic "network_attachments" {
    for_each = var.enable_sec_interface_storage == true || var.enable_protocol == true ? [1] : []
    content {
      name = format("%s-%03s-eth1", var.vsi_name_prefix, each.value.sequence_string)
      virtual_network_interface {
        id = each.value.vni_id
      }
    }
  }

  vpc            = var.vpc_id
  zone           = each.value.zone
  keys           = var.vsi_user_public_key
  resource_group = var.resource_group_id
  user_data      = data.template_file.metadata_startup_script.rendered

  boot_volume {
    name = format("%s-boot-%03s", var.vsi_name_prefix, each.value.sequence_string)
  }
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
  depends_on      = [ibm_is_instance.itself]
}

# A Record for primary network Interface

resource "ibm_dns_resource_record" "a_itself" {
  for_each = {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist([for name_details in ibm_is_instance.itself : name_details.name]), idx)
      network_ip = element(tolist([for ip_details in ibm_is_instance.itself : ip_details.primary_network_interface[0]["primary_ipv4_address"]]), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = each.value.name
  rdata       = each.value.network_ip
  ttl         = 300
  depends_on  = [ibm_is_instance.itself]
}

# PTR Record for primary network Interface

resource "ibm_dns_resource_record" "ptr_itself" {
  for_each = {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist([for name_details in ibm_is_instance.itself : name_details.name]), idx)
      network_ip = element(tolist([for ip_details in ibm_is_instance.itself : ip_details.primary_network_interface[0]["primary_ipv4_address"]]), idx)
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

# A Record for Secondary network Interface

resource "ibm_dns_resource_record" "sec_interface_a_record" {
  for_each = var.enable_sec_interface_storage == false ? {} : {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist(flatten([for instance_details in ibm_is_instance.itself : instance_details[*].network_interfaces[*].name])), idx)
      network_ip = element(tolist(flatten([for instance_details in ibm_is_instance.itself : instance_details[*].network_interfaces[*].primary_ip[*].address])), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = each.value.name
  rdata       = each.value.network_ip
  ttl         = 300
  depends_on  = [ibm_is_instance.itself]
}

# PTR Record for Secondary network Interface

resource "ibm_dns_resource_record" "sec_interface_ptr_record" {
  for_each = var.enable_sec_interface_storage == false ? {} : {
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      name       = element(tolist(flatten([for instance_details in ibm_is_instance.itself : instance_details[*].network_interfaces[*].name])), idx)
      network_ip = element(tolist(flatten([for instance_details in ibm_is_instance.itself : instance_details[*].network_interfaces[*].primary_ip[*].address])), idx)
    }
  }

  instance_id = var.dns_service_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = each.value.network_ip
  rdata       = format("%s.%s", each.value.name, var.dns_domain)
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.sec_interface_a_record]
}

output "instance_ids" {
  value      = try(toset([for instance_details in ibm_is_instance.itself : instance_details.id]), [])
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_private_ips" {
  value      = try(toset([for instance_details in ibm_is_instance.itself : instance_details.primary_network_interface[0]["primary_ipv4_address"]]), [])
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_ips_with_vol_mapping" {
  value = try({ for instance_details in ibm_is_instance.itself : instance_details.name =>
  data.ibm_is_instance_profile.itself.disks[0].quantity[0].value == 1 ? ["/dev/vdb"] : ["/dev/vdb", "/dev/vdc"] }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_private_dns_ip_map" {
  value = try({ for instance_details in ibm_is_instance.itself : instance_details.primary_network_interface[0]["primary_ipv4_address"] => instance_details.private_dns }, {})
}

output "instance_name_id_map" {
  value      = try({ for instance_details in ibm_is_instance.itself : "${instance_details.name}.${var.dns_domain}" => instance_details.id }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_name_ip_map" {
  value      = try({ for instance_details in ibm_is_instance.itself : instance_details.name => instance_details.primary_network_interface[0]["primary_ipv4_address"] }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "secondary_interface_name_ip_map" {
  value      = try({ for instance_details in ibm_is_instance.itself : instance_details.network_interfaces[0]["name"] => instance_details.network_interfaces[0]["primary_ipv4_address"] }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}
