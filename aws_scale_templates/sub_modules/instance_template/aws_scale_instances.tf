/*
    This nested module creates;
    1. Spin storage instances
    2. Spin compute instances
    3. Attach instance profiles to storage, compute instances
    4. Attach EBS volumes to storage instancesBastion Host Role

    Tags are not allowed for EBS, root volumes.
*/

module "cluster_host_iam_role" {
  source           = "../../../resources/aws/compute/iam/iam_role"
  role_name_prefix = "${var.stack_name}-Cluster-"
  role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

module "cluster_host_iam_policy" {
  source                  = "../../../resources/aws/compute/iam/iam_role_policy"
  role_policy_name_prefix = "${var.stack_name}-Cluster-"
  iam_role_id             = module.cluster_host_iam_role.iam_role_id
  iam_role_policy         = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Resource": "*",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:Describe*",
                "ec2:CreateTags*",
                "ec2:ModifyInstanceAttribute",
                "sns:DeleteTopic",
                "sns:CreateTopic",
                "sns:Unsubscribe",
                "sns:Subscribe"
            ]
        }
    ]
}
EOF
}

module "cluster_instance_iam_profile" {
  source                       = "../../../resources/aws/compute/iam/iam_instance_profile"
  instance_profile_name_prefix = "${var.stack_name}-Cluster-"
  iam_host_role                = module.cluster_host_iam_policy.role_policy_name
}

module "compute_security_group" {
  source                = "../../../resources/aws/security/security_group"
  total_sec_groups      = 1
  sec_group_name        = ["Compute-Sec-group"]
  sec_group_description = ["Enable SSH access to the compute host"]
  vpc_id                = [var.vpc_id]
  sec_group_tag_name    = ["Compute-Sec-group"]
}

module "storage_security_group" {
  source                = "../../../resources/aws/security/security_group"
  total_sec_groups      = 1
  sec_group_name        = ["Storage-Sec-group"]
  sec_group_description = ["Enable SSH access to the storage host"]
  vpc_id                = [var.vpc_id]
  sec_group_tag_name    = ["Storage-Sec-group"]
}

locals {
  is_deploy_sec_id_needed = var.deploy_container_sec_group_id == null ? 1 : 0
}

module "deploy_security_group" {
  source                = "../../../resources/aws/security/security_group"
  total_sec_groups      = local.is_deploy_sec_id_needed
  sec_group_name        = ["Deploy-Sec-group"]
  sec_group_description = ["Dummy security group"]
  vpc_id                = [var.vpc_id]
  sec_group_tag_name    = ["Deploy-Sec-group"]
}

locals {
  deploy_sec_group_id = var.deploy_container_sec_group_id == null ? module.deploy_security_group.sec_group_id[0] : var.deploy_container_sec_group_id
}

module "instances_egress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = 2
  security_group_id         = [module.compute_security_group.sec_group_id[0], module.storage_security_group.sec_group_id[0]]
  security_rule_description = ["Outgoing traffic from compute instances", "Outgoing traffic from storage instances"]
  security_rule_type        = ["egress", "egress"]
  traffic_protocol          = ["-1", "-1"]
  traffic_from_port         = ["0", "0"]
  traffic_to_port           = ["6335", "6335"]
  cidr_blocks               = var.egress_access_cidr
  security_prefix_list_ids  = null
}

module "instances_ingress_security_rule" {
  source      = "../../../resources/aws/security/security_rule_source"
  total_rules = 8
  security_group_id = [module.compute_security_group.sec_group_id[0], module.compute_security_group.sec_group_id[0],
    module.compute_security_group.sec_group_id[0], module.compute_security_group.sec_group_id[0],
    module.storage_security_group.sec_group_id[0], module.storage_security_group.sec_group_id[0],
  module.storage_security_group.sec_group_id[0], module.storage_security_group.sec_group_id[0]]
  security_rule_description = ["Incoming traffic to compute instances", "Incoming traffic to compute instances",
    "Incoming traffic from deploy container", "Incoming traffic to compute instances",
    "Incoming traffic to storage instances", "Incoming traffic to storage instances",
  "Incoming traffic from deploy container", "Incoming traffic to storage instances"]
  security_rule_type = ["ingress", "ingress", "ingress", "ingress", "ingress", "ingress", "ingress", "ingress"]
  traffic_protocol   = ["-1", "-1", "-1", "TCP", "-1", "-1", "-1", "TCP"]
  traffic_from_port  = ["0", "0", "0", "22", "0", "0", "0", "22"]
  traffic_to_port    = ["6335", "6335", "6335", "22", "6335", "6335", "6335", "22"]
  source_security_group_id = [module.storage_security_group.sec_group_id[0], module.compute_security_group.sec_group_id[0],
    local.deploy_sec_group_id, var.bastion_sec_group_id,
    module.storage_security_group.sec_group_id[0], module.compute_security_group.sec_group_id[0],
  local.deploy_sec_group_id, var.bastion_sec_group_id]
}

module "ansible_vault" {
  source = "../../../resources/common/ansible_vault"
}

module "email_notification" {
  source         = "../../../resources/aws/sns"
  operator_email = var.operator_email
  sns_topic_name = "${var.stack_name}-topic"
  region         = var.region
}

module "compute_instances" {
  source          = "../../../resources/aws/compute/ec2"
  region          = var.region
  ami_id          = var.compute_ami_id
  instance_type   = var.compute_instance_type
  key_name        = var.key_name
  total_ec2_count = var.total_compute_instances - 1

  enable_delete_on_termination           = var.root_volume_enable_delete_on_termination
  enable_instance_termination_protection = var.enable_instance_termination_protection
  instance_iam_instance_profile          = module.cluster_instance_iam_profile.iam_instance_profile_name
  instance_placement_group               = null
  instance_security_groups               = [module.compute_security_group.sec_group_id[0]]
  instance_subnet_ids                    = var.private_instance_subnet_ids
  root_volume_size                       = var.compute_root_volume_size
  root_volume_type                       = var.compute_root_volume_type

  total_ebs_volumes = 0
  ebs_volume_type   = var.ebs_volume_type
  ebs_volume_size   = var.ebs_volume_size
  device_names      = var.ebs_volume_device_names

  vault_private_key = module.ansible_vault.id_rsa_content
  vault_public_key  = module.ansible_vault.id_rsa_pub_content

  instance_tags = { Name = "${var.stack_name}-compute" }
}

module "desc_compute_instance" {
  source          = "../../../resources/aws/compute/ec2"
  region          = var.region
  ami_id          = var.compute_ami_id
  instance_type   = var.compute_instance_type
  key_name        = var.key_name
  total_ec2_count = 1

  enable_delete_on_termination           = var.root_volume_enable_delete_on_termination
  enable_instance_termination_protection = var.enable_instance_termination_protection
  instance_iam_instance_profile          = module.cluster_instance_iam_profile.iam_instance_profile_name
  instance_placement_group               = null
  instance_security_groups               = [module.compute_security_group.sec_group_id[0]]
  instance_subnet_ids                    = var.private_instance_subnet_ids
  root_volume_size                       = var.compute_root_volume_size
  root_volume_type                       = var.compute_root_volume_type

  total_ebs_volumes = 1
  ebs_volume_type   = "gp2"
  ebs_volume_size   = 5
  device_names      = var.ebs_volume_device_names

  vault_private_key = module.ansible_vault.id_rsa_content
  vault_public_key  = module.ansible_vault.id_rsa_pub_content

  instance_tags = { Name = "${var.stack_name}-compute-desc" }
}

module "storage_instances" {
  source          = "../../../resources/aws/compute/ec2"
  region          = var.region
  ami_id          = var.storage_ami_id == null ? var.compute_ami_id : var.storage_ami_id
  instance_type   = var.storage_instance_type
  key_name        = var.key_name
  total_ec2_count = var.total_storage_instances

  enable_delete_on_termination           = var.root_volume_enable_delete_on_termination
  enable_instance_termination_protection = var.enable_instance_termination_protection
  instance_iam_instance_profile          = module.cluster_instance_iam_profile.iam_instance_profile_name
  instance_placement_group               = null
  instance_security_groups               = [module.storage_security_group.sec_group_id[0]]
  instance_subnet_ids                    = var.private_instance_subnet_ids
  root_volume_size                       = var.storage_root_volume_size
  root_volume_type                       = var.storage_root_volume_type

  total_ebs_volumes = var.ebs_volumes_per_instance
  ebs_volume_type   = var.ebs_volume_type
  ebs_volume_size   = var.ebs_volume_size
  device_names      = var.ebs_volume_device_names

  vault_private_key = module.ansible_vault.id_rsa_content
  vault_public_key  = module.ansible_vault.id_rsa_pub_content

  instance_tags = { Name = "${var.stack_name}-storage" }
}

locals {
  compute_instance_desc_map = {
    for instance in module.desc_compute_instance.instance_ips_with_1_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 1)
  }
  instance_ips_with_0_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 0 ? {
    for instance in module.storage_instances.instance_ips_with_0_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 0)
  } : null
  instance_ips_with_1_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 1 ? {
    for instance in module.storage_instances.instance_ips_with_1_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 1)
  } : null
  instance_ips_with_2_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 2 ? {
    for instance in module.storage_instances.instance_ips_with_2_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 2)
  } : null
  instance_ips_with_3_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 3 ? {
    for instance in module.storage_instances.instance_ips_with_3_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 3)
  } : null
  instance_ips_with_4_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 4 ? {
    for instance in module.storage_instances.instance_ips_with_4_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 4)
  } : null
  instance_ips_with_5_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 5 ? {
    for instance in module.storage_instances.instance_ips_with_5_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 5)
  } : null
  instance_ips_with_6_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 6 ? {
    for instance in module.storage_instances.instance_ips_with_6_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 6)
  } : null
  instance_ips_with_7_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 7 ? {
    for instance in module.storage_instances.instance_ips_with_7_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 7)
  } : null
  instance_ips_with_8_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 8 ? {
    for instance in module.storage_instances.instance_ips_with_8_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 8)
  } : null
  instance_ips_with_9_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 9 ? {
    for instance in module.storage_instances.instance_ips_with_9_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 9)
  } : null
  instance_ips_with_10_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 10 ? {
    for instance in module.storage_instances.instance_ips_with_10_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 10)
  } : null
  instance_ips_with_11_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 11 ? {
    for instance in module.storage_instances.instance_ips_with_11_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 11)
  } : null
  instance_ips_with_12_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 12 ? {
    for instance in module.storage_instances.instance_ips_with_12_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 12)
  } : null
  instance_ips_with_13_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 13 ? {
    for instance in module.storage_instances.instance_ips_with_13_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 13)
  } : null
  instance_ips_with_14_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 14 ? {
    for instance in module.storage_instances.instance_ips_with_14_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 14)
  } : null
  instance_ips_with_15_datadisks_ebs_device_names = tonumber(var.ebs_volumes_per_instance) == 15 ? {
    for instance in module.storage_instances.instance_ips_with_15_datadisks :
    instance => slice(var.ebs_volume_device_names, 0, 15)
  } : null
}

module "invoke_scale_playbook" {
  source                                                  = "../../../resources/common/ansible_scale_playbook"
  ansible_scale_repo_clone_path                           = var.ansible_scale_repo_clone_path
  create_scale_cluster                                    = var.create_scale_cluster
  filesystem_mountpoint                                   = var.filesystem_mountpoint
  filesystem_block_size                                   = var.filesystem_block_size
  cloud_env                                               = var.cloud_env
  cloud_platform                                          = var.cloud_platform
  avail_zones                                             = jsonencode(var.availability_zones)
  compute_instances_by_ip                                 = module.compute_instances.instance_ips_with_0_datadisks == null ? "[]" : jsonencode(module.compute_instances.instance_ips_with_0_datadisks)
  compute_instance_desc_map                               = jsonencode(local.compute_instance_desc_map)
  storage_instance_ips_with_0_datadisks_device_names_map  = local.instance_ips_with_0_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_0_datadisks_ebs_device_names)
  storage_instance_ips_with_1_datadisks_device_names_map  = local.instance_ips_with_1_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_1_datadisks_ebs_device_names)
  storage_instance_ips_with_2_datadisks_device_names_map  = local.instance_ips_with_2_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_2_datadisks_ebs_device_names)
  storage_instance_ips_with_3_datadisks_device_names_map  = local.instance_ips_with_3_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_3_datadisks_ebs_device_names)
  storage_instance_ips_with_4_datadisks_device_names_map  = local.instance_ips_with_4_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_4_datadisks_ebs_device_names)
  storage_instance_ips_with_5_datadisks_device_names_map  = local.instance_ips_with_5_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_5_datadisks_ebs_device_names)
  storage_instance_ips_with_6_datadisks_device_names_map  = local.instance_ips_with_6_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_6_datadisks_ebs_device_names)
  storage_instance_ips_with_7_datadisks_device_names_map  = local.instance_ips_with_7_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_7_datadisks_ebs_device_names)
  storage_instance_ips_with_8_datadisks_device_names_map  = local.instance_ips_with_8_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_8_datadisks_ebs_device_names)
  storage_instance_ips_with_9_datadisks_device_names_map  = local.instance_ips_with_9_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_9_datadisks_ebs_device_names)
  storage_instance_ips_with_10_datadisks_device_names_map = local.instance_ips_with_10_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_10_datadisks_ebs_device_names)
  storage_instance_ips_with_11_datadisks_device_names_map = local.instance_ips_with_11_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_11_datadisks_ebs_device_names)
  storage_instance_ips_with_12_datadisks_device_names_map = local.instance_ips_with_12_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_12_datadisks_ebs_device_names)
  storage_instance_ips_with_13_datadisks_device_names_map = local.instance_ips_with_13_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_13_datadisks_ebs_device_names)
  storage_instance_ips_with_14_datadisks_device_names_map = local.instance_ips_with_14_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_14_datadisks_ebs_device_names)
  storage_instance_ips_with_15_datadisks_device_names_map = local.instance_ips_with_15_datadisks_ebs_device_names == null ? "[]" : jsonencode(local.instance_ips_with_15_datadisks_ebs_device_names)
}
