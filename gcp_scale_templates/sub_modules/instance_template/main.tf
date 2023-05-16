/*
  Creates compute and storage Google Cloud Platform(GCP) VM clusters.
*/

locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets == null && var.vpc_compute_cluster_private_subnets != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets != null) ? "combined" : "none"
  )

  security_rule_description_cluster_storage_internal_ingress = ["Allow ICMP traffic within storage instances",
    "Allow SSH traffic within storage instances",
    "Allow GPFS intra cluster traffic within storage instances",
    "Allow GPFS ephemeral port range within storage instances",
    "Allow management GUI (http/localhost) TCP traffic within storage instances",
    "Allow management GUI (https/localhost) TCP traffic within storage instances",
    "Allow management GUI (https/localhost) TCP traffic within storage instances",
    "Allow management GUI (localhost) TCP traffic within storage instances",
    "Allow management GUI (localhost) UDP traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow http traffic within storage instances",
  "Allow https traffic within storage instances"]

  security_rule_description_cluster_compute_to_storage_ingress = ["Allow ICMP traffic from compute to storage instances",
    "Allow SSH traffic from compute to storage instances",
    "Allow GPFS intra cluster traffic from compute to storage instances",
    "Allow GPFS ephemeral port range from compute to storage instances",
    "Allow management GUI (http/localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (https/localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (https/localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (localhost) UDP traffic from compute to storage instances",
    "Allow performance monitoring collector traffic from compute to storage instances",
    "Allow performance monitoring collector traffic from compute to storage instances",
    "Allow http traffic from compute to storage instances",
  "Allow https traffic from compute to storage instances"]

  traffic_protocol_cluster_storage_internal_ingress = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_port_cluster_storage_internal_ingress     = ["-1", "22", "1191", "60000-61000", "47080", "47443", "4444", "4739", "4739", "9080", "9081", "80", "443"]

  security_rule_description_cluster_compute_internal_ingress = ["Allow ICMP traffic within compute instances",
    "Allow SSH traffic within compute instances",
    "Allow GPFS intra cluster traffic within compute instances",
    "Allow GPFS ephemeral port range within compute instances",
    "Allow management GUI (http/localhost) TCP traffic within compute instances",
    "Allow management GUI (https/localhost) TCP traffic within compute instances",
    "Allow management GUI (https/localhost) TCP traffic within compute instances",
    "Allow management GUI (localhost) TCP traffic within compute instances",
    "Allow management GUI (localhost) UDP traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow http traffic within compute instances",
  "Allow https traffic within compute instances"]

  security_rule_description_cluster_storage_to_compute_ingress = ["Allow ICMP traffic from storage to compute instances",
    "Allow SSH traffic from storage to compute instances",
    "Allow GPFS intra cluster traffic from storage to compute instances",
    "Allow GPFS ephemeral port range from storage to compute instances",
    "Allow management GUI (http/localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (https/localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (https/localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (localhost) UDP traffic from storage to compute instances",
    "Allow performance monitoring collector traffic from storage to compute instances",
    "Allow performance monitoring collector traffic from storage to compute instances",
    "Allow http traffic from storage to compute instances",
  "Allow https traffic from storage to compute instances"]

  traffic_protocol_cluster_compute_ingress = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_port_cluster_compute_ingress     = ["-1", "22", "1191", "60000-61000", "47080", "47443", "4444", "4739", "4739", "9080", "9081", "80", "443"]

  security_rule_description_cluster_egress_all = ["Allow all egress traffic"]


  # Using direct connection protocol and ports
  traffic_protocol_cluster_ingress_using_direct_connection                  = ["icmp", "TCP"]
  traffic_port_cluster_ingress_using_direct_connection                      = [-1, 22]
  security_rule_description_compute_cluster_ingress_using_direct_connection = ["Allow ICMP traffic from client cidr/ip range to compute instances", "Allow SSH traffic from client cidr/ip range to compute instances"]
  security_rule_description_storage_cluster_ingress_using_direct_connection = ["Allow ICMP traffic from client cidr/ip range to storage instances", "Allow SSH traffic from client cidr/ip range to storage instances"]

  security_rule_description_bastion_scale_ingress = ["Allow ICMP traffic from bastion to scale instances",
  "Allow SSH traffic from bastion to scale instances"]

  traffic_protocol_cluster_bastion_scale_ingress = ["icmp", "TCP"]
  traffic_port_cluster_bastion_scale_ingress     = [-1, 22]

  gpfs_base_rpm_path = var.spectrumscale_rpms_path != null ? fileset(var.spectrumscale_rpms_path, "gpfs.base-*") : null
  scale_version      = local.gpfs_base_rpm_path != null ? regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0] : null
}

# Generate compute cluster ssh keys
module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances != null ? true : false
}

# Generate storage cluster ssh keys
module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances != null ? true : false
}

data "google_compute_subnetwork" "storage_cluster" {
  count     = var.vpc_storage_cluster_private_subnets != null ? length(var.vpc_storage_cluster_private_subnets) > 0 ? length(var.vpc_storage_cluster_private_subnets) : 0 : 0
  self_link = length(regexall("^https", var.vpc_storage_cluster_private_subnets[count.index])) > 0 ? var.vpc_storage_cluster_private_subnets[count.index] : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/us-central1/subnetworks/${var.vpc_storage_cluster_private_subnets[count.index]}"
}

data "google_compute_subnetwork" "compute_cluster" {
  count     = var.vpc_compute_cluster_private_subnets != null ? length(var.vpc_compute_cluster_private_subnets) > 0 ? length(var.vpc_compute_cluster_private_subnets) : 0 : 0
  self_link = length(regexall("^https", var.vpc_compute_cluster_private_subnets[count.index])) > 0 ? var.vpc_compute_cluster_private_subnets[count.index] : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/us-central1/subnetworks/${var.vpc_compute_cluster_private_subnets[count.index]}"
}

data "google_compute_instance" "google_compute_instance" {
  count     = var.bastion_instance_ref != null ? 1 : 0
  self_link = var.bastion_instance_ref
  zone      = var.vpc_availability_zones[0]
}

data "google_compute_subnetwork" "bastion_subnetwork" {
  count  = var.bastion_instance_ref != null ? 1 : 0
  name   = element(split("/", data.google_compute_instance.google_compute_instance[0].network_interface[0].subnetwork), length(split("/", data.google_compute_instance.google_compute_instance[0].network_interface[0].subnetwork)) - 1)
  region = var.vpc_region
}

# Allow traffic from bastion to scale cluster
module "allow_traffic_bastion_to_scale_cluster" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = true
  firewall_name_prefix = "${var.resource_prefix}-bastion-to-scale"
  vpc_ref              = var.vpc_ref
  source_ranges        = length(data.google_compute_subnetwork.bastion_subnetwork) > 0 ? (data.google_compute_subnetwork.bastion_subnetwork[0].ip_cidr_range != null ? [data.google_compute_subnetwork.bastion_subnetwork[0].ip_cidr_range] : null) : null
  destination_ranges   = concat(data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range, data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range)
  protocol             = local.traffic_protocol_cluster_bastion_scale_ingress
  ports                = local.traffic_port_cluster_bastion_scale_ingress
  firewall_description = local.security_rule_description_bastion_scale_ingress
}

# Allow traffic within compute internals
module "allow_traffic_scale_cluster_compute_internal" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = local.cluster_type == "compute" || local.cluster_type == "combined" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-comp-internals"
  vpc_ref              = var.vpc_ref
  source_ranges        = length(data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range : null
  destination_ranges   = length(data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_compute_ingress
  ports                = local.traffic_port_cluster_compute_ingress
  firewall_description = local.security_rule_description_cluster_compute_internal_ingress
}

# Allow traffic storage to compute
module "allow_traffic_scale_cluster_storage_to_compute" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = local.cluster_type == "combined" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-strg-comp"
  vpc_ref              = var.vpc_ref
  source_ranges        = length(data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range : null
  destination_ranges   = length(data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_compute_ingress
  ports                = local.traffic_port_cluster_compute_ingress
  firewall_description = local.security_rule_description_cluster_storage_to_compute_ingress
}

# Allow traffic from compute to storage
module "allow_traffic_scale_cluster_compute_to_storage" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = local.cluster_type == "combined" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-comp-strg"
  vpc_ref              = var.vpc_ref
  source_ranges        = length(data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range : null
  destination_ranges   = length(data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_storage_internal_ingress
  ports                = local.traffic_port_cluster_storage_internal_ingress
  firewall_description = local.security_rule_description_cluster_compute_to_storage_ingress
}

# Allow traffic storage internals
module "allow_traffic_scale_cluster_storage_internals" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = local.cluster_type == "storage" || local.cluster_type == "combined" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-strg-internals"
  vpc_ref              = var.vpc_ref
  source_ranges        = length(data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range : null
  destination_ranges   = length(data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_storage_internal_ingress
  ports                = local.traffic_port_cluster_storage_internal_ingress
  firewall_description = local.security_rule_description_cluster_storage_internal_ingress
}

# Allow egress traffic to all instances
module "allow_traffic_scale_cluster_egress_all" {
  source                       = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_egress               = local.cluster_type != "none" ? true : false
  firewall_name_prefix         = "${var.resource_prefix}-scale-all"
  vpc_ref                      = var.vpc_ref
  destination_range_egress_all = local.cluster_type != "none" ? ["0.0.0.0/0"] : null
  firewall_description         = local.security_rule_description_cluster_egress_all
}

# Allow ingress firewall traffic from client_ip_ranges for using_direct_connection mode
module "compute_cluster_ingress_security_rule_using_direct_connection" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.using_direct_connection == true) ? true : false
  firewall_name_prefix = "${var.resource_prefix}-compute-using-direct-connection"
  vpc_ref              = var.vpc_ref
  source_ranges        = var.client_ip_ranges
  destination_ranges   = length(data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.compute_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_ingress_using_direct_connection
  ports                = local.traffic_port_cluster_ingress_using_direct_connection
  firewall_description = local.security_rule_description_compute_cluster_ingress_using_direct_connection
}

module "storage_cluster_ingress_security_rule_using_direct_connection" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  turn_on_ingress_bi   = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.using_direct_connection == true) ? true : false
  firewall_name_prefix = "${var.resource_prefix}-storage-using-direct-connection"
  vpc_ref              = var.vpc_ref
  source_ranges        = var.client_ip_ranges
  destination_ranges   = length(data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range) > 0 ? data.google_compute_subnetwork.storage_cluster[*].ip_cidr_range : null
  protocol             = local.traffic_protocol_cluster_ingress_using_direct_connection
  ports                = local.traffic_port_cluster_ingress_using_direct_connection
  firewall_description = local.security_rule_description_storage_cluster_ingress_using_direct_connection
}

# Creates compute instances
module "compute_cluster_instances" {
  source                  = "../../../resources/gcp/compute/vm_instance"
  vpc_availability_zones  = var.vpc_availability_zones
  ssh_key_path            = var.compute_cluster_public_key_path
  ssh_user_name           = var.instances_ssh_user_name
  total_cluster_instances = local.cluster_type == "compute" || local.cluster_type == "combined" ? var.total_compute_cluster_instances : 0
  total_persistent_disks  = 0
  total_local_ssd_disks   = 0
  instance_name           = format("%s-compute", var.resource_prefix)
  machine_type            = var.compute_cluster_instance_type
  vpc_subnets             = var.vpc_compute_cluster_private_subnets != null ? var.vpc_compute_cluster_private_subnets : null
  private_key_content     = module.generate_compute_cluster_keys.private_key_content
  public_key_content      = module.generate_compute_cluster_keys.public_key_content
  service_email           = var.service_email
  scopes                  = var.scopes
  boot_disk_size          = var.compute_boot_disk_size
  boot_disk_type          = var.compute_boot_disk_type
  boot_image              = var.compute_cluster_image_ref
}

# Creates storage tie breaker instance
module "storage_cluster_tie_breaker_instance" {
  source                  = "../../../resources/gcp/compute/vm_instance"
  vpc_availability_zones  = length(var.vpc_availability_zones) > 1 ? [var.vpc_availability_zones[2]] : []
  ssh_key_path            = var.storage_cluster_public_key_path
  ssh_user_name           = var.instances_ssh_user_name
  total_cluster_instances = var.vpc_storage_cluster_private_subnets != null ? ((length(var.vpc_storage_cluster_private_subnets) > 2 && (local.cluster_type == "storage" || local.cluster_type == "combined")) ? 1 : 0) : 0
  total_persistent_disks  = 1
  total_local_ssd_disks   = 0
  instance_name           = format("%s-storage-tie", var.resource_prefix)
  machine_type            = var.storage_cluster_instance_type
  vpc_subnets             = var.vpc_storage_cluster_private_subnets != null ? (length(var.vpc_storage_cluster_private_subnets) > 1 ? [var.vpc_storage_cluster_private_subnets[2]] : var.vpc_storage_cluster_private_subnets) : null
  private_key_content     = module.generate_storage_cluster_keys.private_key_content
  public_key_content      = module.generate_storage_cluster_keys.public_key_content
  service_email           = var.service_email
  scopes                  = var.scopes
  boot_disk_size          = var.storage_boot_disk_size
  boot_disk_type          = var.storage_boot_disk_type
  boot_image              = var.storage_cluster_image_ref
  data_disk_type          = var.block_device_volume_type
  data_disk_size          = 5
}

# Creates storage instances
module "storage_cluster_instances" {
  source                  = "../../../resources/gcp/compute/vm_instance"
  vpc_availability_zones  = length(var.vpc_availability_zones) > 1 ? slice(var.vpc_availability_zones, 0, 2) : var.vpc_availability_zones
  ssh_key_path            = var.storage_cluster_public_key_path
  ssh_user_name           = var.instances_ssh_user_name
  total_cluster_instances = local.cluster_type == "storage" || local.cluster_type == "combined" ? var.total_storage_cluster_instances : 0
  total_persistent_disks  = var.block_devices_per_storage_instance
  total_local_ssd_disks   = var.scratch_devices_per_storage_instance
  instance_name           = format("%s-storage", var.resource_prefix)
  machine_type            = var.storage_cluster_instance_type
  vpc_subnets             = var.vpc_storage_cluster_private_subnets != null ? (length(var.vpc_storage_cluster_private_subnets) > 1 ? slice(var.vpc_storage_cluster_private_subnets, 0, 2) : var.vpc_storage_cluster_private_subnets) : null
  private_key_content     = module.generate_storage_cluster_keys.private_key_content
  public_key_content      = module.generate_storage_cluster_keys.public_key_content
  service_email           = var.service_email
  scopes                  = var.scopes
  boot_disk_size          = var.storage_boot_disk_size
  boot_disk_type          = var.storage_boot_disk_type
  boot_image              = var.storage_cluster_image_ref
  data_disk_type          = var.block_device_volume_type
  data_disk_size          = var.block_device_volume_size
}

# Prepare ansible config
module "prepare_ansible_configuration" {
  turn_on    = true
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

# Write the compute cluster related inventory.
module "write_compute_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == true && local.cluster_type == "compute") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode("None")
  compute_cluster_filesystem_mountpoint            = jsonencode(var.compute_cluster_filesystem_mountpoint)
  bastion_instance_id                              = var.bastion_instance_ref == null ? jsonencode("None") : jsonencode(var.bastion_instance_ref)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(flatten(module.compute_cluster_instances[*].instance_selflink))
  compute_cluster_instance_private_ips             = jsonencode(flatten(module.compute_cluster_instances[*].instance_ips))
  compute_cluster_instance_private_dns_ip_map      = length(module.compute_cluster_instances) > 0 ? jsonencode(module.compute_cluster_instances[*].dns_hostname) : jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode("None")
  storage_cluster_instance_ids                     = jsonencode([])
  storage_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_with_data_volume_mapping         = jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([])
  storage_cluster_desc_instance_private_ips        = jsonencode([])
  storage_cluster_desc_data_volume_mapping         = jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode({})
}

# Write the storage cluster related inventory.
module "write_storage_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == true && local.cluster_type == "storage" || local.cluster_type == "combined") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_ref == null ? jsonencode("None") : jsonencode(var.bastion_instance_ref)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode([])
  compute_cluster_instance_private_ips             = jsonencode([])
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode(flatten(module.storage_cluster_instances[*].instance_selflink))
  storage_cluster_instance_private_ips             = jsonencode(flatten(module.storage_cluster_instances[*].instance_ips))
  storage_cluster_with_data_volume_mapping         = length(module.storage_cluster_instances) > 0 ? jsonencode((module.storage_cluster_instances[*].disk_device_mapping)[0]) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = length(module.storage_cluster_instances) > 0 ? jsonencode((module.storage_cluster_instances[*].dns_hostname)[0]) : jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode(flatten(module.storage_cluster_tie_breaker_instance[*].instance_selflink))
  storage_cluster_desc_instance_private_ips        = jsonencode(module.storage_cluster_tie_breaker_instance[*].instance_ips)
  storage_cluster_desc_data_volume_mapping         = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode((flatten(module.storage_cluster_tie_breaker_instance[*].disk_device_mapping))[0]) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode((flatten(module.storage_cluster_tie_breaker_instance[*].dns_hostname))[0]) : jsonencode({})
}

# Write combined cluster related inventory.
module "write_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_remote_mount_cluster == false && local.cluster_type == "combined") ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  inventory_path                                   = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("GCP")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_ref == null ? jsonencode("None") : jsonencode(var.bastion_instance_ref)
  bastion_user                                     = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(flatten(module.compute_cluster_instances[*].instance_selflink))
  compute_cluster_instance_private_ips             = jsonencode(flatten(module.compute_cluster_instances[*].instance_ips))
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = jsonencode(flatten(module.storage_cluster_instances[*].instance_selflink))
  storage_cluster_instance_private_ips             = jsonencode(flatten(module.storage_cluster_instances[*].instance_ips))
  storage_cluster_with_data_volume_mapping         = length(module.storage_cluster_instances) > 0 ? jsonencode((module.storage_cluster_instances[*].disk_device_mapping)[0]) : jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = length(module.storage_cluster_instances) > 0 ? jsonencode((module.storage_cluster_instances[*].dns_hostname)[0]) : jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode(flatten(module.storage_cluster_tie_breaker_instance[*].instance_selflink))
  storage_cluster_desc_instance_private_ips        = jsonencode(module.storage_cluster_tie_breaker_instance[*].instance_ips)
  storage_cluster_desc_data_volume_mapping         = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode((flatten(module.storage_cluster_tie_breaker_instance[*].disk_device_mapping))[0]) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(module.storage_cluster_tie_breaker_instance) > 0 ? jsonencode((flatten(module.storage_cluster_tie_breaker_instance[*].dns_hostname))[0]) : jsonencode({})
}

# Configure the compute cluster using ansible based on the create_scale_cluster input.
module "compute_cluster_configuration" {
  source                       = "../../../resources/common/compute_configuration"
  turn_on                      = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_compute_cluster_inventory.write_inventory_complete
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_jumphost_connection    = var.using_jumphost_connection
  using_rest_initialization    = var.using_rest_api_remote_mount
  compute_cluster_gui_username = var.compute_cluster_gui_username
  compute_cluster_gui_password = var.compute_cluster_gui_password
  memory_size                  = 8
  max_pagepool_gb              = 4
  bastion_user                 = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip   = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key      = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key             = module.generate_compute_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
}

# Configure the storage cluster using ansible based on the create_scale_cluster input.
module "storage_cluster_configuration" {
  source                       = "../../../resources/common/storage_configuration"
  turn_on                      = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_storage_cluster_inventory.write_inventory_complete
  inventory_format             = var.inventory_format
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_jumphost_connection    = var.using_jumphost_connection
  using_rest_initialization    = true
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = 5
  max_pagepool_gb              = 16
  vcpu_count                   = 2
  bastion_user                 = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip   = var.bastion_instance_public_ip
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
  depends_on                   = [module.storage_cluster_instances]
}
