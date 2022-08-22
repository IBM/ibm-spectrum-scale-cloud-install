/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

locals {
  gpfs_base_rpm_path = fileset(var.spectrumscale_rpms_path, "gpfs.base-*")
  scale_version      = regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0]
}

locals {
  compute_instance_image_id = var.compute_vsi_osimage_id != "" ? var.compute_vsi_osimage_id : data.ibm_is_image.compute_instance_image[0].id
  storage_instance_image_id = var.storage_vsi_osimage_id != "" ? var.storage_vsi_osimage_id : data.ibm_is_image.storage_instance_image[0].id
  storage_bare_metal_image_id = var.storage_bare_metal_osimage_id != "" ? var.storage_bare_metal_osimage_id : data.ibm_is_image.storage_bare_metal_image[0].id
}


module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances > 0 ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances > 0 ? true : false
}

module "deploy_security_group" {
  source                = "../../../resources/ibmcloud/security/security_group"
  turn_on               = var.deploy_controller_sec_group_id == null ? true : false
  sec_group_name        = ["Deploy-Sec-group"]
  vpc_id                = var.vpc_id
  resource_group_id     = var.resource_group_id
  resource_tags         = var.scale_cluster_resource_tags
}

locals {
  deploy_sec_group_id = var.deploy_controller_sec_group_id == null ? module.deploy_security_group.sec_group_id : var.deploy_controller_sec_group_id
}

module "compute_cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.total_compute_cluster_instances > 0 ? true : false
  sec_group_name    = [format("%s-compute-sg", var.resource_prefix)]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

# FIXME - Fine grain port inbound is needed, but hits limitation of 5 rules
module "compute_cluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_compute_cluster_instances > 0 && var.using_direct_connection == false) ? 3 : 0
  security_group_id        = [module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.compute_cluster_security_group.sec_group_id]
}

module "compute_cluster_ingress_security_rule_wt_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_compute_cluster_instances > 0 && var.using_direct_connection == true && var.deploy_controller_sec_group_id != null) ? 3 : 0
  security_group_id        = [module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.compute_cluster_security_group.sec_group_id]
}

module "compute_cluster_ingress_security_rule_wo_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_compute_cluster_instances > 0 && var.using_direct_connection == true && var.deploy_controller_sec_group_id == null) ? 2 : 0
  security_group_id        = [module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [local.deploy_sec_group_id, module.compute_cluster_security_group.sec_group_id]
}

module "compute_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  turn_on            = var.total_compute_cluster_instances > 0 ? true : false
  security_group_ids = module.compute_cluster_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "storage_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  turn_on            = var.total_storage_cluster_instances > 0 ? true : false
  security_group_ids = module.storage_cluster_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "storage_cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.total_storage_cluster_instances > 0 ? true : false
  sec_group_name    = [format("%s-storage-sg", var.resource_prefix)]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

module "storage_cluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.using_direct_connection == false) ? 3 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "storage_cluster_ingress_security_rule_wt_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.using_direct_connection == true && var.deploy_controller_sec_group_id != null) ? 3 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "storage_cluster_ingress_security_rule_wo_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.using_direct_connection == true && var.deploy_controller_sec_group_id == null) ? 2 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [local.deploy_sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "bicluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.total_compute_cluster_instances > 0) ? 2 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound", "inbound"]
  source_security_group_id = [module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

data "ibm_is_ssh_key" "compute_ssh_key" {
  name = var.compute_cluster_key_pair
}

data "ibm_is_instance_profile" "compute_profile" {
  name = var.compute_vsi_profile
}

data "ibm_is_image" "compute_instance_image" {
  name = var.compute_vsi_osimage_name
  count = var.compute_vsi_osimage_id != "" ? 0 : 1
}

module "compute_cluster_instances" {
  source               = "../../../resources/ibmcloud/compute/vsi_0_vol"
  total_vsis           = var.total_compute_cluster_instances
  vsi_name_prefix      = format("%s-compute", var.resource_prefix)
  vpc_id               = var.vpc_id
  resource_group_id    = var.resource_group_id
  zones                = [var.vpc_availability_zones[0]]
  vsi_image_id         = local.compute_instance_image_id
  vsi_profile          = var.compute_vsi_profile
  dns_domain           = var.vpc_compute_cluster_dns_domain
  dns_service_id       = var.vpc_compute_cluster_dns_service_id
  dns_zone_id          = var.vpc_compute_cluster_dns_zone_id
  vsi_subnet_id        = length(var.vpc_compute_cluster_private_subnets) == 0 ? var.vpc_storage_cluster_private_subnets : var.vpc_compute_cluster_private_subnets
  vsi_security_group   = [module.compute_cluster_security_group.sec_group_id]
  vsi_user_public_key  = [data.ibm_is_ssh_key.compute_ssh_key.id]
  vsi_meta_private_key = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key  = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  depends_on           = [module.compute_cluster_ingress_security_rule, module.compute_cluster_ingress_security_rule_wt_bastion, module.compute_cluster_ingress_security_rule_wo_bastion, module.compute_egress_security_rule, var.vpc_custom_resolver_id]
  resource_tags        = var.scale_cluster_resource_tags
}

data "ibm_is_instance_profile" "storage_profile" {
  name = var.storage_vsi_profile
}

data "ibm_is_bare_metal_server_profile" "storage_bare_metal_server_profile" {
  name = var.storage_bare_metal_server_profile
}

data "ibm_is_ssh_key" "storage_ssh_key" {
  name = var.storage_cluster_key_pair
}

data "ibm_is_image" "storage_instance_image" {
  name = var.storage_vsi_osimage_name
  count = var.storage_vsi_osimage_id != "" ? 0:1
}

data "ibm_is_image" "storage_bare_metal_image" {
  name = var.storage_bare_metal_osimage_name
  count = var.storage_bare_metal_osimage_id != "" ? 0:1
}

resource "time_sleep" "wait_300_seconds" {
  depends_on = [module.storage_cluster_security_group]
  destroy_duration = "300s"
}

module "storage_cluster_instances" {
  count = var.storage_type == "scratch" ? 1 : 0
  source               = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  total_vsis           = var.total_storage_cluster_instances
  vsi_name_prefix      = format("%s-storage", var.resource_prefix)
  vpc_id               = var.vpc_id
  resource_group_id    = var.resource_group_id
  zones                = [var.vpc_availability_zones[0]]
  vsi_image_id         = local.storage_instance_image_id
  vsi_profile          = var.storage_vsi_profile
  dns_domain           = var.vpc_storage_cluster_dns_domain
  dns_service_id       = var.vpc_storage_cluster_dns_service_id
  dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id        = var.vpc_storage_cluster_private_subnets
  vsi_security_group   = [module.storage_cluster_security_group.sec_group_id]
  vsi_user_public_key  = [data.ibm_is_ssh_key.storage_ssh_key.id]
  vsi_meta_private_key = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key  = module.generate_storage_cluster_keys.public_key_content
  depends_on           = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
  resource_tags        = var.scale_cluster_resource_tags
}

module "storage_cluster_bare_metal_server" {
  count = var.storage_type == "scratch" ? 0 : 1
  source = "../../../resources/ibmcloud/compute/bare_metal_server_multiple_vol"
  total_vsis = var.total_storage_cluster_instances
  vsi_name_prefix      = format("%s-storage-baremetal", var.resource_prefix)
  vpc_id               = var.vpc_id
  resource_group_id    = var.resource_group_id
  zones                = [var.vpc_availability_zones[0]]
  vsi_image_id         = local.storage_bare_metal_image_id
  vsi_profile          = var.storage_bare_metal_server_profile
  dns_domain           = var.vpc_storage_cluster_dns_domain
  dns_service_id       = var.vpc_storage_cluster_dns_service_id
  dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id        = var.vpc_storage_cluster_private_subnets
  vsi_security_group   = [module.storage_cluster_security_group.sec_group_id]
  vsi_user_public_key  = [data.ibm_is_ssh_key.storage_ssh_key.id]
  vsi_meta_private_key = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key  = module.generate_storage_cluster_keys.public_key_content
  resource_tags        = var.scale_cluster_resource_tags
  depends_on           = [module.storage_cluster_ingress_security_rule, var.vpc_custom_resolver_id, module.storage_egress_security_rule,time_sleep.wait_300_seconds]
}

module "storage_cluster_tie_breaker_instance" {
  source               = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  total_vsis           = (length(var.vpc_storage_cluster_private_subnets) > 1 && var.total_storage_cluster_instances > 0) ? 1 : 0
  vsi_name_prefix      = format("%s-storage-tie", var.resource_prefix)
  vpc_id               = var.vpc_id
  resource_group_id    = var.resource_group_id
  zones                = [var.vpc_availability_zones[0]]
  vsi_image_id         = local.storage_instance_image_id
  vsi_profile          = var.storage_vsi_profile
  dns_domain           = var.vpc_storage_cluster_dns_domain
  dns_service_id       = var.vpc_storage_cluster_dns_service_id
  dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id        = var.vpc_storage_cluster_private_subnets
  vsi_security_group   = [module.storage_cluster_security_group.sec_group_id]
  vsi_user_public_key  = [data.ibm_is_ssh_key.storage_ssh_key.id]
  vsi_meta_private_key = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key  = module.generate_storage_cluster_keys.public_key_content
  depends_on           = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
  resource_tags        = var.scale_cluster_resource_tags
}

module "activity_tracker" {
  source                 = "../../../resources/ibmcloud/resource_instance"
  service_count          = var.vpc_create_activity_tracker == true ? 1 : 0
  resource_instance_name = [format("%s-activity_track", var.resource_prefix)]
  resource_group_id      = var.resource_group_id
  service_name           = "logdnaat"
  plan_type              = var.activity_tracker_plan_type
  target_location        = var.vpc_region
  resource_tags          = var.scale_cluster_resource_tags
}

module "prepare_ansible_configuration" {
  source     = "../../../resources/common/git_utils"
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

module "write_compute_cluster_inventory" {
  source                                    = "../../../resources/common/write_inventory"
  write_inventory                           = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? 1 : 0
  clone_complete                            = module.prepare_ansible_configuration.clone_complete
  inventory_path                            = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("IBMCloud")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vpc_region)
  vpc_availability_zones                    = jsonencode(var.vpc_availability_zones)
  scale_version                             = jsonencode(local.scale_version)
  filesystem_block_size                     = jsonencode("None")
  compute_cluster_filesystem_mountpoint     = jsonencode(var.compute_cluster_filesystem_mountpoint)
  bastion_instance_id                       = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids              = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips      = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint     = jsonencode("None")
  storage_cluster_instance_ids              = jsonencode([])
  storage_cluster_instance_private_ips      = jsonencode([])
  storage_cluster_with_data_volume_mapping  = jsonencode({})
  storage_cluster_desc_instance_ids         = jsonencode([])
  storage_cluster_desc_instance_private_ips = jsonencode([])
  storage_cluster_desc_data_volume_mapping  = jsonencode({})
}

module "write_storage_cluster_inventory" {
  source                                    = "../../../resources/common/write_inventory"
  write_inventory                           = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? 1 : 0
  clone_complete                            = module.prepare_ansible_configuration.clone_complete
  inventory_path                            = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("IBMCloud")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vpc_region)
  vpc_availability_zones                    = jsonencode(var.vpc_availability_zones)
  scale_version                             = jsonencode(local.scale_version)
  filesystem_block_size                     = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint     = jsonencode("None")
  bastion_instance_id                       = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids              = jsonencode([])
  compute_cluster_instance_private_ips      = jsonencode([])
  storage_cluster_filesystem_mountpoint     = jsonencode(var.storage_cluster_filesystem_mountpoint)
   storage_cluster_instance_ids              = var.storage_type != "scratch" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ids)) :jsonencode(one(module.storage_cluster_instances[*].instance_ids))
  storage_cluster_instance_private_ips      = var.storage_type != "scratch" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_private_ips)) : jsonencode(one(module.storage_cluster_instances[*].instance_private_ips))
  storage_cluster_with_data_volume_mapping  = var.storage_type != "scratch" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ips_with_vol_mapping)) :jsonencode(one(module.storage_cluster_instances[*].instance_ips_with_vol_mapping))
  storage_cluster_desc_instance_ids         = jsonencode(module.storage_cluster_tie_breaker_instance.instance_ids)
  storage_cluster_desc_instance_private_ips = jsonencode(module.storage_cluster_tie_breaker_instance.instance_private_ips)
  storage_cluster_desc_data_volume_mapping  = jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_vol_mapping)
}

module "write_cluster_inventory" {
  source                                    = "../../../resources/common/write_inventory"
  write_inventory                           = var.create_separate_namespaces == false ? 1 : 0
  clone_complete                            = module.prepare_ansible_configuration.clone_complete
  inventory_path                            = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("IBMCloud")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vpc_region)
  vpc_availability_zones                    = jsonencode(var.vpc_availability_zones)
  scale_version                             = jsonencode(local.scale_version)
  filesystem_block_size                     = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint     = jsonencode("None")
  bastion_instance_id                       = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids              = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips      = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint     = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids              = var.storage_type != "scratch" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ids)) :jsonencode(one(module.storage_cluster_instances[*].instance_ids))
  storage_cluster_instance_private_ips      = var.storage_type != "scratch" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_private_ips)) : jsonencode(one(module.storage_cluster_instances[*].instance_private_ips))
  storage_cluster_with_data_volume_mapping  = var.storage_type != "scratch" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ips_with_vol_mapping)) :jsonencode(one(module.storage_cluster_instances[*].instance_ips_with_vol_mapping))
  storage_cluster_desc_instance_ids         = length(var.vpc_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_ids) : jsonencode([])
  storage_cluster_desc_instance_private_ips = length(var.vpc_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_private_ips) : jsonencode([])
  storage_cluster_desc_data_volume_mapping  = length(var.vpc_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_vol_mapping) : jsonencode({})
}

module "compute_cluster_configuration" {
  source                       = "../../../resources/common/compute_configuration"
  turn_on                      = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_compute_cluster_inventory.write_inventory_complete
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  using_rest_initialization    = var.using_rest_api_remote_mount
  compute_cluster_gui_username = var.compute_cluster_gui_username
  compute_cluster_gui_password = var.compute_cluster_gui_password
  memory_size                  = data.ibm_is_instance_profile.compute_profile.memory[0].value * 1000
  max_pagepool_gb              = 4
  bastion_instance_public_ip   = var.bastion_instance_public_ip
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  meta_private_key             = module.generate_compute_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
}

module "storage_cluster_configuration" {
  source                       = "../../../resources/common/storage_configuration"
  turn_on                      = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_storage_cluster_inventory.write_inventory_complete
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  using_rest_initialization    = true
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = var.storage_type != "scratch" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile.memory[0].value * 1000 : data.ibm_is_instance_profile.storage_profile.memory[0].value * 1000
  max_pagepool_gb              = var.storage_type != "scratch" ? 32 : 16
  vcpu_count                   = var.storage_type != "scratch" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile.cpu_socket_count[0].value : data.ibm_is_instance_profile.storage_profile.vcpu_count[0].value
  bastion_instance_public_ip   = var.bastion_instance_public_ip
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
}

module "combined_cluster_configuration" {
  source                       = "../../../resources/common/scale_configuration"
  turn_on                      = var.create_separate_namespaces == false ? true : false
  clone_complete               = module.prepare_ansible_configuration.clone_complete
  write_inventory_complete     = module.write_cluster_inventory.write_inventory_complete
  create_scale_cluster         = var.create_scale_cluster
  clone_path                   = var.scale_ansible_repo_clone_path
  inventory_path               = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image           = var.using_packer_image
  using_direct_connection      = var.using_direct_connection
  storage_cluster_gui_username = var.storage_cluster_gui_username
  storage_cluster_gui_password = var.storage_cluster_gui_password
  memory_size                  = var.storage_type != "scratch" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile.memory[0].value : data.ibm_is_instance_profile.storage_profile.memory[0].value
  bastion_instance_public_ip   = var.bastion_instance_public_ip
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  meta_private_key             = module.generate_storage_cluster_keys.private_key_content
  scale_version                = local.scale_version
  spectrumscale_rpms_path      = var.spectrumscale_rpms_path
}

module "remote_mount_configuration" {
  source                          = "../../../resources/common/remote_mount_configuration"
  turn_on                         = (var.total_compute_cluster_instances > 0 && var.total_storage_cluster_instances > 0 && var.create_separate_namespaces == true) ? true : false
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  compute_inventory_path          = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  compute_gui_inventory_path      = format("%s/compute_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  storage_inventory_path          = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  storage_gui_inventory_path      = format("%s/storage_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  using_direct_connection         = var.using_direct_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
}
