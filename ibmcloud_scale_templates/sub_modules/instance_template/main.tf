/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

locals {
  gpfs_base_rpm_path = fileset(var.spectrumscale_rpms_path, "gpfs.base-*")
  scale_org_version  = regex("gpfs.base-(.*).x86_64.rpm", tolist(local.gpfs_base_rpm_path)[0])[0]
  scale_version      = replace(local.scale_org_version, "-", ".")
}

locals {
  compute_instance_image_id   = var.compute_vsi_osimage_id != "" ? var.compute_vsi_osimage_id : data.ibm_is_image.compute_instance_image[0].id
  storage_instance_image_id   = var.storage_vsi_osimage_id != "" ? var.storage_vsi_osimage_id : data.ibm_is_image.storage_instance_image[0].id
  storage_bare_metal_image_id = var.storage_bare_metal_osimage_id != "" ? var.storage_bare_metal_osimage_id : data.ibm_is_image.storage_bare_metal_image[0].id
  gklm_instance_image_id      = var.gklm_vsi_osimage_id != "" ? var.gklm_vsi_osimage_id : data.ibm_is_image.gklm_instance_image[0].id
  ldap_instance_image_id      = var.enable_ldap == true && var.ldap_server == "null" ? data.ibm_is_image.ldap_instance_image[0].id : null
}

# Getting bandwidth of compute and storage vsi and based on that checking mrot will be enabled or not.
locals {
  scale_ces_enabled            = var.total_protocol_cluster_instances > 0 ? true : false
  is_colocate_protocol_subset  = local.scale_ces_enabled && var.colocate_protocol_cluster_instances ? var.total_protocol_cluster_instances < var.total_storage_cluster_instances ? true : false : false
  enable_sec_interface_compute = local.scale_ces_enabled == false && data.ibm_is_instance_profile.compute_profile.bandwidth[0].value >= 64000 ? true : false
  enable_sec_interface_storage = local.scale_ces_enabled == false && var.storage_type != "persistent" && data.ibm_is_instance_profile.storage_profile.bandwidth[0].value >= 64000 ? true : false
  enable_mrot_conf             = local.enable_sec_interface_compute && local.enable_sec_interface_storage ? true : false
  ldap_server                  = var.enable_ldap == true && var.ldap_server == "null" ? jsonencode(one(module.ldap_instance[*].vsi_private_ip)) : var.ldap_server
  enable_afm                   = var.total_afm_cluster_instances > 0 ? true : false
  afm_server_type              = strcontains(var.afm_vsi_profile, "metal")
  ces_server_type              = strcontains(var.protocol_vsi_profile, "metal")
  existing_strg_sg_id          = var.strg_sg_id != null ? [var.strg_sg_id] : [module.storage_cluster_security_group.sec_group_id]
  existing_comp_sg_id          = var.comp_sg_id != null ? [var.comp_sg_id] : [module.compute_cluster_security_group.sec_group_id]
  existing_gklm_sg_id          = var.gklm_sg_id != null ? [var.gklm_sg_id] : [module.gklm_instance_security_group.sec_group_id]
  existing_ldap_sg_id          = var.ldap_sg_id != null ? [var.ldap_sg_id] : [module.ldap_instance_security_group.sec_group_id]
}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances > 0 ? true : false
}

module "generate_client_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_client_cluster_instances > 0 ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances > 0 ? true : false
}

module "generate_gklm_instance_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? true : false
}

module "generate_ldap_instance_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.enable_ldap && var.ldap_server == "null"
}

module "deploy_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.deploy_controller_sec_group_id == null ? true : false
  sec_group_name    = ["Deploy-Sec-group"]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

locals {
  deploy_sec_group_id = var.deploy_controller_sec_group_id == null ? module.deploy_security_group.sec_group_id : var.deploy_controller_sec_group_id
}

module "compute_cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = (var.total_client_cluster_instances > 0 || var.total_compute_cluster_instances > 0) && var.comp_sg_id == null ? true : false
  sec_group_name    = [format("%s-compute-sg", var.resource_prefix)]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

# FIXME - Fine grain port inbound is needed, but hits limitation of 5 rules
module "compute_cluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = ((var.total_client_cluster_instances > 0 || var.total_compute_cluster_instances > 0) && var.using_jumphost_connection == false && var.comp_sg_id == null) ? 3 : 0
  security_group_id        = [module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.compute_cluster_security_group.sec_group_id]
}

module "compute_cluster_ingress_security_rule_wt_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = ((var.total_client_cluster_instances > 0 || var.total_compute_cluster_instances > 0) && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id != null && var.comp_sg_id == null) ? 3 : 0
  security_group_id        = [module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.compute_cluster_security_group.sec_group_id]
}

module "compute_cluster_ingress_security_rule_wo_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = ((var.total_client_cluster_instances > 0 || var.total_compute_cluster_instances > 0) && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id == null && var.comp_sg_id == null) ? 2 : 0
  security_group_id        = [module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [local.deploy_sec_group_id, module.compute_cluster_security_group.sec_group_id]
}

module "compute_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  turn_on            = (var.total_client_cluster_instances > 0 || var.total_compute_cluster_instances > 0) && var.comp_sg_id == null ? true : false
  security_group_ids = module.compute_cluster_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "storage_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  turn_on            = var.total_storage_cluster_instances > 0 && var.strg_sg_id == null ? true : false
  security_group_ids = module.storage_cluster_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "gklm_instance_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  turn_on            = (var.scale_encryption_enabled && var.scale_encryption_type == "gklm" && var.gklm_sg_id == null) ? true : false
  security_group_ids = module.gklm_instance_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "ldap_instance_egress_security_rule" {
  source             = "../../../resources/ibmcloud/security/security_allow_all"
  turn_on            = var.enable_ldap && var.ldap_server == "null" && var.ldap_sg_id == null
  security_group_ids = module.ldap_instance_security_group.sec_group_id
  sg_direction       = "outbound"
  remote_ip_addr     = "0.0.0.0/0"
}

module "storage_cluster_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.total_storage_cluster_instances > 0 && var.strg_sg_id == null ? true : false
  sec_group_name    = [format("%s-storage-sg", var.resource_prefix)]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

module "storage_cluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.using_jumphost_connection == false && var.strg_sg_id == null) ? 3 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "storage_cluster_ingress_security_rule_wt_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id != null && var.strg_sg_id == null) ? 3 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "storage_cluster_ingress_security_rule_wo_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id == null && var.strg_sg_id == null) ? 2 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [local.deploy_sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "bicluster_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.total_storage_cluster_instances > 0 && (var.total_client_cluster_instances > 0 || var.total_compute_cluster_instances > 0) && var.strg_sg_id == null) ? 2 : 0
  security_group_id        = [module.storage_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id]
  sg_direction             = ["inbound", "inbound"]
  source_security_group_id = [module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "gklm_instance_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.scale_encryption_enabled && var.scale_encryption_type == "gklm" && var.gklm_sg_id == null ? true : false
  sec_group_name    = [format("%s-gklm-sg", var.resource_prefix)]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

module "gklm_instance_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" && var.using_jumphost_connection == false && var.gklm_sg_id == null) ? 5 : 0
  security_group_id        = [module.gklm_instance_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.gklm_instance_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "gklm_instance_ingress_security_rule_wt_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id != null && var.gklm_sg_id == null) ? 5 : 0
  security_group_id        = [module.gklm_instance_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.gklm_instance_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "gklm_instance_ingress_security_rule_wo_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id == null && var.gklm_sg_id == null) ? 4 : 0
  security_group_id        = [module.gklm_instance_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [local.deploy_sec_group_id, module.gklm_instance_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "ldap_instance_security_group" {
  source            = "../../../resources/ibmcloud/security/security_group"
  turn_on           = var.enable_ldap && var.ldap_server == "null" && var.ldap_sg_id == null
  sec_group_name    = [format("%s-ldap-sg", var.resource_prefix)]
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  resource_tags     = var.scale_cluster_resource_tags
}

module "ldap_instance_ingress_security_rule" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.enable_ldap == true && var.ldap_server == "null" && var.using_jumphost_connection == false && var.ldap_sg_id == null) ? 5 : 0
  security_group_id        = [module.ldap_instance_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.ldap_instance_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "ldap_instance_ingress_security_rule_wt_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.enable_ldap == true && var.ldap_server == "null" && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id != null && var.ldap_sg_id == null) ? 5 : 0
  security_group_id        = [module.ldap_instance_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [var.bastion_security_group_id, local.deploy_sec_group_id, module.ldap_instance_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "ldap_instance_ingress_security_rule_wo_bastion" {
  source                   = "../../../resources/ibmcloud/security/security_rule_source"
  total_rules              = (var.enable_ldap == true && var.ldap_server == "null" && var.using_jumphost_connection == true && var.deploy_controller_sec_group_id == null && var.ldap_sg_id == null) ? 4 : 0
  security_group_id        = [module.ldap_instance_security_group.sec_group_id]
  sg_direction             = ["inbound"]
  source_security_group_id = [local.deploy_sec_group_id, module.ldap_instance_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

data "ibm_is_ssh_key" "ldap_ssh_key" {
  count = var.enable_ldap == true && var.ldap_server == "null" && var.ldap_instance_key_pair != null ? length(var.ldap_instance_key_pair) : 0
  name  = var.ldap_instance_key_pair[count.index]
}

data "ibm_is_image" "ldap_instance_image" {
  name  = var.ldap_vsi_osimage_name
  count = var.enable_ldap == true && var.ldap_server == "null" ? 1 : 0
}

module "ldap_instance" {
  count                = var.enable_ldap == true && var.ldap_server == "null" ? 1 : 0
  source               = "../../../resources/ibmcloud/compute/ldap_vsi"
  vsi_name_prefix      = format("%s-ldapserver", var.resource_prefix)
  vpc_id               = var.vpc_id
  resource_group_id    = var.resource_group_id
  zones                = var.vpc_availability_zones[0]
  vsi_image_id         = local.ldap_instance_image_id
  vsi_profile          = var.ldap_vsi_profile
  vsi_subnet_id        = var.vpc_storage_cluster_private_subnets[0]
  vsi_security_group   = local.existing_ldap_sg_id
  vsi_user_public_key  = var.enable_ldap == true && var.ldap_server == "null" ? data.ibm_is_ssh_key.ldap_ssh_key[*].id : []
  vsi_meta_private_key = var.enable_ldap == true && var.ldap_server == "null" ? module.generate_ldap_instance_keys.private_key_content : 0
  vsi_meta_public_key  = var.enable_ldap == true && var.ldap_server == "null" ? module.generate_ldap_instance_keys.public_key_content : 0
  depends_on           = [module.generate_ldap_instance_keys, module.ldap_instance_security_group]
  resource_tags        = var.scale_cluster_resource_tags
}

data "ibm_is_ssh_key" "compute_ssh_key" {
  count = var.compute_cluster_key_pair != null ? length(var.compute_cluster_key_pair) : 0
  name  = var.compute_cluster_key_pair[count.index]
}

data "ibm_is_ssh_key" "client_ssh_key" {
  count = var.client_cluster_key_pair != null ? length(var.client_cluster_key_pair) : 0
  name  = var.client_cluster_key_pair[count.index]
}

data "ibm_is_instance_profile" "compute_profile" {
  name = var.compute_vsi_profile
}

data "ibm_is_image" "compute_instance_image" {
  name  = var.compute_vsi_osimage_name
  count = var.compute_vsi_osimage_id != "" ? 0 : 1
}

data "ibm_is_image" "client_instance_image" {
  name = var.client_vsi_osimage_name
}

data "ibm_is_subnet" "compute_cluster_private_subnets_cidr" {
  identifier = var.vpc_compute_cluster_private_subnets[0]
}

module "compute_cluster_instances" {
  source                       = "../../../resources/ibmcloud/compute/vsi_0_vol"
  total_vsis                   = var.total_compute_cluster_instances
  vsi_name_prefix              = format("%s-comp", var.resource_prefix)
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = local.compute_instance_image_id
  vsi_profile                  = var.compute_vsi_profile
  dns_domain                   = var.vpc_compute_cluster_dns_domain
  dns_service_id               = var.vpc_compute_cluster_dns_service_id
  dns_zone_id                  = var.vpc_compute_cluster_dns_zone_id
  vsi_subnet_id                = length(var.vpc_compute_cluster_private_subnets) == 0 ? var.vpc_storage_cluster_private_subnets : var.vpc_compute_cluster_private_subnets
  vsi_security_group           = local.existing_comp_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.compute_ssh_key[*].id
  vsi_meta_private_key         = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  storage_domain_name          = var.vpc_storage_cluster_dns_domain
  storage_dns_service_id       = var.vpc_storage_cluster_dns_service_id
  storage_dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  storage_subnet_id            = var.vpc_storage_cluster_private_subnets
  storage_sec_group            = local.existing_strg_sg_id
  enable_sec_interface_compute = local.enable_sec_interface_compute
  scale_firewall_rules_enabled = true
  resource_tags                = var.scale_cluster_resource_tags
  depends_on                   = [module.compute_cluster_ingress_security_rule, module.compute_cluster_ingress_security_rule_wt_bastion, module.compute_cluster_ingress_security_rule_wo_bastion, module.compute_egress_security_rule, var.vpc_custom_resolver_id]
}

module "compute_cluster_management_instance" {
  source                       = "../../../resources/ibmcloud/compute/vsi_0_vol"
  total_vsis                   = var.total_compute_cluster_instances == 0 ? 0 : 1
  vsi_name_prefix              = format("%s-comp-mgmt", var.resource_prefix)
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = local.compute_instance_image_id
  vsi_profile                  = var.management_vsi_profile
  dns_domain                   = var.vpc_compute_cluster_dns_domain
  dns_service_id               = var.vpc_compute_cluster_dns_service_id
  dns_zone_id                  = var.vpc_compute_cluster_dns_zone_id
  vsi_subnet_id                = length(var.vpc_compute_cluster_private_subnets) == 0 ? var.vpc_storage_cluster_private_subnets : var.vpc_compute_cluster_private_subnets
  vsi_security_group           = local.existing_comp_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.compute_ssh_key[*].id
  vsi_meta_private_key         = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = var.create_separate_namespaces == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  storage_domain_name          = var.vpc_storage_cluster_dns_domain
  storage_dns_service_id       = var.vpc_storage_cluster_dns_service_id
  storage_dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  storage_subnet_id            = var.vpc_storage_cluster_private_subnets
  storage_sec_group            = local.existing_strg_sg_id
  enable_sec_interface_compute = local.enable_sec_interface_compute
  scale_firewall_rules_enabled = true
  resource_tags                = var.scale_cluster_resource_tags
  depends_on                   = [module.compute_cluster_ingress_security_rule, module.compute_cluster_ingress_security_rule_wt_bastion, module.compute_cluster_ingress_security_rule_wo_bastion, module.compute_egress_security_rule, var.vpc_custom_resolver_id]
}

module "client_cluster_instances" {
  source                       = "../../../resources/ibmcloud/compute/vsi_0_vol"
  total_vsis                   = var.total_client_cluster_instances
  vsi_name_prefix              = format("%s-client", var.resource_prefix)
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = data.ibm_is_image.client_instance_image.id
  vsi_profile                  = var.client_vsi_profile
  dns_domain                   = var.vpc_client_cluster_dns_domain
  dns_service_id               = var.vpc_client_cluster_dns_service_id
  dns_zone_id                  = var.vpc_client_cluster_dns_zone_id
  vsi_subnet_id                = length(var.vpc_compute_cluster_private_subnets) == 0 ? var.vpc_storage_cluster_private_subnets : var.vpc_compute_cluster_private_subnets
  vsi_security_group           = local.existing_comp_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.client_ssh_key[*].id
  vsi_meta_private_key         = var.create_separate_namespaces == true ? module.generate_client_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = var.create_separate_namespaces == true ? module.generate_client_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  storage_domain_name          = var.vpc_storage_cluster_dns_domain
  storage_dns_service_id       = var.vpc_storage_cluster_dns_service_id
  storage_dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  storage_subnet_id            = var.vpc_storage_cluster_private_subnets
  storage_sec_group            = local.existing_strg_sg_id
  enable_sec_interface_compute = false
  scale_firewall_rules_enabled = false
  resource_tags                = var.scale_cluster_resource_tags
  depends_on                   = [module.compute_cluster_ingress_security_rule, module.compute_cluster_ingress_security_rule_wt_bastion, module.compute_cluster_ingress_security_rule_wo_bastion, module.compute_egress_security_rule, var.vpc_custom_resolver_id]
}

data "ibm_is_instance_profile" "storage_profile" {
  name = var.storage_vsi_profile
}

data "ibm_is_instance_profile" "protocol_profile_vsi" {
  count = local.ces_server_type == false && (local.scale_ces_enabled == true && var.colocate_protocol_cluster_instances == false) ? 1 : 0
  name  = var.protocol_vsi_profile
}

data "ibm_is_bare_metal_server_profile" "protocol_profile_bm" {
  count = local.ces_server_type == true && (local.scale_ces_enabled == true && var.colocate_protocol_cluster_instances == false) ? 1 : 0
  name  = var.protocol_vsi_profile
}

data "ibm_is_instance_profile" "management_profile" {
  name = var.management_vsi_profile
}

data "ibm_is_bare_metal_server_profile" "storage_bare_metal_server_profile" {
  count = var.storage_type == "persistent" ? 1 : 0
  name  = var.storage_bare_metal_server_profile
}

data "ibm_is_ssh_key" "storage_ssh_key" {
  count = length(var.storage_cluster_key_pair)
  name  = var.storage_cluster_key_pair[count.index]
}

data "ibm_is_image" "storage_instance_image" {
  name  = var.storage_vsi_osimage_name
  count = var.storage_vsi_osimage_id != "" ? 0 : 1
}

data "ibm_is_image" "storage_bare_metal_image" {
  name  = var.storage_bare_metal_osimage_name
  count = var.storage_bare_metal_osimage_id != "" ? 0 : 1
}

data "ibm_is_subnet" "storage_cluster_private_subnets_cidr" {
  identifier = var.vpc_storage_cluster_private_subnets[0]
}

module "protocol_reserved_ip" {
  source                  = "../../../resources/ibmcloud/network/protocol_reserved_ip"
  total_reserved_ips      = var.total_protocol_cluster_instances
  subnet_id               = var.vpc_protocol_cluster_private_subnets
  name                    = format("%s-ces", var.resource_prefix)
  protocol_domain         = var.vpc_protocol_cluster_dns_domain
  protocol_dns_service_id = var.vpc_protocol_cluster_dns_service_id
  protocol_dns_zone_id    = var.vpc_protocol_cluster_dns_zone_id
  depends_on              = [module.compute_cluster_ingress_security_rule, module.compute_cluster_ingress_security_rule_wt_bastion, module.compute_cluster_ingress_security_rule_wo_bastion, module.compute_egress_security_rule, var.vpc_custom_resolver_id]
}

module "protocol_cluster_instances" {
  source                    = "../../../resources/ibmcloud/compute/protocol_vsi"
  total_vsis                = var.colocate_protocol_cluster_instances == true ? 0 : var.total_protocol_cluster_instances
  vsi_name_prefix           = format("%s-ces", var.resource_prefix)
  ces_server_type           = local.ces_server_type
  vpc_id                    = var.vpc_id
  resource_group_id         = var.resource_group_id
  zones                     = [var.vpc_availability_zones[0]]
  vsi_image_id              = local.storage_instance_image_id
  vsi_profile               = var.protocol_vsi_profile
  dns_domain                = var.vpc_storage_cluster_dns_domain
  dns_service_id            = var.vpc_storage_cluster_dns_service_id
  dns_zone_id               = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id             = var.vpc_storage_cluster_private_subnets
  vsi_security_group        = local.existing_strg_sg_id
  vsi_user_public_key       = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key      = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key       = module.generate_storage_cluster_keys.public_key_content
  protocol_domain           = var.vpc_protocol_cluster_dns_domain
  protocol_subnet_id        = var.vpc_protocol_cluster_private_subnets
  resource_tags             = var.scale_cluster_resource_tags
  vpc_region                = var.vpc_region
  bms_boot_drive_encryption = var.bms_boot_drive_encryption
  storage_private_key       = module.generate_storage_cluster_keys.private_key_content
  depends_on                = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
}

module "storage_cluster_instances" {
  count                        = var.storage_type != "persistent" ? 1 : 0
  source                       = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  total_vsis                   = var.total_storage_cluster_instances
  vsi_name_prefix              = format("%s-strg", var.resource_prefix)
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = local.storage_instance_image_id
  vsi_profile                  = var.storage_vsi_profile
  dns_domain                   = var.vpc_storage_cluster_dns_domain
  dns_service_id               = var.vpc_storage_cluster_dns_service_id
  dns_zone_id                  = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id                = var.vpc_storage_cluster_private_subnets
  vsi_security_group           = local.existing_strg_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key         = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = module.generate_storage_cluster_keys.public_key_content
  enable_sec_interface_storage = local.enable_sec_interface_storage
  enable_protocol              = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? true : false
  vpc_region                   = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? var.vpc_region : ""
  protocol_domain              = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? var.vpc_protocol_cluster_dns_domain : ""
  protocol_subnet_id           = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? var.vpc_protocol_cluster_private_subnets : []
  resource_tags                = var.scale_cluster_resource_tags
  depends_on                   = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
}

module "storage_cluster_bare_metal_server" {
  count                     = var.storage_type == "persistent" ? 1 : 0
  source                    = "../../../resources/ibmcloud/compute/bare_metal_server_multiple_vol"
  total_vsis                = var.total_storage_cluster_instances
  vsi_name_prefix           = format("%s-strg", var.resource_prefix)
  vpc_id                    = var.vpc_id
  resource_group_id         = var.resource_group_id
  zones                     = [var.vpc_availability_zones[0]]
  vsi_image_id              = local.storage_bare_metal_image_id
  vsi_profile               = var.storage_bare_metal_server_profile
  bms_boot_drive_encryption = var.bms_boot_drive_encryption
  dns_domain                = var.vpc_storage_cluster_dns_domain
  dns_service_id            = var.vpc_storage_cluster_dns_service_id
  dns_zone_id               = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id             = var.vpc_storage_cluster_private_subnets
  vsi_security_group        = local.existing_strg_sg_id
  vsi_user_public_key       = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key      = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key       = module.generate_storage_cluster_keys.public_key_content
  enable_protocol           = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? true : false
  vpc_region                = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? var.vpc_region : ""
  protocol_domain           = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? var.vpc_protocol_cluster_dns_domain : ""
  protocol_subnet_id        = var.total_protocol_cluster_instances > 0 && var.colocate_protocol_cluster_instances == true ? var.vpc_protocol_cluster_private_subnets : []
  storage_private_key       = module.generate_storage_cluster_keys.private_key_content
  resource_tags             = var.scale_cluster_resource_tags
  depends_on                = [module.storage_cluster_ingress_security_rule, var.vpc_custom_resolver_id, module.storage_egress_security_rule]
}

module "storage_cluster_management_instance" {
  source                       = "../../../resources/ibmcloud/compute/vsi_0_vol"
  total_vsis                   = 1
  vsi_name_prefix              = format("%s-strg-mgmt", var.resource_prefix)
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = local.storage_instance_image_id
  vsi_profile                  = var.management_vsi_profile
  dns_domain                   = var.vpc_storage_cluster_dns_domain
  dns_service_id               = var.vpc_storage_cluster_dns_service_id
  dns_zone_id                  = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id                = var.vpc_storage_cluster_private_subnets
  vsi_security_group           = local.existing_strg_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key         = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = module.generate_storage_cluster_keys.public_key_content
  storage_domain_name          = var.vpc_storage_cluster_dns_domain
  storage_dns_service_id       = var.vpc_storage_cluster_dns_service_id
  storage_dns_zone_id          = var.vpc_storage_cluster_dns_zone_id
  storage_subnet_id            = var.vpc_storage_cluster_private_subnets
  storage_sec_group            = local.existing_strg_sg_id
  enable_sec_interface_compute = local.enable_sec_interface_storage
  scale_firewall_rules_enabled = true
  resource_tags                = var.scale_cluster_resource_tags
  depends_on                   = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
}

module "storage_cluster_tie_breaker_instance" {
  count                        = var.storage_type != "persistent" ? 1 : 0
  source                       = "../../../resources/ibmcloud/compute/vsi_multiple_vol"
  total_vsis                   = 1
  vsi_name_prefix              = format("%s-strg-tie", var.resource_prefix)
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = local.storage_instance_image_id
  vsi_profile                  = var.storage_vsi_profile
  dns_domain                   = var.vpc_storage_cluster_dns_domain
  dns_service_id               = var.vpc_storage_cluster_dns_service_id
  dns_zone_id                  = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id                = var.vpc_storage_cluster_private_subnets
  vsi_security_group           = local.existing_strg_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key         = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = module.generate_storage_cluster_keys.public_key_content
  enable_sec_interface_storage = local.enable_sec_interface_storage
  enable_protocol              = false
  vpc_region                   = ""
  protocol_domain              = ""
  protocol_subnet_id           = []
  resource_tags                = var.scale_cluster_resource_tags
  depends_on                   = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
}

module "storage_cluster_tie_breaker_instance_bm" {
  count                     = var.storage_type == "persistent" ? 1 : 0
  source                    = "../../../resources/ibmcloud/compute/bare_metal_server_multiple_vol"
  total_vsis                = 1
  vsi_name_prefix           = format("%s-strg-tie", var.resource_prefix)
  vpc_id                    = var.vpc_id
  resource_group_id         = var.resource_group_id
  zones                     = [var.vpc_availability_zones[0]]
  vsi_image_id              = local.storage_instance_image_id
  vsi_profile               = "cx2d-metal-96x192"
  dns_domain                = var.vpc_storage_cluster_dns_domain
  dns_service_id            = var.vpc_storage_cluster_dns_service_id
  dns_zone_id               = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id             = var.vpc_storage_cluster_private_subnets
  vsi_security_group        = local.existing_strg_sg_id
  vsi_user_public_key       = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key      = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key       = module.generate_storage_cluster_keys.public_key_content
  enable_protocol           = false
  vpc_region                = ""
  protocol_domain           = ""
  protocol_subnet_id        = []
  bms_boot_drive_encryption = var.bms_boot_drive_encryption
  storage_private_key       = module.generate_storage_cluster_keys.private_key_content
  resource_tags             = var.scale_cluster_resource_tags
  depends_on                = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
}

data "ibm_is_ssh_key" "gklm_ssh_key" {
  count = var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" ? length(var.gklm_instance_key_pair) : 0
  name  = var.gklm_instance_key_pair[count.index]
}

data "ibm_is_image" "gklm_instance_image" {
  name  = var.gklm_vsi_osimage_name
  count = var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" && var.gklm_vsi_osimage_id == null ? 1 : 0
}

module "gklm_instance" {
  count                = var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" ? 1 : 0
  source               = "../../../resources/ibmcloud/compute/gklm_vsi"
  total_vsis           = var.total_gklm_instances
  vsi_name_prefix      = format("%s-gklm", var.resource_prefix)
  vpc_id               = var.vpc_id
  resource_group_id    = var.resource_group_id
  zones                = [var.vpc_availability_zones[0]]
  vsi_image_id         = local.gklm_instance_image_id
  vsi_profile          = var.gklm_vsi_profile
  dns_domain           = var.gklm_instance_dns_domain
  dns_service_id       = var.gklm_instance_dns_service_id
  dns_zone_id          = var.gklm_instance_dns_zone_id
  vsi_subnet_id        = var.vpc_compute_cluster_private_subnets
  vsi_security_group   = local.existing_gklm_sg_id
  vsi_user_public_key  = var.scale_encryption_enabled == true && var.scale_encryption_type == "gklm" ? data.ibm_is_ssh_key.gklm_ssh_key[*].id : []
  vsi_meta_private_key = var.create_separate_namespaces == true ? module.generate_gklm_instance_keys.private_key_content : 0
  vsi_meta_public_key  = var.create_separate_namespaces == true ? module.generate_gklm_instance_keys.public_key_content : 0
  resource_tags        = var.scale_cluster_resource_tags
  depends_on           = [module.gklm_instance_ingress_security_rule, module.gklm_instance_ingress_security_rule_wt_bastion, module.gklm_instance_ingress_security_rule_wo_bastion, module.gklm_instance_egress_security_rule, var.vpc_custom_resolver_id]
}

module "key_protect_instance" {
  count                          = var.scale_encryption_enabled == true && var.scale_encryption_type == "key_protect" ? 1 : 0
  source                         = "../../../resources/ibmcloud/compute/key_protect"
  resource_prefix                = var.resource_prefix
  vpc_region                     = var.vpc_region
  resource_group_id              = var.resource_group_id
  key_protect_path               = format("%s/key_protect", var.scale_ansible_repo_clone_path)
  resource_tags                  = var.scale_cluster_resource_tags
  vpc_storage_cluster_dns_domain = var.vpc_storage_cluster_dns_domain
}

data "ibm_is_bare_metal_server_profile" "afm_vsi_bm_server_profile" {
  count = local.afm_server_type == true ? 1 : 0
  name  = var.afm_vsi_profile
}

data "ibm_is_instance_profile" "afm_vsi_server_profile" {
  count = local.afm_server_type == false ? 1 : 0
  name  = var.afm_vsi_profile
}

module "afm_cluster_instances" {
  source                       = "../../../resources/ibmcloud/compute/afm_vsi"
  total_vsis                   = var.total_afm_cluster_instances
  vsi_name_prefix              = format("%s-afm", var.resource_prefix)
  afm_server_type              = local.afm_server_type
  vpc_id                       = var.vpc_id
  resource_group_id            = var.resource_group_id
  zones                        = [var.vpc_availability_zones[0]]
  vsi_image_id                 = local.storage_instance_image_id
  vsi_profile                  = var.afm_vsi_profile
  dns_domain                   = var.vpc_storage_cluster_dns_domain
  dns_service_id               = var.vpc_storage_cluster_dns_service_id
  dns_zone_id                  = var.vpc_storage_cluster_dns_zone_id
  vsi_subnet_id                = var.vpc_storage_cluster_private_subnets
  vsi_security_group           = local.existing_strg_sg_id
  vsi_user_public_key          = data.ibm_is_ssh_key.storage_ssh_key[*].id
  vsi_meta_private_key         = module.generate_storage_cluster_keys.private_key_content
  vsi_meta_public_key          = module.generate_storage_cluster_keys.public_key_content
  scale_firewall_rules_enabled = true
  resource_tags                = var.scale_cluster_resource_tags
  bms_boot_drive_encryption    = var.bms_boot_drive_encryption
  storage_private_key          = module.generate_storage_cluster_keys.private_key_content
  depends_on                   = [module.storage_cluster_ingress_security_rule, module.storage_cluster_ingress_security_rule_wo_bastion, module.storage_cluster_ingress_security_rule_wt_bastion, module.storage_egress_security_rule, var.vpc_custom_resolver_id]
}

locals {
  new_instance_bucket_hmac        = [for details in var.afm_cos_config : details if(details.cos_instance == "" && details.bucket_name == "" && details.cos_service_cred_key == "")]
  exstng_instance_new_bucket_hmac = [for details in var.afm_cos_config : details if(details.cos_instance != "" && details.bucket_name == "" && details.cos_service_cred_key == "")]
  exstng_instance_bucket_new_hmac = [for details in var.afm_cos_config : details if(details.cos_instance != "" && details.bucket_name != "" && details.cos_service_cred_key == "")]
  exstng_instance_hmac_new_bucket = [for details in var.afm_cos_config : details if(details.cos_instance != "" && details.bucket_name == "" && details.cos_service_cred_key != "")]
  exstng_instance_bucket_hmac     = [for details in var.afm_cos_config : details if(details.cos_instance != "" && details.bucket_name != "" && details.cos_service_cred_key != "")]

}

module "cos" {
  count                           = local.enable_afm == true ? 1 : 0
  source                          = "../../../resources/ibmcloud/compute/cos"
  prefix                          = "${var.resource_prefix}-"
  resource_group_id               = var.resource_group_id
  cos_instance_plan               = "standard"
  cos_instance_location           = "global"
  cos_instance_service            = "cloud-object-storage"
  cos_hmac_role                   = "Manager"
  new_instance_bucket_hmac        = local.new_instance_bucket_hmac
  exstng_instance_new_bucket_hmac = local.exstng_instance_new_bucket_hmac
  exstng_instance_bucket_new_hmac = local.exstng_instance_bucket_new_hmac
  exstng_instance_hmac_new_bucket = local.exstng_instance_hmac_new_bucket
  exstng_instance_bucket_hmac     = local.exstng_instance_bucket_hmac
  filesystem                      = var.storage_cluster_filesystem_mountpoint
  depends_on                      = [module.afm_cluster_instances]
}

locals {
  afm_cos_bucket_details = local.enable_afm == true ? flatten(module.cos[*].afm_cos_bucket_details) : []
  afm_config_details     = local.enable_afm == true ? flatten(module.cos[*].afm_config_details) : []
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
  turn_on    = true
}

data "ibm_is_subnet_reserved_ips" "protocol_subnet_reserved_ips" {
  count  = local.scale_ces_enabled == true ? 1 : 0
  subnet = var.vpc_protocol_cluster_private_subnets[0]
}

locals {
  afm_instance_ids         = values(one(module.afm_cluster_instances[*].storage_cluster_instance_name_id_map_vsi_bm))
  afm_instance_names       = keys(one(module.afm_cluster_instances[*].storage_cluster_instance_name_id_map_vsi_bm))
  afm_instance_private_ips = values(one(module.afm_cluster_instances[*].storage_cluster_instance_name_ip_map_vsi_bm))

  storage_instance_ids                = var.storage_type != "persistent" ? local.enable_afm == true ? concat(values(one(module.storage_cluster_instances[*].instance_name_id_map)), local.afm_instance_ids) : values(one(module.storage_cluster_instances[*].instance_name_id_map)) : []
  storage_instance_names              = var.storage_type != "persistent" ? local.enable_afm == true ? concat(keys(one(module.storage_cluster_instances[*].instance_name_id_map)), local.afm_instance_names) : keys(one(module.storage_cluster_instances[*].instance_name_id_map)) : []
  storage_instance_private_ips        = var.storage_type != "persistent" ? local.enable_afm == true ? concat(values(one(module.storage_cluster_instances[*].instance_name_ip_map)), local.afm_instance_private_ips) : values(one(module.storage_cluster_instances[*].instance_name_ip_map)) : []
  storage_instance_private_dns_ip_map = var.storage_type != "persistent" ? one(module.storage_cluster_instances[*].instance_private_dns_ip_map) : {}

  storage_cluster_instance_ids                = local.scale_ces_enabled == false ? local.storage_instance_ids : concat(local.storage_instance_ids, values(one(module.protocol_cluster_instances[*].instance_name_id_map)))
  storage_cluster_instance_names              = local.scale_ces_enabled == false ? local.storage_instance_names : concat(local.storage_instance_names, keys(one(module.protocol_cluster_instances[*].instance_name_id_map)))
  storage_cluster_instance_private_ips        = local.scale_ces_enabled == false ? local.storage_instance_private_ips : concat(local.storage_instance_private_ips, values(one(module.protocol_cluster_instances[*].instance_name_ip_map)))
  storage_cluster_instance_private_dns_ip_map = local.scale_ces_enabled == false ? local.storage_instance_private_dns_ip_map : merge(local.storage_instance_private_dns_ip_map, one(module.protocol_cluster_instances[*].instance_private_dns_ip_map))

  baremetal_instance_ids                = var.storage_type == "persistent" ? local.enable_afm == true ? concat(values(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_id_map)), local.afm_instance_ids) : values(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_id_map)) : []
  baremetal_instance_names              = var.storage_type == "persistent" ? local.enable_afm == true ? concat(keys(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_id_map)), local.afm_instance_names) : keys(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_id_map)) : []
  baremetal_instance_private_ips        = var.storage_type == "persistent" ? local.enable_afm == true ? concat(values(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_ip_map)), local.afm_instance_private_ips) : values(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_ip_map)) : []
  baremetal_instance_private_dns_ip_map = var.storage_type == "persistent" ? one(module.storage_cluster_bare_metal_server[*].instance_private_dns_ip_map) : {}

  baremetal_cluster_instance_ids                = var.storage_type == "persistent" && local.scale_ces_enabled == false ? local.baremetal_instance_ids : concat(local.baremetal_instance_ids, values(one(module.protocol_cluster_instances[*].instance_name_id_map)))
  baremetal_cluster_instance_names              = var.storage_type == "persistent" && local.scale_ces_enabled == false ? local.baremetal_instance_names : concat(local.baremetal_instance_names, keys(one(module.protocol_cluster_instances[*].instance_name_id_map)))
  baremetal_cluster_instance_private_ips        = var.storage_type == "persistent" && local.scale_ces_enabled == false ? local.baremetal_instance_private_ips : concat(local.baremetal_instance_private_ips, values(one(module.protocol_cluster_instances[*].instance_name_ip_map)))
  baremetal_cluster_instance_private_dns_ip_map = var.storage_type == "persistent" && local.scale_ces_enabled == false ? local.baremetal_instance_private_dns_ip_map : merge(local.baremetal_instance_private_dns_ip_map, one(module.protocol_cluster_instances[*].instance_private_dns_ip_map))

  tie_breaker_storage_instance_ids                = var.storage_type != "persistent" ? flatten(module.storage_cluster_tie_breaker_instance[*].instance_ids) : values(one(module.storage_cluster_tie_breaker_instance_bm[*].storage_cluster_instance_name_id_map))
  tie_breaker_storage_instance_names              = var.storage_type != "persistent" ? flatten(keys(one(module.storage_cluster_tie_breaker_instance[*].instance_name_id_map))) : keys(one(module.storage_cluster_tie_breaker_instance_bm[*].storage_cluster_instance_name_id_map))
  tie_breaker_storage_instance_private_ips        = var.storage_type != "persistent" ? flatten(module.storage_cluster_tie_breaker_instance[*].instance_private_ips) : values(one(module.storage_cluster_tie_breaker_instance_bm[*].storage_cluster_instance_name_ip_map))
  tie_breaker_storage_instance_private_dns_ip_map = var.storage_type != "persistent" ? one(module.storage_cluster_tie_breaker_instance[*].instance_private_dns_ip_map) : {}

  fileset_size_map = try({ for details in var.filesets : details.mount_path => details.size }, {})

  protocol_reserved_name_ips_map = try({ for details in data.ibm_is_subnet_reserved_ips.protocol_subnet_reserved_ips[0].reserved_ips : details.name => details.address }, {})
  protocol_subnet_gateway_ip     = local.scale_ces_enabled == true ? local.protocol_reserved_name_ips_map.ibm-default-gateway : ""

  protocol_cluster_instance_names = slice((concat(keys(one(module.protocol_cluster_instances[*].instance_name_id_map)), (var.storage_type == "persistent" ? keys(one(module.storage_cluster_bare_metal_server[*].storage_cluster_instance_name_id_map)) : keys(one(module.storage_cluster_instances[*].instance_name_id_map))))), 0, var.total_protocol_cluster_instances)

  compute_management_node_id   = local.enable_sec_interface_compute ? values(module.compute_cluster_management_instance.secondary_interface_name_id_map) : values(module.compute_cluster_management_instance.instance_name_id_map)
  compute_management_node_ip   = local.enable_sec_interface_compute ? values(module.compute_cluster_management_instance.secondary_interface_name_ip_map) : values(module.compute_cluster_management_instance.instance_name_ip_map)
  compute_management_node_name = local.enable_sec_interface_compute ? keys(module.compute_cluster_management_instance.secondary_interface_name_id_map) : keys(module.compute_cluster_management_instance.instance_name_id_map)
}

module "write_compute_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  bastion_user                                     = jsonencode(var.bastion_user)
  inventory_path                                   = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("IBMCloud")
  resource_prefix                                  = jsonencode(format("%s.%s", var.resource_prefix, var.vpc_compute_cluster_dns_domain))
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode("None")
  compute_cluster_filesystem_mountpoint            = jsonencode(var.compute_cluster_filesystem_mountpoint)
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(concat((local.enable_sec_interface_compute ? values(module.compute_cluster_instances.secondary_interface_name_id_map) : values(module.compute_cluster_instances.instance_name_id_map)), local.compute_management_node_id))
  compute_cluster_instance_private_ips             = jsonencode(concat((local.enable_sec_interface_compute ? values(module.compute_cluster_instances.secondary_interface_name_ip_map) : values(module.compute_cluster_instances.instance_name_ip_map)), local.compute_management_node_ip))
  compute_cluster_instance_private_dns_ip_map      = jsonencode(module.compute_cluster_instances.instance_private_dns_ip_map)
  storage_cluster_filesystem_mountpoint            = jsonencode("None")
  storage_cluster_instance_ids                     = jsonencode([])
  storage_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_with_data_volume_mapping         = jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([])
  storage_cluster_desc_instance_private_ips        = jsonencode([])
  storage_cluster_desc_data_volume_mapping         = jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode({})
  compute_cluster_instance_names                   = jsonencode(concat((local.enable_sec_interface_compute ? keys(module.compute_cluster_instances.secondary_interface_name_id_map) : keys(module.compute_cluster_instances.instance_name_id_map)), local.compute_management_node_name, ))
  storage_cluster_instance_names                   = jsonencode([])
  storage_subnet_cidr                              = local.enable_mrot_conf ? jsonencode(data.ibm_is_subnet.storage_cluster_private_subnets_cidr.ipv4_cidr_block) : jsonencode("")
  compute_subnet_cidr                              = local.enable_mrot_conf ? jsonencode(data.ibm_is_subnet.compute_cluster_private_subnets_cidr.ipv4_cidr_block) : jsonencode("")
  scale_remote_cluster_clustername                 = local.enable_mrot_conf ? jsonencode(format("%s.%s", var.resource_prefix, var.vpc_storage_cluster_dns_domain)) : jsonencode("")
  protocol_cluster_instance_names                  = jsonencode([])
  client_cluster_instance_names                    = jsonencode([])
  protocol_cluster_reserved_names                  = jsonencode([])
  smb                                              = false
  nfs                                              = true
  object                                           = false
  interface                                        = jsonencode([])
  export_ip_pool                                   = jsonencode([])
  filesystem                                       = jsonencode("")
  mountpoint                                       = jsonencode("")
  protocol_gateway_ip                              = jsonencode("")
  filesets                                         = jsonencode({})
  afm_cos_bucket_details                           = jsonencode([])
  afm_config_details                               = jsonencode([])
  afm_cluster_instance_names                       = jsonencode([])
  filesystem_mountpoint                            = var.scale_encryption_type == "key_protect" ? jsonencode(element(split("/", var.storage_cluster_filesystem_mountpoint), length(split("/", var.storage_cluster_filesystem_mountpoint)) - 1)) : jsonencode("")
}

module "write_storage_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  bastion_user                                     = jsonencode(var.bastion_user)
  inventory_path                                   = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("IBMCloud")
  resource_prefix                                  = jsonencode(format("%s.%s", var.resource_prefix, var.vpc_storage_cluster_dns_domain))
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode([])
  compute_cluster_instance_private_ips             = jsonencode([])
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = var.storage_type == "persistent" ? jsonencode(concat(local.baremetal_cluster_instance_ids, values(module.storage_cluster_management_instance.instance_name_id_map), local.tie_breaker_storage_instance_ids)) : jsonencode(concat(local.storage_cluster_instance_ids, values(module.storage_cluster_management_instance.instance_name_id_map), local.tie_breaker_storage_instance_ids))
  storage_cluster_instance_private_ips             = var.storage_type == "persistent" ? jsonencode(concat(local.baremetal_cluster_instance_private_ips, values(module.storage_cluster_management_instance.instance_name_ip_map), local.tie_breaker_storage_instance_private_ips)) : jsonencode(concat(local.storage_cluster_instance_private_ips, values(module.storage_cluster_management_instance.instance_name_ip_map), local.tie_breaker_storage_instance_private_ips))
  storage_cluster_with_data_volume_mapping         = var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ips_with_vol_mapping)) : jsonencode(one(module.storage_cluster_instances[*].instance_ips_with_vol_mapping))
  storage_cluster_instance_private_dns_ip_map      = var.storage_type == "persistent" ? jsonencode(local.baremetal_cluster_instance_private_dns_ip_map) : jsonencode(local.storage_cluster_instance_private_dns_ip_map)
  storage_cluster_desc_instance_ids                = jsonencode(local.tie_breaker_storage_instance_ids)
  storage_cluster_desc_instance_private_ips        = jsonencode(local.tie_breaker_storage_instance_private_ips)
  storage_cluster_desc_data_volume_mapping         = var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_tie_breaker_instance_bm[*].instance_ips_with_vol_mapping)) : jsonencode(one(module.storage_cluster_tie_breaker_instance[*].instance_ips_with_vol_mapping))
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode(local.tie_breaker_storage_instance_private_dns_ip_map)
  storage_cluster_instance_names                   = var.storage_type == "persistent" ? jsonencode(concat(local.baremetal_cluster_instance_names, keys(module.storage_cluster_management_instance.instance_name_id_map), local.tie_breaker_storage_instance_names)) : jsonencode(concat(local.storage_cluster_instance_names, keys(module.storage_cluster_management_instance.instance_name_id_map), local.tie_breaker_storage_instance_names))
  compute_cluster_instance_names                   = jsonencode([])
  storage_subnet_cidr                              = local.enable_mrot_conf ? jsonencode(data.ibm_is_subnet.storage_cluster_private_subnets_cidr.ipv4_cidr_block) : jsonencode("")
  compute_subnet_cidr                              = local.enable_mrot_conf || local.scale_ces_enabled == true ? jsonencode(data.ibm_is_subnet.compute_cluster_private_subnets_cidr.ipv4_cidr_block) : jsonencode("")
  scale_remote_cluster_clustername                 = local.enable_mrot_conf ? jsonencode(format("%s.%s", var.resource_prefix, var.vpc_compute_cluster_dns_domain)) : jsonencode("")
  protocol_cluster_instance_names                  = local.scale_ces_enabled == true ? jsonencode(local.protocol_cluster_instance_names) : jsonencode([])
  client_cluster_instance_names                    = jsonencode([])
  protocol_cluster_reserved_names                  = jsonencode([])
  smb                                              = false
  nfs                                              = local.scale_ces_enabled == true ? true : false
  object                                           = false
  interface                                        = jsonencode([])
  export_ip_pool                                   = local.scale_ces_enabled == true ? jsonencode(values(one(module.protocol_reserved_ip[*].instance_name_ip_map))) : jsonencode([])
  filesystem                                       = local.scale_ces_enabled == true ? jsonencode("cesSharedRoot") : jsonencode("")
  mountpoint                                       = local.scale_ces_enabled == true ? jsonencode(var.storage_cluster_filesystem_mountpoint) : jsonencode("")
  protocol_gateway_ip                              = jsonencode(local.protocol_subnet_gateway_ip)
  filesets                                         = jsonencode(local.fileset_size_map)
  afm_cos_bucket_details                           = local.enable_afm == true ? jsonencode(local.afm_cos_bucket_details) : jsonencode([])
  afm_config_details                               = local.enable_afm == true ? jsonencode(local.afm_config_details) : jsonencode([])
  afm_cluster_instance_names                       = jsonencode(local.afm_instance_names)
  filesystem_mountpoint                            = var.scale_encryption_type == "key_protect" ? jsonencode(element(split("/", var.storage_cluster_filesystem_mountpoint), length(split("/", var.storage_cluster_filesystem_mountpoint)) - 1)) : jsonencode("")
}

module "write_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = var.create_separate_namespaces == false ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  bastion_user                                     = jsonencode(var.bastion_user)
  inventory_path                                   = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("IBMCloud")
  resource_prefix                                  = jsonencode(var.resource_prefix)
  vpc_region                                       = jsonencode(var.vpc_region)
  vpc_availability_zones                           = jsonencode(var.vpc_availability_zones)
  scale_version                                    = jsonencode(local.scale_version)
  filesystem_block_size                            = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips             = jsonencode(module.compute_cluster_instances.instance_private_ips)
  compute_cluster_instance_private_dns_ip_map      = jsonencode(module.compute_cluster_instances.instance_private_dns_ip_map)
  storage_cluster_filesystem_mountpoint            = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids                     = var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ids)) : jsonencode(one(module.storage_cluster_instances[*].instance_ids))
  storage_cluster_instance_private_ips             = var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_private_ips)) : jsonencode(one(module.storage_cluster_instances[*].instance_private_ips))
  storage_cluster_with_data_volume_mapping         = var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_ips_with_vol_mapping)) : jsonencode(one(module.storage_cluster_instances[*].instance_ips_with_vol_mapping))
  storage_cluster_instance_private_dns_ip_map      = var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_bare_metal_server[*].instance_private_dns_ip_map)) : jsonencode(one(module.storage_cluster_instances[*].instance_private_dns_ip_map))
  storage_cluster_desc_instance_ids                = length(var.vpc_availability_zones) > 1 ? jsonencode(local.tie_breaker_storage_instance_ids) : jsonencode([])
  storage_cluster_desc_instance_private_ips        = length(var.vpc_availability_zones) > 1 ? jsonencode(local.tie_breaker_storage_instance_private_ips) : jsonencode([])
  storage_cluster_desc_data_volume_mapping         = length(var.vpc_availability_zones) > 1 ? var.storage_type == "persistent" ? jsonencode(one(module.storage_cluster_tie_breaker_instance_bm[*].instance_ips_with_vol_mapping)) : jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_vol_mapping) : jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = length(var.vpc_availability_zones) > 1 ? jsonencode(local.tie_breaker_storage_instance_private_dns_ip_map) : jsonencode({})
  storage_cluster_instance_names                   = jsonencode([])
  compute_cluster_instance_names                   = jsonencode([])
  storage_subnet_cidr                              = jsonencode("")
  compute_subnet_cidr                              = jsonencode("")
  scale_remote_cluster_clustername                 = jsonencode("")
  protocol_cluster_instance_names                  = jsonencode([])
  client_cluster_instance_names                    = jsonencode([])
  protocol_cluster_reserved_names                  = jsonencode([])
  smb                                              = false
  nfs                                              = true
  object                                           = false
  interface                                        = jsonencode([])
  export_ip_pool                                   = jsonencode([])
  filesystem                                       = jsonencode("")
  mountpoint                                       = jsonencode("")
  protocol_gateway_ip                              = jsonencode("")
  filesets                                         = jsonencode({})
  afm_cos_bucket_details                           = jsonencode([])
  afm_config_details                               = jsonencode([])
  afm_cluster_instance_names                       = jsonencode([])
  filesystem_mountpoint                            = jsonencode("")
}

module "write_client_cluster_inventory" {
  source                                           = "../../../resources/common/write_inventory"
  write_inventory                                  = (var.create_separate_namespaces == true && var.total_client_cluster_instances > 0) ? 1 : 0
  clone_complete                                   = module.prepare_ansible_configuration.clone_complete
  bastion_user                                     = jsonencode(var.bastion_user)
  inventory_path                                   = format("%s/client_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                                   = jsonencode("")
  resource_prefix                                  = jsonencode("")
  vpc_region                                       = jsonencode("")
  vpc_availability_zones                           = jsonencode([])
  scale_version                                    = jsonencode("")
  filesystem_block_size                            = jsonencode("")
  compute_cluster_filesystem_mountpoint            = jsonencode("None")
  bastion_instance_id                              = var.bastion_instance_id == null ? jsonencode("None") : jsonencode(var.bastion_instance_id)
  bastion_instance_public_ip                       = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  compute_cluster_instance_ids                     = jsonencode("")
  compute_cluster_instance_private_ips             = jsonencode("")
  compute_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_filesystem_mountpoint            = local.scale_ces_enabled == true ? jsonencode(var.storage_cluster_filesystem_mountpoint) : jsonencode("")
  storage_cluster_instance_ids                     = jsonencode([])
  storage_cluster_instance_private_ips             = jsonencode([])
  storage_cluster_with_data_volume_mapping         = jsonencode({})
  storage_cluster_instance_private_dns_ip_map      = jsonencode({})
  storage_cluster_desc_instance_ids                = jsonencode([])
  storage_cluster_desc_instance_private_ips        = jsonencode([])
  storage_cluster_desc_data_volume_mapping         = jsonencode({})
  storage_cluster_desc_instance_private_dns_ip_map = jsonencode({})
  storage_cluster_instance_names                   = jsonencode([])
  compute_cluster_instance_names                   = jsonencode([])
  storage_subnet_cidr                              = jsonencode("")
  compute_subnet_cidr                              = jsonencode("")
  scale_remote_cluster_clustername                 = jsonencode("")
  protocol_cluster_instance_names                  = jsonencode([])
  client_cluster_instance_names                    = local.scale_ces_enabled == true ? jsonencode(keys(module.client_cluster_instances.instance_name_id_map)) : jsonencode([])
  protocol_cluster_reserved_names                  = local.scale_ces_enabled == true ? jsonencode(format("%s-ces.%s", var.resource_prefix, var.vpc_protocol_cluster_dns_domain)) : jsonencode([])
  smb                                              = false
  nfs                                              = false
  object                                           = false
  interface                                        = jsonencode([])
  export_ip_pool                                   = jsonencode([])
  filesystem                                       = jsonencode("")
  mountpoint                                       = jsonencode("")
  protocol_gateway_ip                              = jsonencode("")
  filesets                                         = local.scale_ces_enabled == true ? jsonencode(local.fileset_size_map) : jsonencode({})
  afm_cos_bucket_details                           = jsonencode([])
  afm_config_details                               = jsonencode([])
  afm_cluster_instance_names                       = jsonencode([])
  filesystem_mountpoint                            = jsonencode("")
}

module "compute_cluster_configuration" {
  source                          = "../../../resources/common/compute_configuration"
  turn_on                         = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  bastion_user                    = jsonencode(var.bastion_user)
  write_inventory_complete        = module.write_compute_cluster_inventory.write_inventory_complete
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  comp_memory                     = data.ibm_is_instance_profile.compute_profile.memory[0].value
  comp_vcpus_count                = data.ibm_is_instance_profile.compute_profile.vcpu_count[0].value
  comp_bandwidth                  = data.ibm_is_instance_profile.compute_profile.bandwidth[0].value
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  meta_private_key                = module.generate_compute_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = local.enable_mrot_conf ? "True" : "False"
  enable_ces                      = "False"
  enable_afm                      = "False"
  scale_encryption_enabled        = var.scale_encryption_enabled
  scale_encryption_admin_password = var.scale_encryption_admin_password
  scale_encryption_servers        = var.scale_encryption_enabled ? jsonencode(one(module.gklm_instance[*].gklm_ip_addresses)) : null
  enable_ldap                     = var.enable_ldap
  ldap_basedns                    = var.ldap_basedns
  ldap_server                     = local.ldap_server
  ldap_admin_password             = var.ldap_admin_password
  enable_key_protect              = var.scale_encryption_type == "key_protect" ? "True" : "False"
  depends_on                      = [module.ldap_configuration]
}

module "storage_cluster_configuration" {
  source                              = "../../../resources/common/storage_configuration"
  turn_on                             = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? true : false
  clone_complete                      = module.prepare_ansible_configuration.clone_complete
  bastion_user                        = jsonencode(var.bastion_user)
  write_inventory_complete            = module.write_storage_cluster_inventory.write_inventory_complete
  inventory_format                    = var.inventory_format
  create_scale_cluster                = var.create_scale_cluster
  clone_path                          = var.scale_ansible_repo_clone_path
  inventory_path                      = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image                  = var.using_packer_image
  using_jumphost_connection           = var.using_jumphost_connection
  using_rest_initialization           = true
  storage_cluster_gui_username        = var.storage_cluster_gui_username
  storage_cluster_gui_password        = var.storage_cluster_gui_password
  colocate_protocol_cluster_instances = var.colocate_protocol_cluster_instances == true ? "True" : "False"
  is_colocate_protocol_subset         = local.is_colocate_protocol_subset == true ? "True" : "False"
  mgmt_memory                         = data.ibm_is_instance_profile.management_profile.memory[0].value
  mgmt_vcpus_count                    = data.ibm_is_instance_profile.management_profile.vcpu_count[0].value
  mgmt_bandwidth                      = data.ibm_is_instance_profile.management_profile.bandwidth[0].value
  strg_desc_memory                    = data.ibm_is_instance_profile.storage_profile.memory[0].value
  strg_desc_vcpus_count               = data.ibm_is_instance_profile.storage_profile.vcpu_count[0].value
  strg_desc_bandwidth                 = data.ibm_is_instance_profile.storage_profile.bandwidth[0].value
  strg_memory                         = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].memory[0].value : data.ibm_is_instance_profile.storage_profile.memory[0].value
  strg_vcpus_count                    = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].cpu_core_count[0].value * data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].cpu_socket_count[0].value : data.ibm_is_instance_profile.storage_profile.vcpu_count[0].value
  strg_bandwidth                      = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].bandwidth[0].value : data.ibm_is_instance_profile.storage_profile.bandwidth[0].value
  proto_memory                        = (local.scale_ces_enabled == true && var.colocate_protocol_cluster_instances == false) ? local.ces_server_type == false ? data.ibm_is_instance_profile.protocol_profile_vsi[0].memory[0].value : data.ibm_is_bare_metal_server_profile.protocol_profile_bm[0].memory[0].value : jsonencode(0)
  proto_vcpus_count                   = (local.scale_ces_enabled == true && var.colocate_protocol_cluster_instances == false) ? local.ces_server_type == false ? data.ibm_is_instance_profile.protocol_profile_vsi[0].vcpu_count[0].value : data.ibm_is_bare_metal_server_profile.protocol_profile_bm[0].cpu_core_count[0].value : jsonencode(0)
  proto_bandwidth                     = (local.scale_ces_enabled == true && var.colocate_protocol_cluster_instances == false) ? local.ces_server_type == false ? data.ibm_is_instance_profile.protocol_profile_vsi[0].bandwidth[0].value : data.ibm_is_bare_metal_server_profile.protocol_profile_bm[0].bandwidth[0].value : jsonencode(0)
  strg_proto_memory                   = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].memory[0].value : data.ibm_is_instance_profile.storage_profile.memory[0].value
  strg_proto_vcpus_count              = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].cpu_core_count[0].value * data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].cpu_socket_count[0].value : data.ibm_is_instance_profile.storage_profile.vcpu_count[0].value
  strg_proto_bandwidth                = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].bandwidth[0].value : data.ibm_is_instance_profile.storage_profile.bandwidth[0].value
  afm_memory                          = local.afm_server_type == true ? data.ibm_is_bare_metal_server_profile.afm_vsi_bm_server_profile[0].memory[0].value : data.ibm_is_instance_profile.afm_vsi_server_profile[0].memory[0].value
  afm_vcpus_count                     = local.afm_server_type == true ? data.ibm_is_bare_metal_server_profile.afm_vsi_bm_server_profile[0].cpu_core_count[0].value * data.ibm_is_bare_metal_server_profile.afm_vsi_bm_server_profile[0].cpu_socket_count[0].value : data.ibm_is_instance_profile.afm_vsi_server_profile[0].vcpu_count[0].value
  afm_bandwidth                       = local.afm_server_type == true ? data.ibm_is_bare_metal_server_profile.afm_vsi_bm_server_profile[0].bandwidth[0].value : data.ibm_is_instance_profile.afm_vsi_server_profile[0].bandwidth[0].value
  disk_type                           = "network-attached"
  max_data_replicas                   = 3
  max_metadata_replicas               = 3
  default_metadata_replicas           = 2
  default_data_replicas               = 2
  bastion_instance_public_ip          = var.bastion_instance_public_ip
  bastion_ssh_private_key             = var.bastion_ssh_private_key
  meta_private_key                    = module.generate_storage_cluster_keys.private_key_content
  scale_version                       = local.scale_version
  spectrumscale_rpms_path             = var.spectrumscale_rpms_path
  enable_mrot_conf                    = local.enable_mrot_conf ? "True" : "False"
  enable_ces                          = local.scale_ces_enabled == true ? "True" : "False"
  enable_afm                          = local.enable_afm == true ? "True" : "False"
  scale_encryption_enabled            = var.scale_encryption_enabled
  scale_encryption_type               = var.scale_encryption_type
  scale_encryption_admin_password     = var.scale_encryption_admin_password
  scale_encryption_servers            = var.scale_encryption_enabled && var.scale_encryption_type == "gklm" ? jsonencode(one(module.gklm_instance[*].gklm_ip_addresses)) : null
  enable_ldap                         = var.enable_ldap
  ldap_basedns                        = var.ldap_basedns
  ldap_server                         = local.ldap_server
  ldap_admin_password                 = var.ldap_admin_password
  ldap_server_cert                    = var.ldap_server_cert
  enable_key_protect                  = var.scale_encryption_type == "key_protect" ? "True" : "False"
  depends_on                          = [module.ldap_configuration]
}

module "combined_cluster_configuration" {
  source                          = "../../../resources/common/scale_configuration"
  turn_on                         = var.create_separate_namespaces == false ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  bastion_user                    = jsonencode(var.bastion_user)
  write_inventory_complete        = module.write_cluster_inventory.write_inventory_complete
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = var.storage_type == "persistent" ? data.ibm_is_bare_metal_server_profile.storage_bare_metal_server_profile[0].memory[0].value : data.ibm_is_instance_profile.storage_profile.memory[0].value
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = var.scale_encryption_enabled
  scale_encryption_admin_password = var.scale_encryption_admin_password
  scale_encryption_servers        = var.scale_encryption_enabled ? jsonencode(one(module.gklm_instance[*].gklm_ip_addresses)) : null
  enable_ldap                     = var.enable_ldap
  ldap_basedns                    = var.ldap_basedns
  ldap_server                     = local.ldap_server
  ldap_admin_password             = var.ldap_admin_password
  depends_on                      = [module.ldap_configuration]
}

module "client_configuration" {
  source                          = "../../../resources/common/client_configuration"
  turn_on                         = (var.total_client_cluster_instances > 0 && var.create_separate_namespaces == true && local.scale_ces_enabled == true) ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  create_scale_cluster            = var.create_scale_cluster
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
  clone_path                      = var.scale_ansible_repo_clone_path
  using_jumphost_connection       = var.using_jumphost_connection
  client_inventory_path           = format("%s/client_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  bastion_user                    = jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  client_meta_private_key         = module.generate_client_cluster_keys.private_key_content
  write_inventory_complete        = module.write_storage_cluster_inventory.write_inventory_complete
  enable_ldap                     = var.enable_ldap
  ldap_basedns                    = var.ldap_basedns
  ldap_server                     = local.ldap_server
  ldap_admin_password             = var.ldap_admin_password
  depends_on                      = [module.compute_cluster_configuration, module.storage_cluster_configuration, module.combined_cluster_configuration, module.ldap_configuration]
}

module "remote_mount_configuration" {
  source                          = "../../../resources/common/remote_mount_configuration"
  turn_on                         = (var.total_compute_cluster_instances > 0 && var.total_storage_cluster_instances > 0 && var.create_separate_namespaces == true) ? true : false
  create_scale_cluster            = var.create_scale_cluster
  bastion_user                    = jsonencode(var.bastion_user)
  clone_path                      = var.scale_ansible_repo_clone_path
  compute_inventory_path          = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  compute_gui_inventory_path      = format("%s/compute_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  storage_inventory_path          = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  storage_gui_inventory_path      = format("%s/storage_cluster_gui_details.json", var.scale_ansible_repo_clone_path)
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  bastion_instance_public_ip      = var.bastion_instance_public_ip
  bastion_ssh_private_key         = var.bastion_ssh_private_key
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
  depends_on                      = [module.gklm_instance, module.compute_cluster_configuration, module.storage_cluster_configuration, module.combined_cluster_configuration]
}

module "invoke_compute_network_playbook" {
  source                          = "../../../resources/common/network_playbook"
  turn_on                         = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  create_scale_cluster            = var.create_scale_cluster
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
  inventory_path                  = format("%s/%s/compute_inventory.ini", var.scale_ansible_repo_clone_path, "ibm-spectrum-scale-install-infra")
  network_playbook_path           = format("%s/%s/collections/ansible_collections/ibm/spectrum_scale/samples/playbook_cloud_network_config.yaml", var.scale_ansible_repo_clone_path, "ibm-spectrum-scale-install-infra")
}

module "invoke_storage_network_playbook" {
  source                          = "../../../resources/common/network_playbook"
  turn_on                         = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? true : false
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  create_scale_cluster            = var.create_scale_cluster
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
  inventory_path                  = format("%s/%s/storage_inventory.ini", var.scale_ansible_repo_clone_path, "ibm-spectrum-scale-install-infra")
  network_playbook_path           = format("%s/%s/collections/ansible_collections/ibm/spectrum_scale/samples/playbook_cloud_network_config.yaml", var.scale_ansible_repo_clone_path, "ibm-spectrum-scale-install-infra")
}

module "encryption_configuration" {
  source                                  = "../../../resources/common/encryption_configuration"
  turn_on                                 = var.scale_encryption_enabled == true ? true : false
  clone_path                              = var.scale_ansible_repo_clone_path
  clone_complete                          = module.prepare_ansible_configuration.clone_complete
  create_scale_cluster                    = var.create_scale_cluster
  scale_cluster_clustername               = var.resource_prefix
  scale_encryption_admin_default_password = var.scale_encryption_admin_default_password
  scale_encryption_admin_password         = var.scale_encryption_admin_password
  scale_encryption_admin_username         = var.scale_encryption_admin_username
  scale_encryption_type                   = var.scale_encryption_type
  scale_encryption_servers                = var.scale_encryption_type == "gklm" ? jsonencode(one(module.gklm_instance[*].gklm_ip_addresses)) : jsonencode([])
  scale_encryption_servers_dns            = var.scale_encryption_type == "gklm" ? jsonencode(one(module.gklm_instance[*].gklm_dns_names)) : jsonencode([])
  meta_private_key                        = var.scale_encryption_type == "gklm" ? module.generate_gklm_instance_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  storage_cluster_encryption              = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? true : false
  compute_cluster_encryption              = (var.create_separate_namespaces == true && var.total_compute_cluster_instances >= 0) ? true : false
  combined_cluster_encryption             = var.create_separate_namespaces == false ? true : false
  compute_cluster_create_complete         = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete         = module.storage_cluster_configuration.storage_cluster_create_complete
  combined_cluster_create_complete        = module.combined_cluster_configuration.combined_cluster_create_complete
  remote_mount_create_complete            = module.remote_mount_configuration.remote_mount_create_complete
  depends_on                              = [module.gklm_instance, module.compute_cluster_configuration, module.storage_cluster_configuration, module.combined_cluster_configuration, module.remote_mount_configuration]
}

module "ldap_configuration" {
  source                     = "../../../resources/common/ldap_configuration"
  turn_on                    = var.enable_ldap && var.ldap_server == "null"
  clone_path                 = var.scale_ansible_repo_clone_path
  clone_complete             = module.prepare_ansible_configuration.clone_complete
  create_scale_cluster       = var.create_scale_cluster
  bastion_user               = jsonencode(var.bastion_user)
  write_inventory_complete   = module.write_storage_cluster_inventory.write_inventory_complete
  ldap_cluster_prefix        = var.resource_prefix
  script_path                = format("%s/%s/resources/common/scripts/prepare_ldap_inv.py", var.scale_ansible_repo_clone_path, "ibm-spectrum-scale-cloud-install")
  using_jumphost_connection  = var.using_jumphost_connection
  bastion_instance_public_ip = var.bastion_instance_public_ip
  bastion_ssh_private_key    = var.bastion_ssh_private_key
  ldap_basedns               = var.ldap_basedns
  ldap_admin_password        = var.ldap_admin_password
  ldap_user_name             = var.ldap_user_name
  ldap_user_password         = var.ldap_user_password
  ldap_server                = jsonencode(one(module.ldap_instance[*].vsi_private_ip))
  meta_private_key           = module.generate_ldap_instance_keys.private_key_content
  depends_on                 = [module.ldap_instance]
}
