/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
}

data "aws_subnet" "vpc_storage_cluster_private_subnet_cidrs" {
  count = (local.cluster_type == "storage" || local.cluster_type == "combined") ? length(var.vpc_storage_cluster_private_subnets) : 0
  id    = var.vpc_storage_cluster_private_subnets[count.index]
}

data "aws_subnet" "vpc_compute_cluster_private_subnet_cidrs" {
  count = (local.cluster_type == "compute" || local.cluster_type == "combined") ? length(var.vpc_compute_cluster_private_subnets) : 0
  id    = var.vpc_compute_cluster_private_subnets[count.index]
}

module "cluster_host_iam_role" {
  source           = "../../../resources/aws/security/iam/iam_role"
  turn_on          = (var.airgap == true) ? false : true # Disable IAM role creation in airgap mode.
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
  turn_on                 = (var.airgap == true) ? false : true
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
  turn_on                      = (var.airgap == true) ? false : true
  instance_profile_name_prefix = format("%s-cluster-", var.resource_prefix)
  iam_host_role                = module.cluster_host_iam_policy.role_policy_name
}

module "compute_cluster_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = (local.cluster_type == "compute" || local.cluster_type == "combined") ? true : false
  sec_group_name        = ["compute-sec-group-"]
  sec_group_description = ["Enable SSH access to the compute cluster hosts"]
  vpc_id                = var.vpc_ref
  sec_group_tag         = ["compute-sec-group"]
}

# Create security rules to enable scale communication within compute instances in a direct connection method.
# This has been split to 2 modules;
# 1. compute_cluster_ingress_security_rule: Only for scale traffic enablement
module "compute_cluster_ingress_security_rule" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.using_direct_connection == true) ? 13 : 0
  security_group_id = [module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic within compute instances",
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
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  traffic_to_port          = [-1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  source_security_group_id = [module.compute_cluster_security_group.sec_group_id]
}

# Create security rules to enable scale communication within compute instances in a direct connection method.
# This has been split to 2 modules;
# 2. compute_cluster_ingress_security_rule_using_direct_connection: For allowing ingress traffic from client_ip_ranges
module "compute_cluster_ingress_security_rule_using_direct_connection" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.using_direct_connection == true) ? 2 : 0
  security_group_id         = [module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from client cidr/ip range to compute instances", "Allow SSH traffic from client cidr/ip range to compute instances"]
  security_rule_type        = ["ingress", "ingress"]
  traffic_protocol          = ["icmp", "TCP"]
  traffic_from_port         = [-1, 22]
  traffic_to_port           = [-1, 22]
  cidr_blocks               = var.client_ip_ranges
  security_prefix_list_ids  = null
}

# Create security rules to enable scale communication within compute instances in a cloud connection method.
module "compute_cluster_ingress_security_rule_using_cloud_connection" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.using_cloud_connection == true) ? 16 : 0
  security_group_id = [module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from cloud gateway to compute instances",
    "Allow SSH traffic from cloud gateway to compute instances",
    "Allow GUI traffic from cloud gateway security group",
    "Allow ICMP traffic within compute instances",
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
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, 443, -1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  traffic_to_port    = [-1, 22, 443, -1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  source_security_group_id = [var.client_security_group_ref, var.client_security_group_ref, var.client_security_group_ref,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
  module.compute_cluster_security_group.sec_group_id]
}

# Create security rules to enable scale communication within compute instances in a jumphost connection method.
module "compute_cluster_ingress_security_rule_using_jumphost_connection" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = ((local.cluster_type == "compute" || local.cluster_type == "combined") && var.using_jumphost_connection == true) ? 16 : 0
  security_group_id = [module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from bastion to compute instances",
    "Allow SSH traffic from bastion to compute instances",
    "Allow ICMP traffic within compute instances",
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
    "Allow https traffic within compute instances",
  "Allow GUI traffic from bastion/jumphost security group"]
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, -1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443, 443]
  traffic_to_port    = [-1, 22, -1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443, 443]
  source_security_group_id = [var.bastion_security_group_ref, var.bastion_security_group_ref,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
    module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
  module.compute_cluster_security_group.sec_group_id, var.bastion_security_group_ref]
}

module "cluster_egress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = local.cluster_type == "combined" ? 2 : 1
  security_group_id         = local.cluster_type == "combined" ? [module.compute_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id] : (var.total_compute_cluster_instances != null ? [module.compute_cluster_security_group.sec_group_id] : [module.storage_cluster_security_group.sec_group_id])
  security_rule_description = local.cluster_type == "combined" ? ["Outgoing traffic from compute instances", "Outgoing traffic from storage instances"] : (var.total_compute_cluster_instances != null ? ["Outgoing traffic from compute instances"] : ["Outgoing traffic from storage instances"])
  security_rule_type        = ["egress", "egress"]
  traffic_protocol          = ["-1", "-1"]
  traffic_from_port         = ["0", "0"]
  traffic_to_port           = ["6335", "6335"]
  cidr_blocks               = ["0.0.0.0/0"]
  security_prefix_list_ids  = null
}

module "storage_cluster_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = (local.cluster_type == "storage" || local.cluster_type == "combined") ? true : false
  sec_group_name        = ["storage-sec-group-"]
  sec_group_description = ["Enable SSH access to the storage cluster hosts"]
  vpc_id                = var.vpc_ref
  sec_group_tag         = ["storage-sec-group"]
}

# Create security rules to enable scale communication within storage instances in a direct connection method.
# This has been split to 2 modules;
# 1. storage_cluster_ingress_security_rule: Only for scale storage traffic enablement
module "storage_cluster_ingress_security_rule" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.using_direct_connection == true) ? 13 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic within storage instances",
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
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  traffic_to_port          = [-1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  source_security_group_id = [module.storage_cluster_security_group.sec_group_id]
}

# Create security rules to enable scale communication within storage instances in a direct connection method.
# This has been split to 2 modules;
# 2. storage_cluster_ingress_security_rule_using_direct_connection: For allowing ingress traffic from client_ip_ranges
module "storage_cluster_ingress_security_rule_using_direct_connection" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.using_direct_connection == true) ? 2 : 0
  security_group_id         = [module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from client cidr/ip range to storage instances", "Allow SSH traffic from client cidr/ip range to storage instances"]
  security_rule_type        = ["ingress", "ingress"]
  traffic_protocol          = ["icmp", "TCP"]
  traffic_from_port         = [-1, 22]
  traffic_to_port           = [-1, 22]
  cidr_blocks               = var.client_ip_ranges
  security_prefix_list_ids  = null
}

# Create security rules to enable scale communication within storage instances in a cloud connection method.
module "storage_cluster_ingress_security_rule_using_cloud_connection" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.using_cloud_connection == true) ? 16 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from cloud gateway to storage instances",
    "Allow SSH traffic from cloud gateway to storage instances",
    "Allow GUI traffic from cloud gateway security group",
    "Allow ICMP traffic within storage instances",
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
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, 443, -1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  traffic_to_port    = [-1, 22, 443, -1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  source_security_group_id = [var.client_security_group_ref, var.client_security_group_ref, var.client_security_group_ref,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
  module.storage_cluster_security_group.sec_group_id]
}

# Create security rules to enable scale communication within storage instances in a jumphost connection method.
module "storage_cluster_ingress_security_rule_using_jumphost_connection" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = ((local.cluster_type == "storage" || local.cluster_type == "combined") && var.using_jumphost_connection == true) ? 16 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from bastion to storage instances",
    "Allow SSH traffic from bastion to storage instances",
    "Allow ICMP traffic within storage instances",
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
    "Allow https traffic within storage instances",
  "Allow GUI traffic from bastion/jumphost security group"]
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, -1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443, 443]
  traffic_to_port    = [-1, 22, -1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443, 443]
  source_security_group_id = [var.bastion_security_group_ref, var.bastion_security_group_ref,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
    module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
  module.storage_cluster_security_group.sec_group_id, var.bastion_security_group_ref]
}

module "bicluster_ingress_security_rule" {
  source      = "../../../resources/aws/security/security_rule_source"
  total_rules = local.cluster_type == "combined" ? 26 : 0
  security_group_id = [module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id,
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
  module.compute_cluster_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from compute to storage instances",
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
    "Allow https traffic from compute to storage instances",
    "Allow ICMP traffic from storage to compute instances",
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
  security_rule_type = ["ingress"]
  traffic_protocol   = ["icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP", "icmp", "TCP", "TCP", "TCP", "TCP", "UDP", "TCP", "TCP", "UDP", "TCP", "TCP", "TCP", "TCP"]
  traffic_from_port  = [-1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443, -1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  traffic_to_port    = [-1, 22, 1191, 61000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443, -1, 22, 1191, 60000, 47080, 47443, 4444, 4739, 4739, 9080, 9081, 80, 443]
  source_security_group_id = [module.compute_cluster_security_group.sec_group_id, module.compute_cluster_security_group.sec_group_id,
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
  module.storage_cluster_security_group.sec_group_id, module.storage_cluster_security_group.sec_group_id]
}

module "email_notification" {
  source         = "../../../resources/aws/sns"
  turn_on        = var.operator_email != null ? true : false
  operator_email = var.operator_email
  topic_name     = format("%s-topic", var.resource_prefix)
}

data "aws_ec2_instance_type" "compute_profile" {
  count         = (local.cluster_type == "compute" || local.cluster_type == "combined") ? 1 : 0
  instance_type = var.compute_cluster_instance_type
}

resource "aws_placement_group" "itself" {
  count    = local.create_placement_group == true ? 1 : 0
  name     = var.resource_prefix
  strategy = "cluster"
}

module "compute_cluster_instances" {
  for_each               = local.compute_vm_subnet_map
  source                 = "../../../resources/aws/compute/ec2_0_vol"
  name_prefix            = each.key
  ami_id                 = var.compute_cluster_image_ref
  instance_type          = var.compute_cluster_instance_type
  security_groups        = [module.compute_cluster_security_group.sec_group_id]
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  placement_group        = null
  subnet_id              = each.value["subnet"]
  root_volume_type       = var.compute_cluster_boot_disk_type
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  user_public_key        = var.compute_cluster_key_pair
  meta_private_key       = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  volume_tags            = var.compute_cluster_volume_tags
  tags                   = var.compute_cluster_tags
}

data "aws_ec2_instance_type" "storage_profile" {
  count         = (local.cluster_type == "storage" || local.cluster_type == "combined") ? 1 : 0
  instance_type = var.storage_cluster_instance_type
}

module "storage_cluster_instances" {
  for_each               = local.storage_vm_zone_map
  source                 = "../../../resources/aws/compute/ec2_multiple_vol"
  name_prefix            = each.key
  ami_id                 = var.storage_cluster_image_ref
  instance_type          = var.storage_cluster_instance_type
  security_groups        = [module.storage_cluster_security_group.sec_group_id]
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  placement_group        = local.create_placement_group == true ? aws_placement_group.itself[0].id : null
  subnet_id              = each.value["subnet"]
  root_volume_type       = var.storage_cluster_boot_disk_type
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  user_public_key        = var.storage_cluster_key_pair
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  ebs_optimized          = try(data.aws_ec2_instance_type.storage_profile[0].ebs_optimized_support, null) == "unsupported" ? false : true
  is_nitro_instance      = try(data.aws_ec2_instance_type.storage_profile[0].hypervisor, null) == "nitro" ? true : false
  zone                   = each.value["zone"]
  disks                  = each.value["disks"]
  tags                   = var.storage_cluster_tags
  volume_tags            = var.storage_cluster_volume_tags
}

module "storage_cluster_tie_breaker_instance" {
  for_each               = local.storage_tie_vm_zone_map
  source                 = "../../../resources/aws/compute/ec2_multiple_vol"
  name_prefix            = each.key
  ami_id                 = var.storage_cluster_image_ref
  instance_type          = var.storage_cluster_tiebreaker_instance_type
  security_groups        = [module.storage_cluster_security_group.sec_group_id]
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  placement_group        = null
  subnet_id              = each.value["subnet"]
  root_volume_type       = var.storage_cluster_boot_disk_type
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  user_public_key        = var.storage_cluster_key_pair
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  ebs_optimized          = try(data.aws_ec2_instance_type.storage_profile[0].ebs_optimized_support, null) == "unsupported" ? false : true
  is_nitro_instance      = try(data.aws_ec2_instance_type.storage_profile[0].hypervisor, null) == "nitro" ? true : false
  zone                   = each.value["zone"]
  disks                  = each.value["disks"]
  tags                   = var.storage_cluster_tags
  volume_tags            = var.storage_cluster_volume_tags
}

module "gateway_instances" {
  for_each               = local.gateway_vm_subnet_map
  source                 = "../../../resources/aws/compute/ec2_0_vol"
  name_prefix            = each.key
  ami_id                 = var.storage_cluster_image_ref
  instance_type          = var.gateway_instance_type
  security_groups        = [module.storage_cluster_security_group.sec_group_id]
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  placement_group        = null
  subnet_id              = each.value["subnet"]
  root_volume_type       = var.storage_cluster_boot_disk_type
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  user_public_key        = var.storage_cluster_key_pair
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  volume_tags            = var.gateway_volume_tags
  tags                   = var.gateway_tags
}

module "protocol_instances" {
  for_each               = local.protocol_vm_subnet_map
  source                 = "../../../resources/aws/compute/ec2_0_vol"
  name_prefix            = each.key
  ami_id                 = var.storage_cluster_image_ref
  instance_type          = var.protocol_instance_type
  security_groups        = [module.storage_cluster_security_group.sec_group_id]
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  placement_group        = null
  subnet_id              = each.value["subnet"]
  root_volume_type       = var.storage_cluster_boot_disk_type
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  user_public_key        = var.storage_cluster_key_pair
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  volume_tags            = var.protocol_volume_tags
  tags                   = var.protocol_tags
}

module "protocol_enis" {
  for_each          = local.protocol_vm_ces_map
  source            = "../../../resources/aws/network/eni"
  subnet_id         = each.value["subnet"]
  private_ips       = each.value["private_ips"]
  private_ips_count = 1
  security_groups   = [module.storage_cluster_security_group.sec_group_id]
  description       = each.value["description"]
}

module "prepare_ansible_configuration" {
  source     = "../../../resources/common/git_utils"
  turn_on    = (var.airgap == true) ? false : true # Disable git module in airgap mode.
  branch     = "scale_cloud"
  tag        = null
  clone_path = var.scale_ansible_repo_clone_path
}

locals {
  is_nitro_instance                = try(data.aws_ec2_instance_type.storage_profile[0].hypervisor, null) == "nitro" ? true : false
  nvme_block_device_count          = local.storage_or_combined ? (length(data.aws_ec2_instance_type.storage_profile[0].instance_disks) != 0 ? tolist(try(data.aws_ec2_instance_type.storage_profile[0].instance_disks, null))[0].count : 0) : 0
  storage_cluster_private_ips      = local.storage_or_combined ? [for instance in module.storage_cluster_instances : instance.instance_private_ips] : []
  storage_cluster_desc_private_ips = local.storage_or_combined && length(var.vpc_availability_zones) > 1 ? [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips] : []
}

# Write the compute cluster related inventory.
resource "local_sensitive_file" "write_compute_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == true && local.cluster_type == "compute" ? 1 : 0
  filename = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "AWS"
    resource_prefix                           = var.resource_prefix
    vpc_region                                = var.vpc_region
    vpc_availability_zones                    = var.vpc_availability_zones
    scale_version                             = local.scale_version
    filesystem_details                        = local.filesystem_details
    compute_cluster_filesystem_mountpoint     = var.compute_cluster_filesystem_mountpoint
    bastion_instance_id                       = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                              = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                   = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_instance_ids              = [for instance in module.compute_cluster_instances : instance.instance_ids]
    compute_cluster_instance_private_ips      = [for instance in module.compute_cluster_instances : instance.instance_private_ips]
    compute_cluster_instance_private_dns      = [for instance in module.compute_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_instance_ids              = []
    storage_cluster_instance_private_ips      = []
    storage_cluster_with_data_volume_mapping  = {}
    storage_cluster_instance_private_dns      = []
    storage_cluster_desc_instance_ids         = []
    storage_cluster_desc_instance_private_ips = []
    storage_cluster_desc_data_volume_mapping  = {}
    storage_cluster_desc_instance_private_dns = []
  })
}

# Write the storage cluster related inventory.
resource "local_sensitive_file" "write_storage_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == true && local.cluster_type == "storage" ? 1 : 0
  filename = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "AWS"
    resource_prefix                           = var.resource_prefix
    vpc_region                                = var.vpc_region
    vpc_availability_zones                    = var.vpc_availability_zones
    scale_version                             = local.scale_version
    filesystem_details                        = local.filesystem_details
    bastion_instance_id                       = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                              = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                   = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_instance_ids              = []
    compute_cluster_instance_private_ips      = []
    compute_cluster_instance_private_dns      = []
    storage_cluster_instance_ids              = [for instance in module.storage_cluster_instances : instance.instance_ids]
    storage_cluster_instance_private_ips      = [for instance in module.storage_cluster_instances : instance.instance_private_ips]
    storage_cluster_with_data_volume_mapping  = local.storage_instance_ips_with_disk_mapping
    storage_cluster_instance_private_dns      = [for instance in module.storage_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_desc_instance_ids         = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids]
    storage_cluster_desc_instance_private_ips = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips]
    storage_cluster_desc_data_volume_mapping  = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
    storage_cluster_desc_instance_private_dns = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_dns_name]
  })
}

# Write combined cluster related inventory.
resource "local_sensitive_file" "write_combined_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && local.cluster_type == "combined" ? 1 : 0
  filename = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                            = "AWS"
    resource_prefix                           = var.resource_prefix
    vpc_region                                = var.vpc_region
    vpc_availability_zones                    = var.vpc_availability_zones
    scale_version                             = local.scale_version
    filesystem_details                        = local.filesystem_details
    bastion_instance_id                       = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                              = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip                = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                   = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_instance_ids              = [for instance in module.compute_cluster_instances : instance.instance_ids]
    compute_cluster_instance_private_ips      = [for instance in module.compute_cluster_instances : instance.instance_private_ips]
    compute_cluster_instance_private_dns      = [for instance in module.compute_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_instance_ids              = [for instance in module.storage_cluster_instances : instance.instance_ids]
    storage_cluster_instance_private_ips      = [for instance in module.storage_cluster_instances : instance.instance_private_ips]
    storage_cluster_with_data_volume_mapping  = local.storage_instance_ips_with_disk_mapping
    storage_cluster_instance_private_dns      = [for instance in module.storage_cluster_instances : instance.instance_private_dns_name]
    storage_cluster_desc_instance_ids         = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_ids]
    storage_cluster_desc_instance_private_ips = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_ips]
    storage_cluster_desc_data_volume_mapping  = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
    storage_cluster_desc_instance_private_dns = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_private_dns_name]
  })
}

# Configure the compute cluster using ansible based on the create_scale_cluster input.
module "compute_cluster_configuration" {
  source                          = "../../../resources/common/compute_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && (local.cluster_type == "compute" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  compute_cluster_gui_username    = var.compute_cluster_gui_username
  compute_cluster_gui_password    = var.compute_cluster_gui_password
  memory_size                     = try(data.aws_ec2_instance_type.compute_profile[0].memory_size, null)
  max_pagepool_gb                 = 4
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_compute_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  depends_on                      = [resource.local_sensitive_file.write_compute_cluster_inventory]
}

# Configure the storage cluster using ansible based on the create_scale_cluster input.
module "storage_cluster_configuration" {
  source                          = "../../../resources/common/storage_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && (local.cluster_type == "storage" || local.cluster_type == "combined") && var.create_remote_mount_cluster == true ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = true
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = try(data.aws_ec2_instance_type.storage_profile[0].memory_size, null)
  max_pagepool_gb                 = 16
  vcpu_count                      = try(data.aws_ec2_instance_type.storage_profile[0].default_vcpus, null)
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  max_mbps                        = (local.cluster_type == "storage" || local.cluster_type == "combined") ? data.aws_ec2_instance_type.storage_profile[0].ebs_performance_baseline_bandwidth * 0.25 : 0
  disk_type                       = jsonencode("None")
  depends_on                      = [resource.local_sensitive_file.write_storage_cluster_inventory]
}

# Configure the combined cluster using ansible based on the create_scale_cluster input.
module "combined_cluster_configuration" {
  source                          = "../../../resources/common/scale_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && local.cluster_type == "combined" ? true : false
  inventory_format                = var.inventory_format
  create_scale_cluster            = var.create_scale_cluster
  clone_path                      = var.scale_ansible_repo_clone_path
  inventory_path                  = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  using_packer_image              = var.using_packer_image
  using_jumphost_connection       = var.using_jumphost_connection
  storage_cluster_gui_username    = var.storage_cluster_gui_username
  storage_cluster_gui_password    = var.storage_cluster_gui_password
  memory_size                     = try(data.aws_ec2_instance_type.storage_profile[0].memory_size, null)
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  meta_private_key                = module.generate_storage_cluster_keys.private_key_content
  scale_version                   = local.scale_version
  spectrumscale_rpms_path         = var.spectrumscale_rpms_path
  enable_mrot_conf                = false
  scale_encryption_enabled        = false
  scale_encryption_admin_password = null
  scale_encryption_servers        = null
  depends_on                      = [resource.local_sensitive_file.write_combined_inventory]
}

# Configure the remote mount relationship between the created compute & storage cluster.
module "remote_mount_configuration" {
  source                          = "../../../resources/common/remote_mount_configuration"
  turn_on                         = (local.cluster_type == "combined" && var.create_remote_mount_cluster == true) ? true : false
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
  using_jumphost_connection       = var.using_jumphost_connection
  using_rest_initialization       = var.using_rest_api_remote_mount
  bastion_user                    = var.bastion_user == null ? jsonencode("None") : jsonencode(var.bastion_user)
  bastion_instance_public_ip      = var.bastion_instance_public_ip == null ? jsonencode("None") : jsonencode(var.bastion_instance_public_ip)
  bastion_ssh_private_key         = var.bastion_ssh_private_key == null ? jsonencode("None") : jsonencode(var.bastion_ssh_private_key)
  clone_complete                  = module.prepare_ansible_configuration.clone_complete
  compute_cluster_create_complete = module.compute_cluster_configuration.compute_cluster_create_complete
  storage_cluster_create_complete = module.storage_cluster_configuration.storage_cluster_create_complete
}
