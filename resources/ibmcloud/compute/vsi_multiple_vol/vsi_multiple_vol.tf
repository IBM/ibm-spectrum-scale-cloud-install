/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
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
variable "disks" {}
variable "dns_zone_id" {}
variable "instance_type" {}
variable "name_prefix" {}
variable "placement_group" {}
variable "root_device_kms_key_instance_id" {}
variable "root_device_kms_key_instance_name" {}
variable "root_volume_type" {}
variable "security_groups" {}
variable "subnet_id" {}
variable "tags" {}
variable "ssh_key_id" {}
variable "zone" {}
variable "dns_services_instance_id" {}
variable "vpc_id" {}
variable "attach_volumes" {}

# Fetch all DNS zones to get domain name from zone ID
data "ibm_dns_zones" "all_zones" {
  instance_id = var.dns_services_instance_id
}

locals {
  # Find the zone name by matching zone_id
  zone_name = try(
    [for zone in data.ibm_dns_zones.all_zones.dns_zones : zone.name if zone.zone_id == var.dns_zone_id][0],
    ""
  )
}

# Resolves the CRN of your KMS key for boot volume encryption
data "ibm_kms_key" "itself" {
  count       = var.root_device_kms_key_instance_id != null && var.root_device_kms_key_instance_name != null ? 1 : 0
  instance_id = var.root_device_kms_key_instance_id   # GUID of your Key Protect/HPCS instance
  key_name    = var.root_device_kms_key_instance_name # Name (or alias) of the root/standard key
}

# Virtual Server for VPC (VSI)
resource "ibm_is_instance" "itself" {
  name    = var.name_prefix
  image   = var.ami_id
  profile = var.instance_type
  keys    = [var.ssh_key_id]

  vpc  = var.vpc_id
  zone = var.zone

  # Assign to placement group if provided
  placement_group = var.placement_group

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

  metadata_service {
    enabled            = true
    protocol           = "http"
    response_hop_limit = 1
  }
  user_data = <<EOF
#!/usr/bin/env bash
hostnamectl set-hostname --static "${var.name_prefix}.${local.zone_name}"
echo "${var.name_prefix}.${local.zone_name}" > /etc/hostname
EOF

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Create the specified volumes with the corresponding type and size
resource "ibm_is_volume" "itself" {
  for_each       = var.disks
  name           = format("%s-%s", var.name_prefix, each.key)
  zone           = var.zone
  capacity       = tonumber(each.value["size"])
  profile        = each.value["type"]
  iops           = each.value["iops"] == "" ? null : each.value["iops"]
  encryption_key = var.root_device_kms_key_instance_id != null ? data.ibm_kms_key.itself[0].id : null
}

# Create "A" records
resource "ibm_dns_resource_record" "a_itself" {
  instance_id = var.dns_services_instance_id
  zone_id     = var.dns_zone_id
  type        = "A"
  name        = format("%s.%s", var.name_prefix, local.zone_name)
  rdata       = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
  ttl         = 3600
}

# Create "PTR" records in the same DNS zone (IBM Cloud DNS supports this)
resource "ibm_dns_resource_record" "ptr_itself" {
  instance_id = var.dns_services_instance_id
  zone_id     = var.dns_zone_id
  type        = "PTR"
  name        = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
  rdata       = format("%s.%s", var.name_prefix, local.zone_name)
  ttl         = 3600

  depends_on = [ibm_dns_resource_record.a_itself]
}

# Attach the volumes to the provisioned IBM Cloud instance (only if attach_volumes is true)
resource "ibm_is_instance_volume_attachment" "itself" {
  for_each = var.attach_volumes ? ibm_is_volume.itself : {}

  instance = ibm_is_instance.itself.id
  volume   = ibm_is_volume.itself[each.key].id
  name     = format("%s-%s-att", var.name_prefix, each.key)
}

output "instance_details" {
  value = {
    private_ip = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
    id         = ibm_is_instance.itself.id
    dns        = format("%s.%s", var.name_prefix, local.zone_name)
    zone       = ibm_is_instance.itself.zone
  }
}
