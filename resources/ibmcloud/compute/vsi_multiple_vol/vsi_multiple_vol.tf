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
    if grep -q "platform:el8" /etc/os-release
    then
        PACKAGE_MGR=dnf
        package_list="python38 kernel-devel-$(uname -r) kernel-headers-$(uname -r)"
    else
        PACKAGE_MGR=yum
        package_list="python3 kernel-devel-$(uname -r) kernel-headers-$(uname -r)"
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

if grep -q "8.6" /etc/os-release && [ "${var.enable_sec_interface_storage}" == true ]; then
    cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth1
    sed -i 's/eth0/eth1/g' /etc/sysconfig/network-scripts/ifcfg-eth1
    sed -i '/HWADD/d' /etc/sysconfig/network-scripts/ifcfg-eth1
    sed -i '/DOMAIN/d' /etc/sysconfig/network-scripts/ifcfg-eth1
    mac=$(ifconfig | grep ether | awk -F " " '{print$2}' | awk 'NR==2 {print}')
    sec_interface=$(nmcli -t con show --active | grep eth1 | cut -d ':' -f 1)
    echo "HWADDR=$mac" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    echo "NAME=\"$sec_interface\"" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    echo "DOMAIN=${var.dns_domain}" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    systemctl restart NetworkManager
    sudo nmcli connection up "$sec_interface"
fi
EOF
}

resource "ibm_is_instance" "itself" {
  for_each = {
    # This assigns a subnet-id to each of the instance
    # iteration.
    for idx, count_number in range(1, var.total_vsis + 1) : idx => {
      sequence_string = tostring(count_number)
      subnet_id       = element(var.vsi_subnet_id, idx)
      zone            = element(var.zones, idx)
    }
  }

  name    = format("%s-%s", var.vsi_name_prefix, each.value.sequence_string)
  image   = var.vsi_image_id
  profile = var.vsi_profile
  tags    = var.resource_tags

  primary_network_interface {
    subnet          = each.value.subnet_id
    security_groups = var.vsi_security_group
  }

  dynamic "network_interfaces" {
    for_each = var.enable_sec_interface_storage ? [1] : []
    content {
      name            = format("%s-%s-eth1", var.vsi_name_prefix, each.value.sequence_string)
      subnet          = each.value.subnet_id
      security_groups = var.vsi_security_group
    }
  }

  vpc            = var.vpc_id
  zone           = each.value.zone
  keys           = var.vsi_user_public_key
  resource_group = var.resource_group_id
  user_data      = data.template_file.metadata_startup_script.rendered

  boot_volume {
    name = format("%s-boot-%s", var.vsi_name_prefix, each.value.sequence_string)
  }
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

output "secondary_interface_names" {
  value = try(toset(flatten([for instance_details in ibm_is_instance.itself : instance_details[*].network_interfaces[*].name])), [])
  depends_on = [ibm_dns_resource_record.sec_interface_a_record, ibm_dns_resource_record.sec_interface_ptr_record]
}

output "secondary_interface_ips" {
  value = try(toset(flatten([for instance_details in ibm_is_instance.itself : instance_details[*].network_interfaces[*].primary_ip[*].address])), [])
  depends_on = [ibm_dns_resource_record.sec_interface_a_record, ibm_dns_resource_record.sec_interface_ptr_record]
}

output "instance_names_id_map" {
  value      = try({ for instance_details in ibm_is_instance.itself : "${instance_details.name}.${var.dns_domain}" => instance_details.id }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}

output "instance_private_name_ip_map" {
  value      = try({ for instance_details in ibm_is_instance.itself : instance_details.name => instance_details.primary_network_interface[0]["primary_ipv4_address"] }, {})
  depends_on = [ibm_dns_resource_record.a_itself, ibm_dns_resource_record.ptr_itself]
}