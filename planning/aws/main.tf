# Create policy for vpc/network operations
resource "aws_iam_policy" "vpc_policy" {
  name        = "IBMStoragescale-cloudkit-vpc"
  description = "A policy to manage VPC - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateDhcpOptions",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:DeleteSubnet",
          "ec2:DeleteVpcEndpoints",
          "ec2:AttachInternetGateway",
          "ec2:ReplaceRoute",
          "ec2:AssociateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeInternetGateways",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateRoute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcClassicLinkDnsSupport",
          "ec2:CreateTags",
          "ec2:CreateRouteTable",
          "ec2:DetachInternetGateway",
          "ec2:DescribePrefixLists",
          "ec2:DisassociateRouteTable",
          "ec2:DescribeVpcClassicLink",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DeleteDhcpOptions",
          "ec2:DeleteNatGateway",
          "ec2:DescribeVpcEndpoints",
          "ec2:DeleteVpc",
          "ec2:CreateSubnet",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkAclEntry",
          "ec2:ModifyVpcEndpoint",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DisassociateAddress",
          "ec2:DescribeAddresses",
          "ec2:CreateNatGateway",
          "ec2:DescribeRegions",
          "ec2:CreateVpc",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeAddressesAttribute",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAvailabilityZones",
          "ec2:ModifyVpcAttribute",
          "ec2:ReleaseAddress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AssociateDhcpOptions",
          "ec2:DeleteRoute",
          "ec2:DescribeNatGateways",
          "ec2:AllocateAddress",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeImages",
          "ec2:DescribeVpcs",
          "ec2:CreateVpcEndpoint",
          "ec2:CreateNetworkAclEntry"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for route53/dns operations
resource "aws_iam_policy" "dns_policy" {
  name        = "IBMStoragescale-cloudkit-dns"
  description = "A policy to manage route53/dns - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZonesByVPC",
          "route53:CreateHostedZone",
          "route53:GetChange",
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ChangeResourceRecordSets",
          "route53:ChangeTagsForResource",
          "route53:ListResourceRecordSets",
          "route53:DeleteHostedZone",
          "route53:ListTagsForResource"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for packer/image operations
resource "aws_iam_policy" "image_policy" {
  name        = "IBMStoragescale-cloudkit-image"
  description = "A policy to manage packer/image - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DeregisterImage",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "s3:GetBucketWebsite",
          "ec2:CreateKeyPair",
          "s3:ListBucketVersions",
          "ec2:CreateImage",
          "s3:CreateBucket",
          "ec2:RunInstances",
          "s3:ListBucket",
          "ec2:ModifyImageAttribute",
          "s3:DeleteBucketPolicy",
          "ec2:StopInstances",
          "s3:PutObject",
          "s3:ListAllMyBuckets",
          "s3:PutBucketWebsite",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeVolumes",
          "ec2:DeleteSecurityGroup",
          "s3:PutBucketPolicy",
          "s3:DeleteObject",
          "s3:DeleteBucket",
          "ec2:DeleteKeyPair"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for scale instance operations
# tfsec:ignore:AVD-AWS-0342
resource "aws_iam_policy" "instance_policy" {
  name        = "IBMStoragescale-cloudkit-instance"
  description = "A policy to manage scale instances - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "SNS:CreateTopic",
          "ec2:DescribeInstances",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:CreateRole",
          "SNS:ListTagsForResource",
          "iam:PutRolePolicy",
          "ec2:DescribePlacementGroups",
          "iam:AddRoleToInstanceProfile",
          "SNS:Subscribe",
          "SNS:Unsubscribe",
          "ec2:DeleteVolume",
          "ec2:CreatePlacementGroup",
          "ec2:RevokeSecurityGroupEgress",
          "iam:ListAttachedRolePolicies",
          "ec2:DescribeVolumes",
          "SNS:SetTopicAttributes",
          "ec2:DescribeKeyPairs",
          "iam:ListRolePolicies",
          "ec2:DescribeRouteTables",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "iam:GetRole",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateTags",
          "ec2:DeleteNetworkInterface",
          "ec2:RunInstances",
          "iam:DeleteRole",
          "ec2:CreateVolume",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateNetworkInterface",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeSubnets",
          "iam:GetRolePolicy",
          "ec2:AttachVolume",
          "iam:CreateInstanceProfile",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeRegions",
          "SNS:GetSubscriptionAttributes",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateSecurityGroup",
          "iam:DeleteRolePolicy",
          "SNS:GetTopicAttributes",
          "ec2:DescribeInstanceStatus",
          "iam:DeleteInstanceProfile",
          "ec2:AuthorizeSecurityGroupEgress",
          "SNS:DeleteTopic",
          "ec2:TerminateInstances",
          "ec2:DetachNetworkInterface",
          "ec2:DeletePlacementGroup",
          "iam:GetInstanceProfile",
          "ec2:DescribeTags",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeImages",
          "ec2:DescribeVpcs",
          "ec2:DeleteSecurityGroup"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for bastion/proxy instance operations
# tfsec:ignore:AVD-AWS-0342
resource "aws_iam_policy" "bastion_policy" {
  name        = "IBMStoragescale-cloudkit-bastion"
  description = "A policy to manage scale bastion/proxy - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:ListTagsLogGroup",
          "iam:CreateInstanceProfile",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:CreateRole",
          "logs:DescribeMetricFilters",
          "iam:PutRolePolicy",
          "iam:AddRoleToInstanceProfile",
          "iam:ListInstanceProfilesForRole",
          "logs:DeleteMetricFilter",
          "iam:PassRole",
          "ec2:GetLaunchTemplateData",
          "autoscaling:DescribeScalingActivities",
          "ec2:CreateSecurityGroup",
          "iam:ListAttachedRolePolicies",
          "iam:DeleteRolePolicy",
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeVolumes",
          "autoscaling:UpdateAutoScalingGroup",
          "iam:ListRolePolicies",
          "iam:DeleteInstanceProfile",
          "iam:GetRole",
          "ec2:DeleteLaunchTemplate",
          "logs:DescribeLogGroups",
          "ec2:DescribeIamInstanceProfileAssociations",
          "iam:GetInstanceProfile",
          "logs:DeleteLogGroup",
          "ec2:DescribeLaunchTemplates",
          "ec2:CreateTags",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:RunInstances",
          "iam:DeleteRole",
          "autoscaling:SuspendProcesses",
          "logs:CreateLogGroup",
          "logs:ListTagsForResource",
          "ec2:DescribeInstanceCreditSpecifications",
          "ec2:CreateLaunchTemplateVersion",
          "logs:PutMetricFilter",
          "ec2:CreateLaunchTemplate",
          "autoscaling:SetInstanceProtection",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeInstanceTypes",
          "autoscaling:DeleteAutoScalingGroup",
          "iam:GetRolePolicy",
          "iam:CreateServiceLinkedRole",
          "autoscaling:CreateAutoScalingGroup"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for afm-cos operations
resource "aws_iam_policy" "afm_cos_policy" {
  name        = "IBMStoragescale-cloudkit-afm-cos"
  description = "A policy to manage afm-cos - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:GetBucketLocation",
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for ebs kms encryption operations
resource "aws_iam_policy" "kms_policy" {
  name        = "IBMStoragescale-cloudkit-kms"
  description = "A policy to manage autoscaling/fleet - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for autoscaling/fleet operations
resource "aws_iam_policy" "fleet_policy" {
  name        = "IBMStoragescale-cloudkit-fleet"
  description = "A policy to manage autoscaling/fleet - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "autoscaling:CreateLaunchConfiguration",
        "Resource" : "*"
      }
    ]
  })
}

# Create policy for managed ad operations
resource "aws_iam_policy" "ad_policy" {
  name        = "IBMStoragescale-cloudkit-ad"
  description = "A policy to manage ad - created by IBM Storage Scale cloudkit"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ds:CreateMicrosoftAD",
          "ds:DescribeTrusts",
          "ds:DescribeLDAPSSettings",
          "ds:ListTagsForResource",
          "ds:DescribeDirectories",
          "ds:DescribeSettings",
          "ds:DeleteDirectory"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "itself" {
  for_each = {
    vpc_policy      = aws_iam_policy.vpc_policy.arn
    dns_policy      = aws_iam_policy.dns_policy.arn
    image_policy    = aws_iam_policy.image_policy.arn
    instance_policy = aws_iam_policy.instance_policy.arn
    bastion_policy  = aws_iam_policy.bastion_policy.arn
    afm_cos_policy  = aws_iam_policy.afm_cos_policy.arn
    kms_policy      = aws_iam_policy.kms_policy.arn
    fleet_policy    = aws_iam_policy.fleet_policy.arn
    ad_policy       = aws_iam_policy.ad_policy.arn
  }
  user       = var.user_name
  policy_arn = each.value
}
