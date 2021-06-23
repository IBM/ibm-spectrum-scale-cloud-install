/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

locals {
  ebs_device_names = ["/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj",
  "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt"]
}

#terraform {
#  backend "s3" {}
#}

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_compute_cluster_instances > 0 ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = var.total_storage_cluster_instances > 0 ? true : false
}

module "cluster_host_iam_role" {
  source           = "../../../resources/aws/security/iam/iam_role"
  role_name_prefix = format("%s-cluster-", var.resource_prefix)
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
  source                  = "../../../resources/aws/security/iam/iam_role_policy"
  role_policy_name_prefix = format("%s-cluster-", var.resource_prefix)
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
                "iam:GetRole",
                "ssm:DescribeParameters",
                "ssm:PutParameter",
                "ssm:GetParameter",
                "ssm:DeleteParameters",
                "sns:DeleteTopic",
                "sns:CreateTopic",
                "sns:Unsubscribe",
                "sns:Subscribe",
                "sns:Publish"
            ]
        }
    ]
}
EOF
}

module "cluster_instance_iam_profile" {
  source                       = "../../../resources/aws/security/iam/iam_instance_profile"
  instance_profile_name_prefix = format("%s-cluster-", var.resource_prefix)
  iam_host_role                = module.cluster_host_iam_policy.role_policy_name
}

module "compute_cluster_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = var.total_compute_cluster_instances > 0 ? true : false
  sec_group_name        = ["compute-sec-group-"]
  sec_group_description = ["Enable SSH access to the compute cluster hosts"]
  vpc_id                = var.vpc_id
  sec_group_tag         = ["compute-sec-group"]
}

module "compute_cluster_ingress_security_rule" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = (var.total_compute_cluster_instances > 0 && var.bastion_security_group_id != null) ? 17 : 0
  security_group_id = [module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from bastion to compute instances",
    "Allow SSH traffic from bastion to compute instances",
    "Allow ICMP traffic within compute instances",
    "Allow SSH traffic within compute instances",
    "Allow GPFS intra cluster traffic within compute instances",
    "Allow GPFS ephemeral port range within compute instances",
    "Allow management GUI (http/localhost) TCP traffic within compute instances",
    "Allow management GUI (http/localhost) UDP traffic within compute instances",
    "Allow management GUI (https/localhost) TCP traffic within compute instances",
    "Allow management GUI (https/localhost) UDP traffic within compute instances",
    "Allow management GUI (localhost) TCP traffic within compute instances",
    "Allow management GUI (localhost) UDP traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow http traffic within compute instances",
  "Allow https traffic within compute instances"]
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, -1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  traffic_to_port    = [-1, 22, -1, 22, 1191, 61000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  source_security_group_id = [var.bastion_security_group_id, var.bastion_security_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
  module.compute_cluster_security_group.sec_group_id]
}

module "compute_cluster_ingress_security_rule_wo_bastion" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = (var.total_compute_cluster_instances > 0 && var.bastion_security_group_id == null) ? 15 : 0
  security_group_id = [module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic within compute instances",
    "Allow SSH traffic within compute instances",
    "Allow GPFS intra cluster traffic within compute instances",
    "Allow GPFS ephemeral port range within compute instances",
    "Allow management GUI (http/localhost) TCP traffic within compute instances",
    "Allow management GUI (http/localhost) UDP traffic within compute instances",
    "Allow management GUI (https/localhost) TCP traffic within compute instances",
    "Allow management GUI (https/localhost) UDP traffic within compute instances",
    "Allow management GUI (localhost) TCP traffic within compute instances",
    "Allow management GUI (localhost) UDP traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow performance monitoring collector traffic within compute instances",
    "Allow http traffic within compute instances",
  "Allow https traffic within compute instances"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  traffic_to_port          = [-1, 22, 1191, 61000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  source_security_group_id = [module.compute_cluster_security_group.sec_group_id]
}

module "cluster_egress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = (var.total_compute_cluster_instances > 0 && var.total_storage_cluster_instances > 0) ? 2 : 1
  security_group_id         = (var.total_compute_cluster_instances > 0 && var.total_storage_cluster_instances > 0) ? [module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id] : (var.total_compute_cluster_instances > 0 ? [module.compute_cluster_security_group.sec_group_id] : [module.storage_cluster_security_group.sec_group_id])
  security_rule_description = (var.total_compute_cluster_instances > 0 && var.total_storage_cluster_instances > 0) ? ["Outgoing traffic from compute instances", "Outgoing traffic from storage instances"] : (var.total_compute_cluster_instances > 0 ? ["Outgoing traffic from compute instances"] : ["Outgoing traffic from storage instances"])
  security_rule_type        = ["egress", "egress"]
  traffic_protocol          = ["-1", "-1"]
  traffic_from_port         = ["0", "0"]
  traffic_to_port           = ["6335", "6335"]
  cidr_blocks               = ["0.0.0.0/0"]
  security_prefix_list_ids  = null
}

module "storage_cluster_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = var.total_storage_cluster_instances > 0 ? true : false
  sec_group_name        = ["storage-sec-group-"]
  sec_group_description = ["Enable SSH access to the storage cluster hosts"]
  vpc_id                = var.vpc_id
  sec_group_tag         = ["storage-sec-group"]
}

module "storage_cluster_ingress_security_rule" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = (var.total_storage_cluster_instances > 0 && var.bastion_security_group_id != null) ? 17 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from bastion to storage instances",
    "Allow SSH traffic from bastion to storage instances",
    "Allow ICMP traffic within storage instances",
    "Allow SSH traffic within storage instances",
    "Allow GPFS intra cluster traffic within storage instances",
    "Allow GPFS ephemeral port range within storage instances",
    "Allow management GUI (http/localhost) TCP traffic within storage instances",
    "Allow management GUI (http/localhost) UDP traffic within storage instances",
    "Allow management GUI (https/localhost) TCP traffic within storage instances",
    "Allow management GUI (https/localhost) UDP traffic within storage instances",
    "Allow management GUI (localhost) TCP traffic within storage instances",
    "Allow management GUI (localhost) UDP traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow http traffic within storage instances",
  "Allow https traffic within storage instances"]
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, -1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  traffic_to_port    = [-1, 22, -1, 22, 1191, 61000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  source_security_group_id = [var.bastion_security_group_id, var.bastion_security_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
  module.storage_cluster_security_group.sec_group_id]
}

module "storage_cluster_ingress_security_rule_wo_bastion" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = (var.total_storage_cluster_instances > 0 && var.bastion_security_group_id == null) ? 15 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic within storage instances",
    "Allow SSH traffic within storage instances",
    "Allow GPFS intra cluster traffic within storage instances",
    "Allow GPFS ephemeral port range within storage instances",
    "Allow management GUI (http/localhost) TCP traffic within storage instances",
    "Allow management GUI (http/localhost) UDP traffic within storage instances",
    "Allow management GUI (https/localhost) TCP traffic within storage instances",
    "Allow management GUI (https/localhost) UDP traffic within storage instances",
    "Allow management GUI (localhost) TCP traffic within storage instances",
    "Allow management GUI (localhost) UDP traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow performance monitoring collector traffic within storage instances",
    "Allow http traffic within storage instances",
  "Allow https traffic within storage instances"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  traffic_to_port          = [-1, 22, 1191, 61000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  source_security_group_id = [module.storage_cluster_security_group.sec_group_id]
}

module "bicluster_ingress_security_rule" {
  source      = "../../../resources/aws/security/security_rule_source"
  total_rules = (var.total_storage_cluster_instances > 0 && var.total_compute_cluster_instances > 0) ? 30 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
  module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from compute to storage instances",
    "Allow SSH traffic from compute to storage instances",
    "Allow GPFS intra cluster traffic from compute to storage instances",
    "Allow GPFS ephemeral port range from compute to storage instances",
    "Allow management GUI (http/localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (http/localhost) UDP traffic from compute to storage instances",
    "Allow management GUI (https/localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (https/localhost) UDP traffic from compute to storage instances",
    "Allow management GUI (localhost) TCP traffic from compute to storage instances",
    "Allow management GUI (localhost) UDP traffic from compute to storage instances",
    "Allow performance monitoring collector traffic from compute to storage instances",
    "Allow performance monitoring collector traffic from compute to storage instances",
    "Allow performance monitoring collector traffic from compute to storage instances",
    "Allow http traffic from compute to storage instances",
    "Allow https traffic from compute to storage instances",
    "Allow ICMP traffic from storage to compute instances",
    "Allow SSH traffic from storage to compute instances",
    "Allow GPFS intra cluster traffic from storage to compute instances",
    "Allow GPFS ephemeral port range from storage to compute instances",
    "Allow management GUI (http/localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (http/localhost) UDP traffic from storage to compute instances",
    "Allow management GUI (https/localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (https/localhost) UDP traffic from storage to compute instances",
    "Allow management GUI (localhost) TCP traffic from storage to compute instances",
    "Allow management GUI (localhost) UDP traffic from storage to compute instances",
    "Allow performance monitoring collector traffic from storage to compute instances",
    "Allow performance monitoring collector traffic from storage to compute instances",
    "Allow performance monitoring collector traffic from storage to compute instances",
    "Allow http traffic from storage to compute instances",
  "Allow https traffic from storage to compute instances"]
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "UDP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443, -1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  traffic_to_port    = [-1, 22, 1191, 61000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443, -1, 22, 1191, 60000, 47080, 47080, 47443, 47443, 4444, 4444, 4739, 9084, 9085, 80, 443]
  source_security_group_id = [module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
  module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "email_notification" {
  source         = "../../../resources/aws/sns"
  operator_email = var.operator_email
  topic_name     = format("%s-topic", var.resource_prefix)
  vpc_region     = var.vpc_region
}

data "aws_ec2_instance_type" "compute_profile" {
  instance_type = var.compute_cluster_instance_type
}

module "compute_cluster_instances" {
  source               = "../../../resources/aws/compute/ec2_0_vol"
  instances_count      = var.total_compute_cluster_instances
  name_prefix          = format("%s-compute", var.resource_prefix)
  ami_id               = var.compute_cluster_ami_id
  instance_type        = var.compute_cluster_instance_type
  security_groups      = [module.compute_cluster_security_group.sec_group_id]
  iam_instance_profile = module.cluster_instance_iam_profile.iam_instance_profile_name
  placement_group      = null
  subnet_ids           = length(var.vpc_compute_cluster_private_subnets) > 0 ? var.vpc_compute_cluster_private_subnets : var.vpc_storage_cluster_private_subnets
  root_volume_type     = var.compute_cluster_root_volume_type
  user_public_key      = var.compute_cluster_key_pair
  meta_private_key     = module.generate_compute_cluster_keys.private_key_content
  meta_public_key      = module.generate_compute_cluster_keys.public_key_content
  volume_tags          = var.compute_cluster_volume_tags
  tags                 = var.compute_cluster_tags
}

data "aws_ec2_instance_type" "storage_profile" {
  instance_type = var.storage_cluster_instance_type
}

module "storage_cluster_instances" {
  source                                 = "../../../resources/aws/compute/ec2_multiple_vol"
  instances_count                        = var.total_storage_cluster_instances
  name_prefix                            = format("%s-storage", var.resource_prefix)
  ami_id                                 = var.storage_cluster_ami_id
  instance_type                          = var.storage_cluster_instance_type
  security_groups                        = [module.storage_cluster_security_group.sec_group_id]
  iam_instance_profile                   = module.cluster_instance_iam_profile.iam_instance_profile_name
  placement_group                        = null
  subnet_ids                             = length(var.vpc_storage_cluster_private_subnets) > 1 ? slice(var.vpc_storage_cluster_private_subnets, 0, 2) : var.vpc_storage_cluster_private_subnets
  root_volume_type                       = var.storage_cluster_root_volume_type
  user_public_key                        = var.storage_cluster_key_pair
  meta_private_key                       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                        = module.generate_storage_cluster_keys.public_key_content
  volume_tags                            = var.storage_cluster_volume_tags
  ebs_optimized                          = data.aws_ec2_instance_type.storage_profile.ebs_optimized_support == "unsupported" ? false : true
  ebs_block_devices                      = var.ebs_block_devices_per_storage_instance
  ebs_block_device_names                 = local.ebs_device_names
  ebs_block_device_delete_on_termination = var.ebs_block_device_delete_on_termination
  ebs_block_device_encrypted             = var.ebs_block_device_encrypted
  ebs_block_device_kms_key_id            = var.ebs_block_device_kms_key_id
  ebs_block_device_volume_size           = var.ebs_block_device_volume_size
  ebs_block_device_volume_type           = var.ebs_block_device_volume_type
  ebs_block_device_iops                  = var.ebs_block_device_iops
  enable_nvme_block_device               = var.enable_nvme_block_device
  nvme_block_device_count                = tolist(data.aws_ec2_instance_type.storage_profile.instance_disks)[0].count
  tags                                   = var.storage_cluster_tags
}

module "storage_cluster_tie_breaker_instance" {
  source                                 = "../../../resources/aws/compute/ec2_multiple_vol"
  instances_count                        = (length(var.vpc_storage_cluster_private_subnets) > 1 && var.total_storage_cluster_instances > 0) ? 1 : 0
  name_prefix                            = format("%s-storage-tie", var.resource_prefix)
  ami_id                                 = var.storage_cluster_ami_id
  instance_type                          = var.storage_cluster_tiebreaker_instance_type
  security_groups                        = [module.storage_cluster_security_group.sec_group_id]
  iam_instance_profile                   = module.cluster_instance_iam_profile.iam_instance_profile_name
  placement_group                        = null
  subnet_ids                             = length(var.vpc_storage_cluster_private_subnets) > 1 ? [var.vpc_storage_cluster_private_subnets[2]] : var.vpc_storage_cluster_private_subnets
  root_volume_type                       = var.storage_cluster_root_volume_type
  user_public_key                        = var.storage_cluster_key_pair
  meta_private_key                       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key                        = module.generate_storage_cluster_keys.public_key_content
  volume_tags                            = var.storage_cluster_volume_tags
  ebs_optimized                          = data.aws_ec2_instance_type.storage_profile.ebs_optimized_support == "unsupported" ? false : true
  ebs_block_devices                      = 1
  ebs_block_device_names                 = local.ebs_device_names
  ebs_block_device_delete_on_termination = var.ebs_block_device_delete_on_termination
  ebs_block_device_encrypted             = var.ebs_block_device_encrypted
  ebs_block_device_kms_key_id            = var.ebs_block_device_kms_key_id
  ebs_block_device_volume_size           = 5
  ebs_block_device_volume_type           = var.ebs_block_device_volume_type
  ebs_block_device_iops                  = var.ebs_block_device_iops
  enable_nvme_block_device               = var.enable_nvme_block_device
  nvme_block_device_count                = tolist(data.aws_ec2_instance_type.storage_profile.instance_disks)[0].count
  tags                                   = var.storage_cluster_tags
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
  inventory_path                            = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("AWS")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vpc_region)
  vpc_availability_zones                    = jsonencode(var.vpc_availability_zones)
  scale_version                             = jsonencode(var.scale_version)
  filesystem_block_size                     = jsonencode("None")
  compute_cluster_filesystem_mountpoint     = jsonencode(var.compute_cluster_filesystem_mountpoint)
  compute_cluster_gui_username              = jsonencode(var.compute_cluster_gui_username)
  compute_cluster_gui_password              = jsonencode(var.compute_cluster_gui_password)
  compute_cluster_instance_ids              = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips      = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint     = jsonencode("None")
  storage_cluster_instance_ids              = jsonencode([])
  storage_cluster_instance_private_ips      = jsonencode([])
  storage_cluster_with_data_volume_mapping  = jsonencode({})
  storage_cluster_gui_username              = jsonencode(var.storage_cluster_gui_username)
  storage_cluster_gui_password              = jsonencode(var.storage_cluster_gui_password)
  storage_cluster_desc_instance_ids         = jsonencode([])
  storage_cluster_desc_instance_private_ips = jsonencode([])
  storage_cluster_desc_data_volume_mapping  = jsonencode({})
  depends_on                                = [module.prepare_ansible_configuration]
}

module "write_storage_cluster_inventory" {
  source                                    = "../../../resources/common/write_inventory"
  write_inventory                           = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? 1 : 0
  inventory_path                            = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("AWS")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vpc_region)
  vpc_availability_zones                    = jsonencode(var.vpc_availability_zones)
  scale_version                             = jsonencode(var.scale_version)
  filesystem_block_size                     = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint     = jsonencode("None")
  compute_cluster_gui_username              = jsonencode(var.compute_cluster_gui_username)
  compute_cluster_gui_password              = jsonencode(var.compute_cluster_gui_password)
  compute_cluster_instance_ids              = jsonencode([])
  compute_cluster_instance_private_ips      = jsonencode([])
  storage_cluster_filesystem_mountpoint     = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids              = jsonencode(module.storage_cluster_instances.instance_ids)
  storage_cluster_instance_private_ips      = jsonencode(module.storage_cluster_instances.instance_private_ips)
  storage_cluster_with_data_volume_mapping  = jsonencode(module.storage_cluster_instances.instance_ips_with_ebs_mapping)
  storage_cluster_gui_username              = jsonencode(var.storage_cluster_gui_username)
  storage_cluster_gui_password              = jsonencode(var.storage_cluster_gui_password)
  storage_cluster_desc_instance_ids         = jsonencode(module.storage_cluster_tie_breaker_instance.instance_ids)
  storage_cluster_desc_instance_private_ips = jsonencode(module.storage_cluster_tie_breaker_instance.instance_private_ips)
  storage_cluster_desc_data_volume_mapping  = jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_ebs_mapping)
  depends_on                                = [module.prepare_ansible_configuration]
}

module "write_cluster_inventory" {
  source                                    = "../../../resources/common/write_inventory"
  write_inventory                           = var.create_separate_namespaces == false ? 1 : 0
  inventory_path                            = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  cloud_platform                            = jsonencode("AWS")
  resource_prefix                           = jsonencode(var.resource_prefix)
  vpc_region                                = jsonencode(var.vpc_region)
  vpc_availability_zones                    = jsonencode(var.vpc_availability_zones)
  scale_version                             = jsonencode(var.scale_version)
  filesystem_block_size                     = jsonencode(var.filesystem_block_size)
  compute_cluster_filesystem_mountpoint     = jsonencode("None")
  compute_cluster_gui_username              = jsonencode(var.compute_cluster_gui_username)
  compute_cluster_gui_password              = jsonencode(var.compute_cluster_gui_password)
  compute_cluster_instance_ids              = jsonencode(module.compute_cluster_instances.instance_ids)
  compute_cluster_instance_private_ips      = jsonencode(module.compute_cluster_instances.instance_private_ips)
  storage_cluster_filesystem_mountpoint     = jsonencode(var.storage_cluster_filesystem_mountpoint)
  storage_cluster_instance_ids              = jsonencode(module.storage_cluster_instances.instance_ids)
  storage_cluster_instance_private_ips      = jsonencode(module.storage_cluster_instances.instance_private_ips)
  storage_cluster_with_data_volume_mapping  = jsonencode(module.storage_cluster_instances.instance_ips_with_ebs_mapping)
  storage_cluster_gui_username              = jsonencode(var.storage_cluster_gui_username)
  storage_cluster_gui_password              = jsonencode(var.storage_cluster_gui_password)
  storage_cluster_desc_instance_ids         = length(var.vpc_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_ids) : jsonencode([])
  storage_cluster_desc_instance_private_ips = length(var.vpc_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_private_ips) : jsonencode([])
  storage_cluster_desc_data_volume_mapping  = length(var.vpc_availability_zones) > 1 ? jsonencode(module.storage_cluster_tie_breaker_instance.instance_ips_with_ebs_mapping) : jsonencode({})
  depends_on                                = [module.prepare_ansible_configuration]
}

module "compute_cluster_configuration" {
  source                     = "../../../resources/common/compute_configuration"
  turn_on                    = (var.create_separate_namespaces == true && var.total_compute_cluster_instances > 0) ? true : false
  clone_path                 = var.scale_ansible_repo_clone_path
  inventory_path             = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  memory_size                = data.aws_ec2_instance_type.compute_profile.memory_size
  bastion_instance_public_ip = var.bastion_instance_public_ip
  bastion_ssh_private_key    = var.bastion_ssh_private_key
  meta_private_key           = module.generate_compute_cluster_keys.private_key_content
  scale_version              = var.scale_version
  spectrumscale_rpms_path    = var.spectrumscale_rpms_path
  depends_on                 = [module.prepare_ansible_configuration, module.write_compute_cluster_inventory]
}

module "storage_cluster_configuration" {
  source                     = "../../../resources/common/storage_configuration"
  turn_on                    = (var.create_separate_namespaces == true && var.total_storage_cluster_instances > 0) ? true : false
  clone_path                 = var.scale_ansible_repo_clone_path
  inventory_path             = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  memory_size                = data.aws_ec2_instance_type.storage_profile.memory_size
  bastion_instance_public_ip = var.bastion_instance_public_ip
  bastion_ssh_private_key    = var.bastion_ssh_private_key
  meta_private_key           = module.generate_storage_cluster_keys.private_key_content
  scale_version              = var.scale_version
  spectrumscale_rpms_path    = var.spectrumscale_rpms_path
  depends_on                 = [module.prepare_ansible_configuration, module.write_storage_cluster_inventory]
}

module "combined_cluster_configuration" {
  source                     = "../../../resources/common/scale_configuration"
  turn_on                    = var.create_separate_namespaces == false ? true : false
  clone_path                 = var.scale_ansible_repo_clone_path
  inventory_path             = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  memory_size                = data.aws_ec2_instance_type.storage_profile.memory_size
  bastion_instance_public_ip = var.bastion_instance_public_ip
  bastion_ssh_private_key    = var.bastion_ssh_private_key
  meta_private_key           = module.generate_storage_cluster_keys.private_key_content
  scale_version              = var.scale_version
  spectrumscale_rpms_path    = var.spectrumscale_rpms_path
  depends_on                 = [module.prepare_ansible_configuration, module.write_storage_cluster_inventory]
}
