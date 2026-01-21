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

variable "ami_id" {}
variable "dns_domain" {}
variable "forward_dns_zone" {}
variable "forward_dns_zone_id" {}
variable "instance_type" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "name_prefix" {}
variable "placement_group" {}
#variable "reverse_dns_domain" {}
#variable "reverse_dns_zone" {}
#variable "reverse_dns_zone_id" {}
variable "root_device_encrypted" {}
variable "root_device_kms_key_instance_id" {}
variable "root_device_kms_key_instance_name" {}
variable "root_volume_type" {}
variable "security_groups" {}
variable "subnet_id" {}
variable "tags" {}
variable "user_public_key" {}
variable "volume_tags" {}
variable "vpc_id" {}
variable "zone" {}
variable "dns_services_instance_id" {}


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
  EOT
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
  zone = var.zone[0]

  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = var.security_groups
  }

  # Encrypt the root volume with the KMS key CRN
  boot_volume {
    encryption = var.root_device_kms_key_instance_id != null ? data.ibm_kms_key.itself[0].id : null
  }

  metadata_service_enabled = true

  #user_data = data.cloudinit_config.user_data64.rendered


  user_data = <<-EOF
    #!/usr/bin/env bash
    set -euxo pipefail

    # Ensure SSH dir exists and correct perms
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh

    # Keys & SSH settings (these are Terraform variables – keep them as-is)
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

    EOF

  #tags = concat([format("Name=%s", var.name_prefix)], try(var.tags, []))

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
  #zone_id     = var.reverse_dns_zone_id
  zone_id = var.forward_dns_zone_id

  type = "PTR"

  name = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address

  # rdata is the FQDN you want this IP to resolve to
  rdata = format("%s.%s", var.name_prefix, var.dns_domain)
  ttl = 3600

  depends_on = [ibm_dns_resource_record.a_itself]
}

output "instance_details" {
  value = {
    private_ip = ibm_is_instance.itself.primary_network_interface[0].primary_ipv4_address
    id         = ibm_is_instance.itself.id
    dns        = format("%s.%s", var.name_prefix, var.dns_domain)
    zone       = ibm_is_instance.itself.zone
  }
}
