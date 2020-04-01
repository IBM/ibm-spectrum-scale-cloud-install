/*
    This nested module creates;
    1. Bastion log group
    2. Bastion SSH metric filter
    3. Bastion Host Role
    4. Bastion Host Policy
    5. Bastion security group/Rule
    6. Bastion Autoscaling group
*/

module "bastion_log_group" {
  source            = "../../../resources/aws/logs/log_group"
  group_name_prefix = "${var.stack_name}-Bastion-Log"
}

module "bastion_ssh_metric_filter" {
  source     = "../../../resources/aws/logs/log_metric"
  group_name = module.bastion_log_group.log_group_name
}

module "bastion_host_iam_role" {
  source           = "../../../resources/aws/compute/iam/iam_role"
  role_name_prefix = "${var.stack_name}-Bastion-"
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

module "bastion_host_iam_policy" {
  source                  = "../../../resources/aws/compute/iam/iam_role_policy"
  role_policy_name_prefix = "${var.stack_name}-Bastion-"
  iam_role_id             = module.bastion_host_iam_role.iam_role_id
  iam_role_policy         = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:GetLogEvents",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutRetentionPolicy",
                "logs:PutMetricFilter",
                "logs:CreateLogGroup"
            ],
            "Resource": "${module.bastion_log_group.log_group_arn}",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:AssociateAddress",
                "ec2:DescribeAddresses"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

module "bastion_instance_iam_profile" {
  source                       = "../../../resources/aws/compute/iam/iam_instance_profile"
  instance_profile_name_prefix = "${var.stack_name}-Bastion-"
  iam_host_role                = module.bastion_host_iam_policy.role_policy_name
}

module "bastion_security_group" {
  source                = "../../../resources/aws/security/security_group"
  total_sec_groups      = 1
  sec_group_name        = ["Bastion-Sec-group"]
  sec_group_description = ["Enable SSH access to the bastion host from external via SSH port"]
  vpc_id                = [var.vpc_id]
  sec_group_tag_name    = ["Private-Sec-group"]
}

module "bastion_security_rule" {
  source      = "../../../resources/aws/security/security_rule_cidr"
  total_rules = 3
  security_group_id = [module.bastion_security_group.sec_group_id[0],
    module.bastion_security_group.sec_group_id[0],
  module.bastion_security_group.sec_group_id[0]]
  security_rule_description = ["Incoming traffic to bastion",
    "Incoming ICMP traffic to bastion",
  "Outgoing traffic from bastion to instances"]
  security_rule_type       = ["ingress", "ingress", "egress"]
  traffic_protocol         = ["TCP", "icmp", "-1"]
  traffic_from_port        = [var.bastion_public_ssh_start_port, "-1", "0"]
  traffic_to_port          = [var.bastion_public_ssh_end_port, "-1", "65535"]
  cidr_blocks              = var.cidr_blocks
  security_prefix_list_ids = null
}

module "private_instances_security_group" {
  source                = "../../../resources/aws/security/security_group"
  total_sec_groups      = 1
  sec_group_name        = ["Private-Sec-group"]
  sec_group_description = ["Enable SSH access to the Private instances from the bastion via SSH port"]
  vpc_id                = [var.vpc_id]
  sec_group_tag_name    = ["Private-Sec-group"]
}

module "private_instances_ingress_rule" {
  source                    = "../../../resources/aws/security/security_rule_source"
  total_rules               = 1
  security_group_id         = [module.private_instances_security_group.sec_group_id[0]]
  security_rule_description = ["Incoming traffic to bastion"]
  security_rule_type        = ["ingress"]
  traffic_protocol          = ["TCP"]
  traffic_from_port         = [var.bastion_public_ssh_start_port]
  traffic_to_port           = [var.bastion_public_ssh_end_port]
  source_security_group_id  = [module.bastion_security_group.sec_group_id[0]]
}

module "bastion_autoscaling_launch_config" {
  source                    = "../../../resources/aws/asg/asg_launch_config"
  launch_config_name_prefix = "Bastion-ASG-Launch-Config-"
  image_id                  = var.aws_linux_image_map_codes[var.region][var.bastion_image_name]
  instance_type             = var.bastion_instance_type
  assoc_public_ip           = true
  instance_iam_profile      = module.bastion_instance_iam_profile.iam_instance_profile_name
  key_name                  = var.key_name
  sec_groups                = [module.bastion_security_group.sec_group_id[0]]
}

module "bastion_autoscaling_group" {
  source                     = "../../../resources/aws/asg/asg_group"
  asg_name_prefix            = "Bastion-asg"
  asg_launch_config_name     = module.bastion_autoscaling_launch_config.asg_launch_config_name
  asg_max_size               = 1
  asg_min_size               = 1
  asg_desired_size           = 1
  auto_scaling_group_subnets = var.auto_scaling_group_subnets
  asg_tags                   = list(map("key", "Name", "value", "Bastion-ASG", "propagate_at_launch", true))
}
