#    This nested module creates:
#    1. Storage cluster instances (with and without attached volumes)
#    2. Compute cluster instances
#    3. Protocol/CES nodes for NFS/SMB services
#    4. Gateway nodes for multi-cluster connectivity
#    5. Security groups and network configurations
#    6. DNS records for cluster nodes
#    7. SSH key pairs for instance access

# Create cluster security group
module "cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = true
  sec_group_name    = "${var.resource_prefix}-scale-sec-group"
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
}

# Create protocol/ces nodes specific security group
module "protocol_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.total_protocol_instances > 0
  sec_group_name    = "${var.resource_prefix}-protocol-sec-group"
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
}

# Create security rules to enable scale/gpfs traffic within compute/storage instances.
module "scale_cluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_sg"
  enable_rule              = true
  security_group_id        = module.cluster_security_group.sec_group_id
  sg_direction             = "inbound"
  source_security_group_id = module.cluster_security_group.sec_group_id
  rules = concat(
    [for port in local.tcp_port_scale_cluster : {
      protocol = "tcp"
      port_min = tonumber(port)
      port_max = tonumber(port)
    }],
    [{
      protocol = "tcp"
      port_min = local.gpfs_ephemeral_port_range.port_min
      port_max = local.gpfs_ephemeral_port_range.port_max
    }],
    [for port in local.udp_port_scale_cluster : {
      protocol = "udp"
      port_min = tonumber(port)
      port_max = tonumber(port)
    }],
    [{
      protocol = "icmp"
    }]
  )
}

# Create security rules to enable direct connection to scale cluster
module "scale_cluster_ingress_security_rule_using_direct_connection" {
  source            = "../../../resources/ibmcloud/security/security_rule"
  enable_rule       = var.using_direct_connection != null ? var.using_direct_connection : false
  security_group_id = module.cluster_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.client_ip_ranges
  rules = concat(
    [{
      protocol = "icmp"
    }],
    [{
      protocol = "tcp"
      port_min = 22
      port_max = 22
    }],
    [{
      protocol = "tcp"
      port_min = 443
      port_max = 443
    }],
    [{
      protocol = "tcp"
      port_min = 46443
      port_max = 46443
    }],
    [{
      protocol = "tcp"
      port_min = 9250
      port_max = 9250
    }]
  )
}

# Create security rules to enable jumphost communication to scale cluster
module "scale_cluster_ingress_security_rule_using_jumphost" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = var.using_jumphost_connection ? 1 : 0
  security_group_id        = [module.cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id]
}

# Create security rules to enable scale communication from cloud connection method
module "scale_cluster_ingress_security_rule_using_cloud_connection" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = var.using_cloud_connection ? 1 : 0
  security_group_id        = [module.cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.client_security_group_id]
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
  source                   = "../../../resources/ibmcloud/security/security_rule_sg"
  enable_rule              = var.total_protocol_instances > 0
  security_group_id        = module.protocol_security_group.sec_group_id
  sg_direction             = "inbound"
  source_security_group_id = module.protocol_security_group.sec_group_id
  rules = [for port in local.protocol_traffic_ports : {
    protocol = "tcp"
    port_min = port
    port_max = port
  }]
}

# Allow NFS clients to reach the CES IPs
module "protocol_nfs_ingress_security_rule" {
  source            = "../../../resources/ibmcloud/security/security_rule"
  enable_rule       = local.storage_and_protocol && var.ces_network_mode == "same_account"
  security_group_id = module.protocol_security_group.sec_group_id
  sg_direction      = "inbound"
  remote_ip_addr    = var.ces_client_cidr_blocks
  rules = concat(
    flatten([for protocol in ["tcp", "udp"] : [for ports in local.nfs_port_ranges : {
      protocol = protocol
      port_min = ports[0]
      port_max = ports[1]
    }]]),
    [{
      protocol = "icmp"
    }]
  )
}

module "protocol_cluster_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  enable_rule        = var.total_protocol_instances > 0
  security_group_ids = module.protocol_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = ["0.0.0.0/0"]
}

resource "ibm_is_ssh_key" "storage_ssh_key" {
  count          = local.storage_or_combined ? 1 : 0
  name           = "${var.resource_prefix}-storage-cluster-ssh-key"
  public_key     = trimspace(var.storage_cluster_public_key)
  resource_group = var.resource_group_id
  tags           = var.tags
}

resource "ibm_is_ssh_key" "compute_ssh_key" {
  count          = local.compute_or_combined ? 1 : 0
  name           = "${var.resource_prefix}-compute-cluster-ssh-key"
  public_key     = trimspace(var.compute_cluster_public_key)
  resource_group = var.resource_group_id
  tags           = var.tags
}

resource "ibm_is_placement_group" "storage_cluster" {
  count          = local.create_placement_group ? 1 : 0
  name           = "${var.resource_prefix}-storage-placement-group"
  strategy       = var.placement_group_strategy
  resource_group = var.resource_group_id
}

module "compute_cluster_instances" {
  for_each                          = local.compute_vm_subnet_map
  source                            = "../../../resources/ibmcloud/compute/vsi_0_vol"
  ami_id                            = var.compute_cluster_image_id
  dns_service_instance_id           = var.dns_service_instance_id
  dns_zone_id                       = var.vpc_compute_cluster_dns_zone_id
  dns_domain                        = var.vpc_compute_cluster_dns_domain
  instance_type                     = var.compute_cluster_instance_type
  name_prefix                       = each.key
  resource_group_id                 = var.resource_group_id
  root_device_kms_key_instance_id   = var.root_device_kms_key_id
  root_device_kms_key_instance_name = var.root_device_kms_key_name
  root_volume_type                  = var.boot_disk_type
  security_groups                   = var.using_jumphost_connection && var.bastion_security_group_id != null ? [module.cluster_security_group.sec_group_id, var.bastion_security_group_id] : [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.tags
  ssh_key_id                        = try(ibm_is_ssh_key.compute_ssh_key[0].id, null)
  vpc_id                            = var.vpc_id
  zone                              = var.vpc_availability_zones
  orchestrator_server               = var.orchestrator_server
  orchestrator_port                 = var.orchestrator_port
  orchestrator_workload_secret      = var.orchestrator_workload_secret
}

module "storage_cluster_instances" {
  for_each                          = local.storage_vm_zone_map
  source                            = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  ami_id                            = var.storage_cluster_image_id
  disks                             = each.value["disks"]
  dns_service_instance_id           = var.dns_service_instance_id
  dns_zone_id                       = var.vpc_storage_cluster_dns_zone_id
  dns_domain                        = var.vpc_storage_cluster_dns_domain
  instance_type                     = var.storage_cluster_instance_type
  name_prefix                       = each.key
  resource_group_id                 = var.resource_group_id
  placement_group                   = local.create_placement_group ? ibm_is_placement_group.storage_cluster[0].id : null
  root_device_kms_key_instance_id   = var.root_device_kms_key_id
  root_device_kms_key_instance_name = var.root_device_kms_key_name
  root_volume_type                  = var.boot_disk_type
  security_groups                   = var.using_jumphost_connection && var.bastion_security_group_id != null ? [module.cluster_security_group.sec_group_id, var.bastion_security_group_id] : [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.tags
  ssh_key_id                        = try(ibm_is_ssh_key.storage_ssh_key[0].id, null)
  vpc_id                            = var.vpc_id
  zone                              = each.value["zone"]
  attach_volumes                    = !var.operator_managed_volumes
  volume_tags                       = local.storage_volume_tags
  total_volume_bandwidth            = local.effective_storage_vol_bandwidth
  orchestrator_server               = var.orchestrator_server
  orchestrator_port                 = var.orchestrator_port
  orchestrator_workload_secret      = var.orchestrator_workload_secret
}

module "storage_cluster_tie_breaker_instance" {
  for_each                          = local.storage_tie_vm_zone_map
  source                            = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  ami_id                            = var.storage_cluster_image_id
  disks                             = each.value["disks"]
  dns_service_instance_id           = var.dns_service_instance_id
  dns_zone_id                       = var.vpc_storage_cluster_dns_zone_id
  dns_domain                        = var.vpc_storage_cluster_dns_domain
  instance_type                     = var.storage_cluster_tiebreaker_instance_type
  name_prefix                       = each.key
  resource_group_id                 = var.resource_group_id
  placement_group                   = local.create_placement_group ? ibm_is_placement_group.storage_cluster[0].id : null
  root_device_kms_key_instance_id   = var.root_device_kms_key_id
  root_device_kms_key_instance_name = var.root_device_kms_key_name
  root_volume_type                  = var.boot_disk_type
  security_groups                   = var.using_jumphost_connection && var.bastion_security_group_id != null ? [module.cluster_security_group.sec_group_id, var.bastion_security_group_id] : [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.tags
  ssh_key_id                        = try(ibm_is_ssh_key.storage_ssh_key[0].id, null)
  vpc_id                            = var.vpc_id
  zone                              = each.value["zone"]
  attach_volumes                    = !var.operator_managed_volumes
  volume_tags                       = local.storage_volume_tags
  total_volume_bandwidth            = null
  orchestrator_server               = var.orchestrator_server
  orchestrator_port                 = var.orchestrator_port
  orchestrator_workload_secret      = var.orchestrator_workload_secret
}

module "protocol_instances" {
  for_each                          = local.protocol_vm_subnet_map
  source                            = "../../../resources/ibmcloud/compute/vsi_ip_fwd"
  ami_id                            = var.storage_cluster_image_id
  dns_service_instance_id           = var.dns_service_instance_id
  dns_zone_id                       = coalesce(var.vpc_protocol_cluster_dns_zone_id, var.vpc_storage_cluster_dns_zone_id)
  dns_domain                        = coalesce(var.vpc_protocol_cluster_dns_domain, var.vpc_storage_cluster_dns_domain)
  instance_type                     = var.protocol_instance_type
  name_prefix                       = each.key
  resource_group_id                 = var.resource_group_id
  root_device_kms_key_instance_id   = var.root_device_kms_key_id
  root_device_kms_key_instance_name = var.root_device_kms_key_name
  root_volume_type                  = var.boot_disk_type
  security_groups                   = var.using_jumphost_connection && var.bastion_security_group_id != null ? [module.cluster_security_group.sec_group_id, var.bastion_security_group_id] : [module.cluster_security_group.sec_group_id]
  ces_security_groups               = [module.protocol_security_group.sec_group_id]
  subnet_id                         = each.value["base_subnet"]
  ces_subnet_id                     = each.value["ces_subnet"]
  ces_ip_cidr                       = var.ces_ip_cidr
  ces_network_mode                  = var.ces_network_mode
  ces_vni_id                        = each.value["ces_vni_id"]
  total_volume_bandwidth            = local.effective_protocol_vol_bandwidth
  tags                              = var.tags
  ssh_key_id                        = try(ibm_is_ssh_key.storage_ssh_key[0].id, null)
  vpc_id                            = var.vpc_id
  zone                              = each.value["zone"]
  orchestrator_server               = var.orchestrator_server
  orchestrator_port                 = var.orchestrator_port
  orchestrator_workload_secret      = var.orchestrator_workload_secret
}

data "ibm_is_vpc" "itself" {
  count      = length(local.ces_routes) > 0 ? 1 : 0
  identifier = var.vpc_id
}

# Route each CES IP to its protocol node's CES NIC
resource "ibm_is_vpc_routing_table_route" "ces" {
  for_each      = local.ces_routes
  vpc           = var.vpc_id
  routing_table = data.ibm_is_vpc.itself[0].default_routing_table
  name          = each.key
  zone          = each.value["zone"]
  destination   = format("%s/32", each.value["ip"])
  action        = "deliver"
  next_hop      = module.protocol_instances[each.value["vm_name"]].ces_nic_ip

  lifecycle {
    # CES failover updates next_hop
    ignore_changes = [next_hop]

    precondition {
      condition     = length(local.ces_routes) <= 200
      error_message = "CES IPs x zones exceeds 200, the routes-per-routing-table quota. Use fewer CES IPs."
    }
  }
}

# Round-robin DNS name for the CES IPs
resource "ibm_dns_resource_record" "ces_a" {
  for_each    = toset(local.ces_ips)
  instance_id = var.dns_service_instance_id
  zone_id     = coalesce(var.vpc_protocol_cluster_dns_zone_id, var.vpc_storage_cluster_dns_zone_id)
  type        = "A"
  name        = local.ces_dns_name
  rdata       = each.value
  ttl         = 300
}

resource "ibm_dns_resource_record" "ces_ptr" {
  for_each    = toset(local.ces_ips)
  instance_id = var.dns_service_instance_id
  zone_id     = coalesce(var.vpc_protocol_cluster_dns_zone_id, var.vpc_storage_cluster_dns_zone_id)
  type        = "PTR"
  name        = each.value
  rdata       = local.ces_dns_name
  ttl         = 300
  depends_on  = [ibm_dns_resource_record.ces_a]
}

module "gateway_instances" {
  for_each                          = local.gateway_vm_subnet_map
  source                            = "../../../resources/ibmcloud/compute/vsi_0_vol"
  ami_id                            = var.storage_cluster_image_id
  dns_service_instance_id           = var.dns_service_instance_id
  dns_zone_id                       = var.vpc_storage_cluster_dns_zone_id
  dns_domain                        = var.vpc_storage_cluster_dns_domain
  instance_type                     = var.gateway_instance_type
  name_prefix                       = each.key
  resource_group_id                 = var.resource_group_id
  root_device_kms_key_instance_id   = var.root_device_kms_key_id
  root_device_kms_key_instance_name = var.root_device_kms_key_name
  root_volume_type                  = var.boot_disk_type
  security_groups                   = [module.cluster_security_group.sec_group_id]
  subnet_id                         = each.value["subnet"]
  tags                              = var.tags
  ssh_key_id                        = try(ibm_is_ssh_key.storage_ssh_key[0].id, null)
  vpc_id                            = var.vpc_id
  zone                              = var.vpc_availability_zones
  orchestrator_server               = var.orchestrator_server
  orchestrator_port                 = var.orchestrator_port
  orchestrator_workload_secret      = var.orchestrator_workload_secret
}
