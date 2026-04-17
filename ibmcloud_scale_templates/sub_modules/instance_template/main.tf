/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

data "ibm_resource_group" "itself" {
  name = var.resource_group_name
}

# VPC reference - vpc_ref should be the VPC ID
locals {
  vpc_id = var.vpc_ref
}

# Get all zones in a DNS Services instance (only if service_instance_ref is provided)
data "ibm_dns_zones" "all" {
  count       = var.service_instance_ref != null && var.service_instance_ref != "" ? 1 : 0
  instance_id = var.service_instance_ref
}

data "ibm_is_instance_profile" "storage_profile" {
  count = local.storage_or_combined ? 1 : 0
  name  = var.storage_cluster_instance_type
}

data "ibm_is_instance_profile" "compute_profile" {
  count = local.compute_or_combined ? 1 : 0
  name  = var.compute_cluster_instance_type
}

locals {
  # Disk list associated with the instance
  disks = local.storage_or_combined ? try(data.ibm_is_instance_profile.storage_profile[0].disks, []) : []

  # Get the disk quantity or value
  disk_quantities = [
    for d in local.disks :
    tonumber(coalesce(try(d.quantity[0].value, null), try(d.quantity[0].default, null), 0))
  ]

  # Count the total disk count
  local_block_device_count = length(local.disks) > 0 ? sum(local.disk_quantities) : 0
}

# Extract the zone_id for a specific zone name
locals {
  dns_zones_available = length(data.ibm_dns_zones.all) > 0 ? data.ibm_dns_zones.all[0].dns_zones : []

  forward_zone = length(local.dns_zones_available) > 0 ? one([
    for z in local.dns_zones_available : z
    if z.name == var.vpc_storage_cluster_dns_domain
  ]) : null

  forward_compute_zone = length(local.dns_zones_available) > 0 ? one([
    for z in local.dns_zones_available : z
    if z.name == var.vpc_compute_cluster_dns_domain
  ]) : null

  /*
  reverse_zone = one([
    for z in data.ibm_dns_zones.all.dns_zones : z
    if z.name == var.vpc_reverse_dns_domain
  ])
*/
}

locals {
  storage_pub_path            = var.storage_cluster_public_key_path
  storage_priv_path           = trimsuffix(local.storage_pub_path, ".pub")
  storage_private_key_content = can(file(local.storage_priv_path)) ? file(local.storage_priv_path) : null

  compute_pub_path            = var.compute_cluster_public_key_path
  compute_priv_path           = trimsuffix(local.compute_pub_path, ".pub")
  compute_private_key_content = can(file(local.compute_priv_path)) ? file(local.compute_priv_path) : null
}

# Create cluster security group
module "cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = "${var.resource_prefix}-scale-sec-group"
  vpc_id            = local.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
}

# Create protocol/ces nodes specific security group
module "protocol_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.total_protocol_instances > 0 ? true : false
  sec_group_name    = "${var.resource_prefix}-protocol-sec-group"
  vpc_id            = local.vpc_id
  resource_group_id = data.ibm_resource_group.itself.id
}

# Create security rules to enable scale/gpfs traffic within compute/storage instances.
module "scale_cluster_ingress_tcp_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_tcp_rule"
  enable_rule       = length(local.tcp_port_scale_cluster) > 0 ? true : false
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  port              = local.tcp_port_scale_cluster
  remote_ip_addr    = module.cluster_security_group.sec_group_id
}

module "scale_cluster_ingress_udp_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_udp_rule"
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  port              = local.udp_port_scale_cluster
  remote_ip_addr    = module.cluster_security_group.sec_group_id
}

module "scale_cluster_ingress_icmp_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_icmp_rule"
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = module.cluster_security_group.sec_group_id
}

# Create security rules to enable jumphost communication to scale cluster
module "scale_cluster_ingress_security_rule_using_jumphost" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = var.using_jumphost_connection ? 1 : 0
  security_group_id        = [module.cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_ref]
}

# Create security rule to enable scale cluster egress communication
module "scale_cluster_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  enable_rule        = true
  security_group_ids = module.cluster_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = ["0.0.0.0/0"]
}

module "protocol_cluster_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_tcp_rule"
  enable_rule       = var.total_protocol_instances > 0 ? true : false
  security_group_id = module.protocol_security_group.sec_group_id
  sg_direction      = "inbound"
  port              = local.protocol_traffic_ports
  remote_ip_addr    = module.protocol_security_group.sec_group_id
}

module "protocol_cluster_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  enable_rule       = var.total_protocol_instances > 0 ? true : false
  security_group_ids = module.protocol_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = ["0.0.0.0/0"]
}

# Create ssh key to access the scale storage instance
resource "ibm_is_ssh_key" "storage_ssh_key" {
  count = local.storage_or_combined ? 1 : 0
  name  = "${var.resource_prefix}-storage-cluster-ssh-key"
  #public_key = module.generate_storage_cluster_keys.public_key_content
  public_key = file(var.storage_cluster_public_key_path)
}

# Create ssh key to access the scale compute instance
resource "ibm_is_ssh_key" "compute_ssh_key" {
  count = local.compute_or_combined ? 1 : 0
  name  = "${var.resource_prefix}-compute-cluster-ssh-key"
  #public_key = module.generate_storage_cluster_keys.public_key_content
  public_key = file(var.compute_cluster_public_key_path)
}

resource "ibm_is_placement_group" "storage_cluster" {
  count    = local.create_placement_group ? 1 : 0
  name     = "${var.resource_prefix}-storage-placement-group"
  strategy = "host_spread"
}

module "compute_cluster_instances" {
  for_each                 = local.compute_vm_subnet_map
  source                   = "../../../resources/ibmcloud/compute/vsi_0_vol"
  ami_id                   = var.compute_cluster_image_ref
  dns_domain               = var.vpc_compute_cluster_dns_domain
  dns_services_instance_id = var.service_instance_ref
  forward_dns_zone         = var.vpc_compute_cluster_dns_domain
  forward_dns_zone_id      = local.forward_compute_zone != null ? local.forward_compute_zone.zone_id : ""
  instance_type            = var.compute_cluster_instance_type
  name_prefix              = each.key
  placement_group          = null
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.compute_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.compute_cluster_tags
  user_public_key                   = ibm_is_ssh_key.compute_ssh_key[0].id
  volume_tags                       = var.compute_cluster_volume_tags
  vpc_id                            = local.vpc_id
  zone                              = var.vpc_availability_zones
}

module "storage_cluster_instances" {
  for_each                 = local.storage_vm_zone_map
  source                   = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  ami_id                   = var.storage_cluster_image_ref
  disks                    = each.value["disks"]
  dns_domain               = var.vpc_storage_cluster_dns_domain
  dns_services_instance_id = var.service_instance_ref
  forward_dns_zone         = var.vpc_storage_cluster_dns_domain
  forward_dns_zone_id      = local.forward_zone != null ? local.forward_zone.zone_id : ""
  instance_type            = var.storage_cluster_instance_type
  name_prefix              = each.key
  placement_group          = local.create_placement_group ? ibm_is_placement_group.storage_cluster[0].id : null
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.storage_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.storage_cluster_tags
  user_public_key                   = ibm_is_ssh_key.storage_ssh_key[0].id
  volume_tags                       = var.storage_cluster_volume_tags
  vpc_id                            = local.vpc_id
  zone                              = each.value["zone"]
}

module "storage_cluster_tie_breaker_instance" {
  for_each                 = local.storage_tie_vm_zone_map
  source                   = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  ami_id                   = var.storage_cluster_image_ref
  disks                    = each.value["disks"]
  dns_domain               = var.vpc_storage_cluster_dns_domain
  dns_services_instance_id = var.service_instance_ref
  forward_dns_zone         = var.vpc_storage_cluster_dns_domain
  forward_dns_zone_id      = local.forward_zone != null ? local.forward_zone.zone_id : ""
  instance_type            = var.storage_cluster_tiebreaker_instance_type
  name_prefix              = each.key
  placement_group          = local.create_placement_group ? ibm_is_placement_group.storage_cluster[0].id : null
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.storage_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.storage_cluster_tags
  user_public_key                   = ibm_is_ssh_key.storage_ssh_key[0].id
  volume_tags                       = var.storage_cluster_volume_tags
  vpc_id                            = local.vpc_id
  zone                              = each.value["zone"]
}

module "protocol_instances" {
  for_each                          = local.protocol_vm_subnet_map
  source                            = "../../../resources/ibmcloud/compute/vsi_ip_fwd"
  ami_id                            = var.storage_cluster_image_ref
  dns_domain                        = var.vpc_storage_cluster_dns_domain
  dns_services_instance_id          = var.service_instance_ref
  forward_dns_zone                  = var.vpc_storage_cluster_dns_domain
  forward_dns_zone_id               = local.forward_zone != null ? local.forward_zone.zone_id : ""
  instance_type                     = var.protocol_instance_type
  name_prefix                       = each.key
  placement_group                   = local.create_placement_group ? ibm_is_placement_group.storage_cluster[0].id : null
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  security_groups                   = [module.cluster_security_group.sec_group_id, module.protocol_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  ces_ipaddress                     = each.value["ces_ip_address"]
  tags                              = var.protocol_tags
  user_public_key                   = ibm_is_ssh_key.storage_ssh_key[0].id
  volume_tags                       = var.protocol_volume_tags
  vpc_id                            = local.vpc_id
  zone                              = each.value["zone"]
}

module "gateway_instances" {
  for_each                          = local.gateway_vm_subnet_map
  source                            = "../../../resources/ibmcloud/compute/vsi_0_vol"
  ami_id                            = var.storage_cluster_image_ref
  dns_domain                        = var.vpc_storage_cluster_dns_domain
  dns_services_instance_id          = var.service_instance_ref
  forward_dns_zone                  = var.vpc_storage_cluster_dns_domain
  forward_dns_zone_id               = local.forward_zone != null ? local.forward_zone.zone_id : ""
  instance_type                     = var.gateway_instance_type
  name_prefix                       = each.key
  placement_group                   = null
  root_device_encrypted             = var.root_device_encrypted
  root_device_kms_key_instance_id   = var.root_device_kms_key_ref
  root_device_kms_key_instance_name = var.root_device_kms_key_ref_name
  root_volume_type                  = var.storage_cluster_boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.gateway_tags
  user_public_key                   = ibm_is_ssh_key.storage_ssh_key[0].id
  volume_tags                       = var.gateway_volume_tags
  vpc_id                            = local.vpc_id
  zone                              = var.vpc_availability_zones
}
