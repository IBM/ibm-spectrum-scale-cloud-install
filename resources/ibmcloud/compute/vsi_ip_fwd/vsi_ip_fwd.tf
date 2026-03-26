/*
     Creates IBMCloud Virtual Server instance(s) with a static route
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "ami_id" {}
variable "subnet_id" {}
variable "dns_domain" {}
variable "forward_dns_zone" {}
variable "forward_dns_zone_id" {}
variable "ces_ipaddress" {}
variable "instance_type" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "name_prefix" {}
variable "placement_group" {}
variable "root_device_kms_key_instance_id" {}
variable "root_device_kms_key_instance_name" {}
variable "root_device_encrypted" {}
variable "security_groups" {}
variable "tags" {}
variable "user_public_key" {}
variable "volume_tags" {}
variable "zone" {}
variable "dns_services_instance_id" {}
variable "vpc_id" {}
variable "trusted_profile_id" {
  description = "Trusted profile ID for instance authentication (equivalent to AWS IAM instance profile)"
  type        = string
  default     = ""
}

variable "trusted_profile_name" {
  description = "Trusted profile name for IBM Cloud CLI authentication"
  type        = string
  default     = ""
}


# Resolves the CRN of your KMS key for boot volume encryption
data "ibm_kms_key" "itself" {
  count       = var.root_device_kms_key_instance_id != null && var.root_device_kms_key_instance_name != null ? 1 : 0
  instance_id = var.root_device_kms_key_instance_id   # GUID of your Key Protect/HPCS instance
  key_name    = var.root_device_kms_key_instance_name      # Name (or alias) of the root/standard key
}

# Virtual Server for VPC (VSI)
resource "ibm_is_instance" "itself" {
  name    = var.name_prefix
  image   = var.ami_id
  profile = var.instance_type

  # SSH key(s): IBM expects key IDs, not names
  keys = [var.user_public_key]

  vpc  = var.vpc_id
  zone = var.zone

  # Attach trusted profile if provided (equivalent to AWS iam_instance_profile)
  default_trusted_profile_target = var.trusted_profile_id != "" ? var.trusted_profile_id : null

  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = var.security_groups
  }

  # Encrypt the root volume with the KMS key CRN
  boot_volume {
    encryption = var.root_device_kms_key_instance_id != null ? data.ibm_kms_key.itself[0].id : null
  }

  user_data = <<-EOF
#!/usr/bin/env bash
set -euxo pipefail

# Ensure SSH dir exists and correct perms
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Keys & SSH settings
echo "${var.meta_private_key}" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
echo "${var.meta_public_key}" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

{
  echo "  StrictHostKeyChecking no"
  echo "  UserKnownHostsFile=/dev/null"
} >> /root/.ssh/config
chmod 600 /root/.ssh/config

# Hostname settings
hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
mkdir -p /etc/cloud/cloud.cfg.d
echo 'preserve_hostname: True' > /etc/cloud/cloud.cfg.d/10_hostname.cfg
echo "${var.name_prefix}.${var.dns_domain}" > /etc/hostname

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && sysctl -p

# Setup IBM Cloud CLI if trusted profile is provided
if [ -n "${var.trusted_profile_name}" ]; then
  REGION="$(echo "${var.zone}" | sed 's/-[0-9]\+$//')"
  
  # Install IBM Cloud CLI and configure
  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
  /usr/local/bin/ibmcloud config --check-version=false
  /usr/local/bin/ibmcloud api https://cloud.ibm.com
  /usr/local/bin/ibmcloud login --vpc-cri --profile "${var.trusted_profile_id}" -r "$REGION"
  /usr/local/bin/ibmcloud plugin install vpc-infrastructure -f
  
  # Create session keeper service
  cat > /etc/systemd/system/ibmcloud-session-keeper.service <<'SVC'
[Unit]
Description=IBM Cloud CLI Session Keeper
After=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=300
Environment="IBMCLOUD_HOME=/root/.ibmcloud"
ExecStart=/usr/local/bin/ibmcloud-session-keeper.sh

[Install]
WantedBy=multi-user.target
SVC

  cat > /usr/local/bin/ibmcloud-session-keeper.sh <<'SCRIPT'
#!/bin/bash
export IBMCLOUD_HOME=/root/.ibmcloud
export PATH=/usr/local/bin:$PATH
while true; do
  if ! /usr/local/bin/ibmcloud target &>/dev/null; then
    /usr/local/bin/ibmcloud config --check-version=false
    /usr/local/bin/ibmcloud api https://cloud.ibm.com
    /usr/local/bin/ibmcloud login --vpc-cri --profile "${var.trusted_profile_id}" -r "$REGION"
    /usr/local/bin/ibmcloud plugin list | grep -q vpc-infrastructure || \
      /usr/local/bin/ibmcloud plugin install vpc-infrastructure -f &>/dev/null
  fi
  sleep 300
done
SCRIPT

  chmod +x /usr/local/bin/ibmcloud-session-keeper.sh
  
  # Set environment variables
  grep -q "IBMCLOUD_HOME" /root/.bashrc || \
    echo -e "\nexport IBMCLOUD_HOME=/root/.ibmcloud\nexport PATH=/usr/local/bin:\$PATH" >> /root/.bashrc
  grep -q "IBMCLOUD_HOME" /etc/environment || \
    echo "IBMCLOUD_HOME=/root/.ibmcloud" >> /etc/environment
  
  # Start service
  systemctl daemon-reload
  systemctl enable --now ibmcloud-session-keeper.service
fi

# Unmask and enable rpcbind service and socket for protocol node
echo "Unmasking and enabling rpcbind service and socket..." | logger -t rpcbind-setup
systemctl unmask rpcbind.service rpcbind.socket
if [ $? -eq 0 ]; then
  echo "rpcbind service and socket unmasked successfully" | logger -t rpcbind-setup
else
  echo "WARNING: rpcbind service or socket unmasking failed" | logger -t rpcbind-setup
fi

# IBM Storage Scale device discovery helper
mkdir -p "/var/mmfs/etc"

cat > "/var/mmfs/etc/nsddevices" <<'KSH'
#!/bin/ksh
# Generated by IBM Storage Scale deployment.
KSH

BOOT_DISK=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
for disk in /dev/vd[b-z]; do
    [[ ! -b "$disk" ]] && continue
    [[ "$disk" == "$BOOT_DISK" ]] && continue

    SIZE=$(blockdev --getsize64 "$disk")
    if [[ $SIZE -gt 1073741824 ]]; then    # >1GB
        echo "echo $disk generic" >> "/var/mmfs/etc/nsddevices"
    fi
done

echo "# Bypass the NSD device discovery" >> "/var/mmfs/etc/nsddevices"
echo "return 0" >> "/var/mmfs/etc/nsddevices"
chmod u+x "/var/mmfs/etc/nsddevices"
EOF

  metadata_service {
    enabled  = true
    protocol = "http"
  }

  lifecycle {
    ignore_changes = all
  }
}

# Create "A" record: hostname -> private IPv4
resource "ibm_dns_resource_record" "a_itself" {
  # IBM Cloud DNS Services instance GUID (from ibm_resource_instance "dns-svcs")
  instance_id = var.dns_services_instance_id

  # Forward DNS zone ID (from ibm_dns_zone)
  zone_id = var.forward_dns_zone_id

  type = "A"
  name = format("%s.%s", var.name_prefix, var.dns_domain)
  rdata = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address
  ttl   = 3600
}

# Create "PTR" record: IPv4 -> hostname (in the same forward zone)
resource "ibm_dns_resource_record" "ptr_itself" {
  instance_id = var.dns_services_instance_id
  zone_id = var.forward_dns_zone_id

  type = "PTR"
  name = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address

  # rdata is the FQDN you want this IP to resolve to
  rdata = format("%s.%s", var.name_prefix, var.dns_domain)
  ttl = 3600

  depends_on = [ibm_dns_resource_record.a_itself]
}

data "ibm_is_subnet" "itself" {
  identifier = var.subnet_id
}

resource "ibm_is_vpc_routing_table_route" itself {
  vpc           = var.vpc_id
  routing_table = data.ibm_is_subnet.itself.routing_table[0].id
  destination   = format("%s/32", var.ces_ipaddress)
  action        = "deliver"
  next_hop      = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address
  zone=var.zone
}

# Create "A" (IPv4 Address) record to map CES IPv4 address as hostname along with domain
resource "ibm_dns_resource_record" "ces_a_itself" {
  # IBM Cloud DNS Services instance GUID (from ibm_resource_instance "dns-svcs")
  instance_id = var.dns_services_instance_id

  # Forward DNS zone ID (from ibm_dns_zone)
  zone_id = var.forward_dns_zone_id

  type = "A"
  name = format("%s-ces.%s", var.name_prefix, var.dns_domain)
  rdata = var.ces_ipaddress
  ttl   = 3600
}

# Create "PTR" record: IPv4 -> hostname (in the same forward zone)
resource "ibm_dns_resource_record" "ces_ptr_itself" {
  instance_id = var.dns_services_instance_id
  zone_id = var.forward_dns_zone_id

  type = "PTR"
  name = var.ces_ipaddress

  # rdata is the FQDN you want this IP to resolve to
  rdata = format("%s-ces.%s", var.name_prefix, var.dns_domain)
  ttl = 3600

  depends_on = [ibm_dns_resource_record.ces_a_itself]
}


output "instance_details" {
  value = {
    private_ip = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address
    id         = ibm_is_instance.itself.id
    dns        = format("%s.%s", var.name_prefix, var.dns_domain)
    zone       = ibm_is_instance.itself.zone
    ces_private_ip = var.ces_ipaddress
  }
}

output "ces_private_ip" {
  value = var.ces_ipaddress
}
