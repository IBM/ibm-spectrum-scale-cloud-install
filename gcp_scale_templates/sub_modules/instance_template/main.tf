/*
  Creates compute and storage Google Cloud Platform(GCP) VM clusters.
*/

terraform {
  backend "gcs" {}
}

locals {
  cluster_type = (
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets == null) ? "storage" :
    (var.vpc_storage_cluster_private_subnets == null && var.vpc_compute_cluster_private_subnets != null) ? "compute" :
    (var.vpc_storage_cluster_private_subnets != null && var.vpc_compute_cluster_private_subnets != null) ? "combined" : "none"
  )

  cluster_comp_stg_vm_tags = concat(var.compute_instance_tags, var.storage_instance_tags)

  security_rule_description_bastion = ["Allow ICMP traffic from bastion to scale instances",
  "Allow SSH traffic from bastion to scale instances"]

  traffic_protocol_bastion = ["icmp", "TCP"]
  traffic_port_bastion     = [-1, 22]

  security_rule_description_cluster_ingress = [
    "Allow ICMP traffic within scale instances",
    "Allow SSH traffic within scale instances",
    "Allow GPFS intra cluster traffic within scale instances",
    "Allow GPFS ephemeral port range within scale instances",
    "Allow management GUI (http/localhost) TCP traffic within scale instances",
    "Allow management GUI (http/localhost) UDP traffic within scale instances",
    "Allow management GUI (https/localhost) TCP traffic within scale instances",
    "Allow management GUI (https/localhost) UDP traffic within scale instances",
    "Allow management GUI (localhost) TCP traffic within scale instances",
    "Allow management GUI (localhost) UDP traffic within scale instances",
    "Allow performance monitoring collector traffic within scale instances",
    "Allow performance monitoring collector traffic within scale instances",
    "Allow performance monitoring collector traffic within scale instances",
    "Allow http traffic within scale instances",
  "Allow https traffic within scale instances"]

  traffic_protocol_cluster_ingress = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_port_cluster_ingress     = [-1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]

  security_rule_description_egress = ["Outgoing traffic from compute and storage cluster"]
  traffic_protocol_egress          = ["TCP"]
  traffic_port_egress              = [6335]
}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances != null ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances != null ? true : false
}

module "allow_traffic_bastion_to_scale_cluster" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  count                = length(local.traffic_protocol_bastion)
  turn_on_ingress      = local.cluster_type != "none" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-bastion-${count.index}"
  vpc_name             = var.vpc_name
  source_vm_tags       = var.bastion_instance_tags
  destination_vm_tags  = local.cluster_comp_stg_vm_tags
  protocol             = local.traffic_protocol_bastion[count.index]
  ports                = [local.traffic_port_bastion[count.index]]
  firewall_description = local.security_rule_description_bastion[count.index]
}

module "allow_traffic_compute_instances_internal" {
  source               = "../../../resources/gcp/security/allow_internal"
  turn_on              = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
  firewall_name_prefix = "${var.resource_prefix}-compute"
  vpc_name             = var.vpc_name
  subnet_cidr_range    = var.compute_subnet_cidrs
  vm_tags              = local.cluster_comp_stg_vm_tags
}

module "allow_traffic_storage_instances_internal" {
  source               = "../../../resources/gcp/security/allow_internal"
  turn_on              = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
  firewall_name_prefix = "${var.resource_prefix}-storage"
  vpc_name             = var.vpc_name
  subnet_cidr_range    = var.storage_subnet_cidrs
  vm_tags              = local.cluster_comp_stg_vm_tags
}

module "allow_traffic_scale_cluster" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  count                = length(local.traffic_protocol_cluster_ingress)
  turn_on_ingress      = local.cluster_type != "none" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-scale-cluster-${count.index}"
  vpc_name             = var.vpc_name
  source_vm_tags       = local.cluster_comp_stg_vm_tags
  destination_vm_tags  = local.cluster_comp_stg_vm_tags
  protocol             = local.traffic_protocol_cluster_ingress[count.index]
  ports                = [local.traffic_port_cluster_ingress[count.index]]
  firewall_description = local.security_rule_description_cluster_ingress[count.index]
}

module "allow_traffic_scale_cluster_egress" {
  source               = "../../../resources/gcp/security/allow_protocol_ports"
  count                = length(local.traffic_protocol_egress)
  turn_on_egress       = local.cluster_type != "none" ? true : false
  firewall_name_prefix = "${var.resource_prefix}-cluster-${count.index}"
  vpc_name             = var.vpc_name
  source_vm_tags       = local.cluster_comp_stg_vm_tags
  destination_vm_tags  = local.cluster_comp_stg_vm_tags
  protocol             = local.traffic_protocol_egress[count.index]
  ports                = [local.traffic_port_egress[count.index]]
  firewall_description = local.security_rule_description_egress[count.index]
}

#Creates compute instances
module "compute_cluster_instances" {
  count                         = local.cluster_type == "storage" || local.cluster_type == "combined" ? length(var.vpc_availability_zones) > 2 ? 2 : length(var.vpc_availability_zones) : 0
  source                        = "../../../resources/gcp/compute/vm_instance_multiple"
  zone                          = var.vpc_availability_zones[count.index]
  instances_ssh_public_key_path = var.instances_ssh_public_key_path
  instances_ssh_user_name       = var.instances_ssh_user_name
  total_cluster_instances       = var.total_compute_cluster_instances
  total_data_disks              = 0
  instance_name_prefix          = var.compute_instance_name_prefix
  machine_type                  = var.compute_machine_type
  subnet_name                   = var.vpc_compute_cluster_private_subnets
  private_key_content           = module.generate_compute_cluster_keys.private_key_content
  public_key_content            = module.generate_compute_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.compute_instance_tags
  boot_disk_size                = var.compute_boot_disk_size
  boot_disk_type                = var.compute_boot_disk_type
  boot_image                    = var.compute_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
}

module "storage_cluster_tie_breaker_instance" {
  count                         = local.cluster_type == "storage" || local.cluster_type == "combined" ? length(var.vpc_storage_cluster_private_subnets) > 1 ? (length(var.vpc_availability_zones) > 2 ? 1 : 0) : 0 : 0
  source                        = "../../../resources/gcp/compute/vm_instance_multiple"
  zone                          = var.vpc_availability_zones[2]
  instances_ssh_public_key_path = var.instances_ssh_public_key_path
  instances_ssh_user_name       = var.instances_ssh_user_name
  total_cluster_instances       = 1
  total_data_disks              = var.data_disks_per_instance
  instance_name_prefix          = format("%s-storage-tie", var.resource_prefix)
  machine_type                  = var.compute_machine_type
  subnet_name                   = var.vpc_storage_cluster_private_subnets != null ? length(var.vpc_storage_cluster_private_subnets) > 1 ? [var.vpc_storage_cluster_private_subnets[2]] : [] : []
  private_key_content           = module.generate_storage_cluster_keys.private_key_content
  public_key_content            = module.generate_storage_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.storage_instance_tags
  boot_disk_size                = var.storage_boot_disk_size
  boot_disk_type                = var.storage_boot_disk_type
  boot_image                    = var.storage_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
}

#Creates storage instances
module "storage_cluster_instances" {
  count                         = local.cluster_type == "storage" || local.cluster_type == "combined" ? length(var.vpc_availability_zones) > 2 ? 2 : length(var.vpc_availability_zones) : 0
  source                        = "../../../resources/gcp/compute/vm_instance_multiple"
  zone                          = var.vpc_availability_zones[count.index]
  instances_ssh_public_key_path = var.instances_ssh_public_key_path
  instances_ssh_user_name       = var.instances_ssh_user_name
  total_cluster_instances       = var.total_storage_cluster_instances
  total_data_disks              = var.data_disks_per_instance
  instance_name_prefix          = var.storage_instance_name_prefix
  machine_type                  = var.storage_machine_type
  subnet_name                   = var.vpc_storage_cluster_private_subnets
  private_key_content           = module.generate_storage_cluster_keys.private_key_content
  public_key_content            = module.generate_storage_cluster_keys.public_key_content
  operator_email                = var.operator_email
  scopes                        = var.scopes
  vm_instance_tags              = var.storage_instance_tags
  boot_disk_size                = var.storage_boot_disk_size
  boot_disk_type                = var.storage_boot_disk_type
  boot_image                    = var.storage_boot_image
  data_disk_type                = var.data_disk_type
  data_disk_size                = var.data_disk_size
}
