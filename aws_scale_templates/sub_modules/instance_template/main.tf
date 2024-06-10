/*
    This nested module creates;
    1. Spin storage cluster instances
    2. Spin compute cluster instances
    3. Copy, Install gpfs cloud rpms to both cluster instances
    4. Configure clusters, filesystem creation and remote mount
*/

module "generate_compute_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = local.compute_or_combined ? true : false
}

module "generate_storage_cluster_keys" {
  source  = "../../../resources/common/generate_keys"
  turn_on = local.storage_or_combined ? true : false
}

data "aws_subnet" "vpc_storage_cluster_private_subnet_cidrs" {
  count = local.storage_or_combined ? length(var.vpc_storage_cluster_private_subnets) : 0
  id    = var.vpc_storage_cluster_private_subnets[count.index]
}

data "aws_subnet" "vpc_compute_cluster_private_subnet_cidrs" {
  count = local.compute_or_combined ? length(var.vpc_compute_cluster_private_subnets) : 0
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
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AssignPrivateIpAddresses",
                "ec2:Describe*",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags*",
                "ec2:UnassignPrivateIpAddresses",
                "ec2:ModifyInstanceAttribute",
                "iam:GetRole",
                "sns:Publish",
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
  source                       = "../../../resources/aws/security/iam/iam_instance_profile"
  turn_on                      = (var.airgap == true) ? false : true
  instance_profile_name_prefix = format("%s-cluster-", var.resource_prefix)
  iam_host_role                = module.cluster_host_iam_policy.role_policy_name
}

# Create Scale cluster security group
module "cluster_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = true
  sec_group_name        = ["scale-sec-group-"]
  sec_group_description = ["Scale cluster sec group"]
  vpc_id                = var.vpc_ref
  sec_group_tag         = ["scale-sec-group"]
}

# Create Scale cluster security group
module "protocol_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = length(local.protocol_vm_subnet_map) > 0 ? true : false
  sec_group_name        = ["protocol-sec-group-"]
  sec_group_description = ["CES Protocol sec group"]
  vpc_id                = var.vpc_ref
  sec_group_tag         = ["protocol-sec-group"]
}

# Create security rules to enable scale/gpfs traffic within compute/storage instances.
module "scale_cluster_ingress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_source"
  total_rules               = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? length(local.traffic_scale_protocol) : 0
  security_group_id         = [module.cluster_security_group.sec_group_id]
  security_rule_description = local.security_rule_description_scale
  security_rule_type        = ["ingress"]
  traffic_protocol          = local.traffic_scale_protocol
  traffic_from_port         = local.traffic_scale_from_port
  traffic_to_port           = local.traffic_scale_to_port
  source_security_group_id  = [module.cluster_security_group.sec_group_id]
}

# Create security rules to enable direct connection to scale cluster
module "scale_cluster_ingress_security_rule_using_direct_connection" {
  source            = "../../../resources/aws/security/security_rule_cidr"
  total_rules       = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.using_direct_connection ? 2 : 0
  security_group_id = [module.cluster_security_group.sec_group_id]
  security_rule_description = [
    "Allow ICMP traffic from client cidr/ip range to compute instances",
    "Allow SSH traffic from client cidr/ip range to compute instances",
  "Allow GUI traffic from jumphost security group"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 443]
  traffic_to_port          = [-1, 22, 443]
  cidr_blocks              = var.client_ip_ranges
  security_prefix_list_ids = null
}


# Create security rules to enable jumphost communication to scale cluster
module "scale_cluster_ingress_security_rule_using_jumphost" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.using_jumphost_connection ? 3 : 0
  security_group_id = [module.cluster_security_group.sec_group_id]
  security_rule_description = [
    "Allow ICMP traffic from Jumphost to compute instances",
    "Allow SSH traffic from Jumphost to compute instances",
  "Allow GUI traffic from Jumphost security group"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 443]
  traffic_to_port          = [-1, 22, 443]
  source_security_group_id = [var.bastion_security_group_ref, var.bastion_security_group_ref, var.bastion_security_group_ref]
}

# Create security rules to enable scale communication from cloud connection method
module "scale_cluster_ingress_security_rule_using_cloud_connection" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") && var.using_cloud_connection ? 16 : 0
  security_group_id = [module.cluster_security_group.sec_group_id]
  security_rule_description = [
    "Allow ICMP traffic from cloud gateway to compute instances",
    "Allow SSH traffic from cloud gateway to compute instances",
  "Allow GUI traffic from cloud gateway security group"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP", "TCP"]
  traffic_from_port        = [-1, 22, 443]
  traffic_to_port          = [-1, 22, 443]
  source_security_group_id = [var.client_security_group_ref, var.client_security_group_ref, var.client_security_group_ref]
}

# Create security rule to enable egress communication
module "scale_cluster_egress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = (var.cluster_type == "Compute-only" || var.cluster_type == "Storage-only" || var.cluster_type == "Combined-compute-storage") ? 1 : 0
  security_group_id         = [module.cluster_security_group.sec_group_id]
  security_rule_description = ["Outgoing traffic from scale instances"]
  security_rule_type        = ["egress"]
  traffic_protocol          = ["-1"]
  traffic_from_port         = ["0"]
  traffic_to_port           = ["6335"]
  cidr_blocks               = ["0.0.0.0/0"]
  security_prefix_list_ids  = null
}

# Create security rules to enable scale communication within protocol vm's
module "protocol_cluster_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_source"
  total_rules               = length(local.protocol_vm_subnet_map) > 0 ? length(local.traffic_protocol_from_port) : 0
  security_group_id         = [module.protocol_security_group.sec_group_id]
  security_rule_description = local.security_rule_description_protocol
  security_rule_type        = ["ingress"]
  traffic_protocol          = local.traffic_protocol
  traffic_from_port         = local.traffic_protocol_from_port
  traffic_to_port           = local.traffic_protocol_from_port
  source_security_group_id  = [module.protocol_security_group.sec_group_id]
}

# Create security rules to enable jumphost communication to protocol vm's
module "protocol_cluster_ingress_security_rule_using_jumphost" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = length(local.protocol_vm_subnet_map) > 0 ? 2 : 0
  security_group_id = [module.protocol_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from Jumphost to compute instances",
  "Allow SSH traffic from Jumphost to compute instances"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP"]
  traffic_from_port        = [-1, 22]
  traffic_to_port          = [-1, 22]
  source_security_group_id = [var.bastion_security_group_ref, var.bastion_security_group_ref]
}

# Create security rules to enable protocol communication between protocol to scale cluster
module "protocol_cluster_to_scale_cluster" {
  source      = "../../../resources/aws/security/security_rule_source"
  total_rules = length(local.protocol_vm_subnet_map) > 0 ? 26 : 0
  security_group_id = [
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id
  ]
  security_rule_description = local.security_rule_description_bi
  security_rule_type        = ["ingress"]
  traffic_protocol          = local.traffic_protocol_bi
  traffic_from_port         = local.traffic_protocol_from_port_bi
  traffic_to_port           = local.traffic_protocol_to_port_bi
  source_security_group_id = [
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id,
    module.protocol_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
    module.cluster_security_group.sec_group_id, module.cluster_security_group.sec_group_id,
  module.cluster_security_group.sec_group_id]
}

# Create security rules to enable outgoing traffic from protocol vm's
module "protocol_egress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = length(local.protocol_vm_subnet_map) > 0 ? 1 : 0
  security_group_id         = [module.protocol_security_group.sec_group_id]
  security_rule_description = ["Outgoing traffic from protocol instances"]
  security_rule_type        = ["egress"]
  traffic_protocol          = ["-1"]
  traffic_from_port         = ["0"]
  traffic_to_port           = ["6335"]
  cidr_blocks               = ["0.0.0.0/0"]
  security_prefix_list_ids  = null
}

# Create security rules to enable direction communication to protocol vm's
module "protocol_cluster_ingress_security_rule_using_direct_connection" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = length(local.protocol_vm_subnet_map) > 0 && var.using_direct_connection ? 2 : 0
  security_group_id         = [module.protocol_security_group.sec_group_id, module.protocol_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from client cidr/ip range to protocol instances", "Allow SSH traffic from client cidr/ip range to protocol instances"]
  security_rule_type        = ["ingress", "ingress"]
  traffic_protocol          = ["icmp", "TCP"]
  traffic_from_port         = [-1, 22]
  traffic_to_port           = [-1, 22]
  cidr_blocks               = var.client_ip_ranges
  security_prefix_list_ids  = null
}

# Create security rules to enable cloud-vm communication to protocol vm's
module "protocol_cluster_ingress_security_rule_using_cloudvm" {
  source            = "../../../resources/aws/security/security_rule_source"
  total_rules       = length(local.protocol_vm_subnet_map) > 0 && var.using_cloud_connection ? 2 : 0
  security_group_id = [module.protocol_security_group.sec_group_id]
  security_rule_description = ["Allow ICMP traffic from cloud-vm to protocol instances",
  "Allow SSH traffic from cloud-vm to protocol instances"]
  security_rule_type       = ["ingress"]
  traffic_protocol         = ["icmp", "TCP"]
  traffic_from_port        = [-1, 22]
  traffic_to_port          = [-1, 22]
  source_security_group_id = [var.client_security_group_ref, var.client_security_group_ref]
}

module "email_notification" {
  source         = "../../../resources/aws/sns"
  turn_on        = var.operator_email != null ? true : false
  operator_email = var.operator_email
  topic_name     = format("%s-topic", var.resource_prefix)
}

data "aws_ec2_instance_type" "compute_profile" {
  count         = local.compute_or_combined ? 1 : 0
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
  ami_id                 = var.compute_cluster_image_ref
  dns_domain             = var.vpc_compute_cluster_dns_domain
  forward_dns_zone       = var.vpc_forward_dns_zone
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  instance_type          = var.compute_cluster_instance_type
  meta_private_key       = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.private_key_content : module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = var.create_remote_mount_cluster == true ? module.generate_compute_cluster_keys.public_key_content : module.generate_storage_cluster_keys.public_key_content
  name_prefix            = each.key
  placement_group        = null
  reverse_dns_domain     = var.vpc_reverse_dns_domain
  reverse_dns_zone       = var.vpc_reverse_dns_zone
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  root_volume_type       = var.compute_cluster_boot_disk_type
  secondary_private_ip   = null
  security_groups        = [module.cluster_security_group.sec_group_id]
  subnet_id              = each.value["subnet"]
  tags                   = var.compute_cluster_tags
  user_public_key        = var.compute_cluster_key_pair
  volume_tags            = var.compute_cluster_volume_tags
}

data "aws_ec2_instance_type" "storage_profile" {
  count         = local.storage_or_combined ? 1 : 0
  instance_type = var.storage_cluster_instance_type
}

module "storage_cluster_instances" {
  for_each               = local.storage_vm_zone_map
  source                 = "../../../resources/aws/compute/ec2_multiple_vol"
  ami_id                 = var.storage_cluster_image_ref
  disks                  = each.value["disks"]
  dns_domain             = var.vpc_storage_cluster_dns_domain
  ebs_optimized          = try(data.aws_ec2_instance_type.storage_profile[0].ebs_optimized_support, null) == "unsupported" ? false : true
  forward_dns_zone       = var.vpc_forward_dns_zone
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  instance_type          = var.storage_cluster_instance_type
  is_nitro_instance      = try(data.aws_ec2_instance_type.storage_profile[0].hypervisor, null) == "nitro" ? true : false
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  name_prefix            = each.key
  placement_group        = local.create_placement_group == true ? aws_placement_group.itself[0].id : null
  reverse_dns_domain     = var.vpc_reverse_dns_domain
  reverse_dns_zone       = var.vpc_reverse_dns_zone
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  root_volume_type       = var.storage_cluster_boot_disk_type
  security_groups        = [module.cluster_security_group.sec_group_id]
  subnet_id              = each.value["subnet"]
  tags                   = var.storage_cluster_tags
  user_public_key        = var.storage_cluster_key_pair
  volume_tags            = var.storage_cluster_volume_tags
  zone                   = each.value["zone"]
}

module "storage_cluster_tie_breaker_instance" {
  for_each               = local.storage_tie_vm_zone_map
  source                 = "../../../resources/aws/compute/ec2_multiple_vol"
  ami_id                 = var.storage_cluster_image_ref
  disks                  = each.value["disks"]
  dns_domain             = var.vpc_storage_cluster_dns_domain
  ebs_optimized          = try(data.aws_ec2_instance_type.storage_profile[0].ebs_optimized_support, null) == "unsupported" ? false : true
  forward_dns_zone       = var.vpc_forward_dns_zone
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  instance_type          = var.storage_cluster_tiebreaker_instance_type
  is_nitro_instance      = try(data.aws_ec2_instance_type.storage_profile[0].hypervisor, null) == "nitro" ? true : false
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  name_prefix            = each.key
  placement_group        = null
  reverse_dns_domain     = var.vpc_reverse_dns_domain
  reverse_dns_zone       = var.vpc_reverse_dns_zone
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  root_volume_type       = var.storage_cluster_boot_disk_type
  security_groups        = [module.cluster_security_group.sec_group_id]
  subnet_id              = each.value["subnet"]
  tags                   = var.storage_cluster_tags
  user_public_key        = var.storage_cluster_key_pair
  volume_tags            = var.storage_cluster_volume_tags
  zone                   = each.value["zone"]
}

module "gateway_instances" {
  for_each               = local.gateway_vm_subnet_map
  source                 = "../../../resources/aws/compute/ec2_0_vol"
  ami_id                 = var.storage_cluster_image_ref
  dns_domain             = var.vpc_compute_cluster_dns_domain
  forward_dns_zone       = var.vpc_forward_dns_zone
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  instance_type          = var.gateway_instance_type
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  name_prefix            = each.key
  placement_group        = null
  reverse_dns_domain     = var.vpc_reverse_dns_domain
  reverse_dns_zone       = var.vpc_reverse_dns_zone
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  root_volume_type       = var.storage_cluster_boot_disk_type
  secondary_private_ip   = null
  security_groups        = [module.cluster_security_group.sec_group_id]
  subnet_id              = each.value["subnet"]
  tags                   = var.gateway_tags
  user_public_key        = var.storage_cluster_key_pair
  volume_tags            = var.gateway_volume_tags
}

module "protocol_instances" {
  for_each               = local.protocol_vm_subnet_map
  source                 = "../../../resources/aws/compute/ec2_0_vol"
  ami_id                 = var.storage_cluster_image_ref
  dns_domain             = var.vpc_compute_cluster_dns_domain
  forward_dns_zone       = var.vpc_forward_dns_zone
  iam_instance_profile   = (var.airgap == true) ? null : module.cluster_instance_iam_profile.iam_instance_profile_name[0]
  instance_type          = var.protocol_instance_type
  meta_private_key       = module.generate_storage_cluster_keys.private_key_content
  meta_public_key        = module.generate_storage_cluster_keys.public_key_content
  name_prefix            = each.key
  placement_group        = null
  reverse_dns_domain     = var.vpc_reverse_dns_domain
  reverse_dns_zone       = var.vpc_reverse_dns_zone
  root_device_encrypted  = var.root_device_encrypted
  root_device_kms_key_id = var.root_device_kms_key_ref
  root_volume_type       = var.storage_cluster_boot_disk_type
  secondary_private_ip   = each.value["ces_private_ip"]
  security_groups        = [module.protocol_security_group.sec_group_id]
  subnet_id              = each.value["subnet"]
  tags                   = var.protocol_tags
  user_public_key        = var.storage_cluster_key_pair
  volume_tags            = var.protocol_volume_tags
}

module "protocol_enis" {
  for_each          = local.protocol_vm_ces_map
  source            = "../../../resources/aws/network/eni"
  subnet_id         = each.value["subnet"]
  private_ips       = each.value["private_ips"]
  private_ips_count = 1
  security_groups   = [module.protocol_security_group.sec_group_id]
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
  is_nitro_instance       = try(data.aws_ec2_instance_type.storage_profile[0].hypervisor, null) == "nitro" ? true : false
  nvme_block_device_count = local.storage_or_combined ? (length(data.aws_ec2_instance_type.storage_profile[0].instance_disks) != 0 ? tolist(try(data.aws_ec2_instance_type.storage_profile[0].instance_disks, null))[0].count : 0) : 0
}

# Write the compute cluster related inventory.
resource "local_sensitive_file" "write_compute_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == true && var.cluster_type == "Compute-only" ? 1 : 0
  filename = format("%s/compute_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "AWS"
    resource_prefix                          = var.resource_prefix
    vpc_region                               = var.vpc_region
    vpc_availability_zones                   = var.vpc_availability_zones
    scale_version                            = local.scale_version
    filesystem_details                       = local.filesystem_details
    compute_cluster_filesystem_mountpoint    = var.compute_cluster_filesystem_mountpoint
    bastion_instance_id                      = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                             = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip               = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                  = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_details                  = [for instance in module.compute_cluster_instances : instance.instance_details]
    storage_cluster_details                  = []
    storage_cluster_with_data_volume_mapping = {}
    storage_cluster_desc_details             = []
    storage_cluster_desc_data_volume_mapping = {}
  })
}

# Write the storage cluster related inventory.
resource "local_sensitive_file" "write_storage_cluster_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.cluster_type == "Storage-only" ? 1 : 0
  filename = format("%s/storage_cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "AWS"
    resource_prefix                          = var.resource_prefix
    vpc_region                               = var.vpc_region
    vpc_availability_zones                   = var.vpc_availability_zones
    scale_version                            = local.scale_version
    filesystem_details                       = local.filesystem_details
    bastion_instance_id                      = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                             = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip               = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                  = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_details                  = []
    storage_cluster_details                  = [for instance in module.storage_cluster_instances : instance.instance_details]
    storage_cluster_with_data_volume_mapping = local.storage_instance_ips_with_disk_mapping
    storage_cluster_desc_details             = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
    storage_cluster_desc_data_volume_mapping = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
  })
}

# Write combined cluster related inventory.
resource "local_sensitive_file" "write_combined_inventory" {
  count    = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? 1 : 0
  filename = format("%s/cluster_inventory.json", var.scale_ansible_repo_clone_path)
  content = jsonencode({
    cloud_platform                           = "AWS"
    resource_prefix                          = var.resource_prefix
    vpc_region                               = var.vpc_region
    vpc_availability_zones                   = var.vpc_availability_zones
    scale_version                            = local.scale_version
    filesystem_details                       = local.filesystem_details
    bastion_instance_id                      = var.bastion_instance_ref == null ? null : var.bastion_instance_ref
    bastion_user                             = var.bastion_user == null ? null : var.bastion_user
    bastion_instance_public_ip               = var.bastion_instance_public_ip == null ? null : var.bastion_instance_public_ip
    instances_ssh_user_name                  = var.instances_ssh_user_name == null ? null : var.instances_ssh_user_name
    compute_cluster_details                  = [for instance in module.compute_cluster_instances : instance.instance_details]
    storage_cluster_details                  = [for instance in module.storage_cluster_instances : instance.instance_details]
    storage_cluster_with_data_volume_mapping = local.storage_instance_ips_with_disk_mapping
    storage_cluster_desc_details             = [for instance in module.storage_cluster_tie_breaker_instance : instance.instance_details]
    storage_cluster_desc_data_volume_mapping = length(module.storage_cluster_tie_breaker_instance) > 0 ? local.storage_instance_desc_ip_with_disk_mapping : {}
  })
}

# Configure the compute cluster using ansible based on the create_scale_cluster input.
module "compute_cluster_configuration" {
  source                          = "../../../resources/common/compute_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && local.compute_or_combined && var.create_remote_mount_cluster ? true : false
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
  turn_on                         = module.prepare_ansible_configuration.clone_complete && local.storage_or_combined && var.create_remote_mount_cluster ? true : false
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
  max_mbps                        = local.storage_or_combined ? data.aws_ec2_instance_type.storage_profile[0].ebs_performance_baseline_bandwidth * 0.25 : 0
  disk_type                       = jsonencode("None")
  depends_on                      = [resource.local_sensitive_file.write_storage_cluster_inventory]
}

# Configure the combined cluster using ansible based on the create_scale_cluster input.
module "combined_cluster_configuration" {
  source                          = "../../../resources/common/scale_configuration"
  turn_on                         = module.prepare_ansible_configuration.clone_complete && var.create_remote_mount_cluster == false && var.cluster_type == "Combined-compute-storage" ? true : false
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
  turn_on                         = var.cluster_type == "Combined-compute-storage" && var.create_remote_mount_cluster ? true : false
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
