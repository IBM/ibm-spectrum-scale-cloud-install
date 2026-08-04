/*
     Creates IBMCloud Virtual Server instance(s) with a static route
*/

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2"
    }
  }
}

variable "ami_id" {}
variable "subnet_id" {}
variable "dns_zone_id" {}
variable "ces_ipaddress" {}
variable "instance_type" {}
variable "name_prefix" {}
variable "root_device_kms_key_instance_id" {}
variable "root_device_kms_key_instance_name" {}
variable "root_volume_type" {}
variable "security_groups" {}
variable "tags" {}
variable "ssh_key_id" {}
variable "zone" {}
variable "dns_service_instance_id" {}
variable "dns_domain" {}
variable "vpc_id" {}
variable "resource_group_id" {}
variable "orchestrator_server" {}
variable "orchestrator_port" {}
variable "orchestrator_ca_fingerprint" {}
variable "total_volume_bandwidth" {}
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
    service = "is" # VPC Infrastructure Services
  }
}

# Resolves the CRN of your KMS key for boot volume encryption
data "ibm_kms_key" "itself" {
  count       = var.root_device_kms_key_instance_id != null && var.root_device_kms_key_instance_name != null ? 1 : 0
  instance_id = var.root_device_kms_key_instance_id   # GUID of your Key Protect/HPCS instance
  key_name    = var.root_device_kms_key_instance_name # Name (or alias) of the root/standard key
}

# Virtual Server for VPC (VSI)
resource "ibm_is_instance" "itself" {
  name           = var.name_prefix
  image          = var.ami_id
  profile        = var.instance_type
  keys           = [var.ssh_key_id]
  resource_group = var.resource_group_id

  vpc  = var.vpc_id
  zone = var.zone

  # Reserve Mbps for volume I/O on protocol/CES nodes (default 800 Mbps).
  # IBM Cloud automatically assigns the remainder to the NIC.
  total_volume_bandwidth = var.total_volume_bandwidth

  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = var.security_groups
  }

  # Encrypt the root volume with the KMS key CRN
  boot_volume {
    encryption = var.root_device_kms_key_instance_id != null ? data.ibm_kms_key.itself[0].id : null
    profile    = var.root_volume_type
    tags       = var.tags
  }

  user_data = <<EOF
#!/usr/bin/env bash
hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
echo "${var.name_prefix}.${var.dns_domain}" > /etc/hostname
sed -i "s|^server_url:.*|server_url: https://${var.orchestrator_server}:${var.orchestrator_port}|" /etc/scale-agent/config.yaml
sed -i "s|^ca_fingerprint:.*|ca_fingerprint: \"${var.orchestrator_ca_fingerprint}\"|" /etc/scale-agent/config.yaml
systemctl restart scale-agent
EOF

  metadata_service {
    enabled  = true
    protocol = "http"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Create "A" record: hostname -> private IPv4
resource "ibm_dns_resource_record" "a_itself" {
  instance_id = var.dns_service_instance_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = format("%s.%s", var.name_prefix, var.dns_domain)
  rdata       = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
  ttl         = 3600
}

# Create "PTR" record: IPv4 -> hostname (in the same DNS zone)
resource "ibm_dns_resource_record" "ptr_itself" {
  instance_id = var.dns_service_instance_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
  rdata       = format("%s.%s", var.name_prefix, var.dns_domain)
  ttl         = 3600
  depends_on  = [ibm_dns_resource_record.a_itself]
}

data "ibm_is_subnet" "itself" {
  identifier = var.subnet_id
}

resource "ibm_is_vpc_routing_table_route" "itself" {
  vpc           = var.vpc_id
  routing_table = data.ibm_is_subnet.itself.routing_table[0].id
  destination   = format("%s/32", var.ces_ipaddress)
  action        = "deliver"
  next_hop      = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
  zone          = var.zone
}

# Create "A" (IPv4 Address) record to map CES IPv4 address as hostname along with domain
resource "ibm_dns_resource_record" "ces_a_itself" {
  instance_id = var.dns_service_instance_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = format("%s-ces.%s", var.name_prefix, var.dns_domain)
  rdata       = var.ces_ipaddress
  ttl         = 3600
}

# Create "PTR" records in the same DNS zone (IBM Cloud DNS supports this)
resource "ibm_dns_resource_record" "ces_ptr_itself" {
  instance_id = var.dns_service_instance_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = var.ces_ipaddress
  rdata       = format("%s-ces.%s", var.name_prefix, var.dns_domain)
  ttl         = 3600
  depends_on  = [ibm_dns_resource_record.ces_a_itself]
}


output "instance_details" {
  value = {
    private_ip     = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
    id             = ibm_is_instance.itself.id
    dns            = format("%s.%s", var.name_prefix, var.dns_domain)
    zone           = ibm_is_instance.itself.zone
    ces_private_ip = var.ces_ipaddress
  }
}

output "ces_private_ip" {
  value = var.ces_ipaddress
}
