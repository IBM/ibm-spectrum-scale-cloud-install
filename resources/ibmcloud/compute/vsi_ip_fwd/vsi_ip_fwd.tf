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

locals {
  user_data = <<-EOT
    #!/usr/bin/env bash
    echo "${var.meta_private_key}" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
    echo "StrictHostKeyChecking no" >> ~/.ssh/config
    # Hostname settings
    hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
    echo 'preserve_hostname: True' > /etc/cloud/cloud.cfg.d/10_hostname.cfg
    echo "${var.name_prefix}.${var.dns_domain}" > /etc/hostname
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
  EOT
}

# IBM Cloud CLI Auto-Login Setup (AWS IAM Role Equivalent)

# Create a Service ID for CES automation (equivalent to AWS IAM Role)
resource "ibm_iam_service_id" "ces_automation" {
  name        = "${var.name_prefix}-ces-automation"
  description = "Service ID for IBM Storage Scale CES IP management - AWS IAM role equivalent"
}

# Create an API key for the Service ID
resource "ibm_iam_service_api_key" "ces_api_key" {
  name           = "${var.name_prefix}-ces-api-key"
  iam_service_id = ibm_iam_service_id.ces_automation.iam_id
  description    = "API key for automatic IBM Cloud CLI authentication"
}

# Grant VPC Editor permissions to the Service ID
resource "ibm_iam_service_policy" "ces_vpc_editor" {
  iam_service_id = ibm_iam_service_id.ces_automation.id
  roles          = ["Editor"]

  resources {
    service = "is"  # VPC Infrastructure Services
  }
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

# IBM Cloud CLI Auto-Login Setup (AWS IAM Role Equivalent)
mkdir -p /root/.ibmcloud
echo "${ibm_iam_service_api_key.ces_api_key.apikey}" > /root/.ibmcloud/apikey
chmod 600 /root/.ibmcloud/apikey

# Create systemd service for IBM Cloud CLI auto-login
cat > /etc/systemd/system/ibmcloud-auto-login.service <<'SYSTEMD'
[Unit]
Description=IBM Cloud CLI Auto Login (AWS IAM Role Equivalent)
After=network-online.target
Wants=network-online.target
Before=gpfs.service mmfs.service

[Service]
Type=oneshot
Environment="IBMCLOUD_HOME=/root/.ibmcloud"
ExecStartPre=/bin/sleep 10
ExecStart=/bin/bash -c 'export IBMCLOUD_HOME=/root/.ibmcloud && if [ -f /usr/local/bin/ibmcloud ]; then /usr/local/bin/ibmcloud config --check-version=false && /usr/local/bin/ibmcloud api https://cloud.ibm.com && /usr/local/bin/ibmcloud login --apikey $(cat /root/.ibmcloud/apikey) -r us-south && /usr/local/bin/ibmcloud plugin install vpc-infrastructure -f; fi'
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
SYSTEMD

# Create systemd timer to refresh login every 30 minutes (keep session alive)
cat > /etc/systemd/system/ibmcloud-auto-login.timer <<'TIMER'
[Unit]
Description=IBM Cloud CLI Auto Login Timer
Requires=ibmcloud-auto-login.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
Unit=ibmcloud-auto-login.service

[Install]
WantedBy=timers.target
TIMER

# Wait for IBM Cloud CLI to be available (critical for immediate script execution)
echo "Waiting for IBM Cloud CLI..."
timeout=300
elapsed=0
while [ ! -f /usr/local/bin/ibmcloud ] && [ $elapsed -lt $timeout ]; do
  sleep 5
  elapsed=$((elapsed + 5))
done

if [ ! -f /usr/local/bin/ibmcloud ]; then
  echo "ERROR: IBM Cloud CLI not found after $timeout seconds" | logger -t ibmcloud-setup
  exit 1
fi

# Perform initial login immediately (critical for scripts that run within 1-2 min)
echo "Performing initial IBM Cloud CLI login..." | logger -t ibmcloud-setup
export IBMCLOUD_HOME=/root/.ibmcloud
mkdir -p $IBMCLOUD_HOME
/usr/local/bin/ibmcloud config --check-version=false
/usr/local/bin/ibmcloud api https://cloud.ibm.com
/usr/local/bin/ibmcloud login --apikey "${ibm_iam_service_api_key.ces_api_key.apikey}" -r us-south
if [ $? -eq 0 ]; then
  echo "IBM Cloud CLI login successful" | logger -t ibmcloud-setup
  /usr/local/bin/ibmcloud plugin install vpc-infrastructure -f
  # Make the login persistent by setting environment variable globally
  echo 'export IBMCLOUD_HOME=/root/.ibmcloud' >> /root/.bashrc
  echo 'export IBMCLOUD_HOME=/root/.ibmcloud' >> /root/.bash_profile
  echo 'export IBMCLOUD_HOME=/root/.ibmcloud' >> /etc/environment
else
  echo "ERROR: IBM Cloud CLI login failed" | logger -t ibmcloud-setup
fi

# Enable systemd service and timer for session persistence
systemctl daemon-reload
systemctl enable ibmcloud-auto-login.service
systemctl enable ibmcloud-auto-login.timer
systemctl start ibmcloud-auto-login.timer

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
