# Amazon Web Services (AWS)

This templates offer;
1. New VPC Deployment
A. Single zone
-  Support for separate compute and storage subnet
-  Support for packer images vs. non-packer images
-  Support for single/combined, separate compute only, separate storage only, separate compute and storage clusters.
-  Support for both EBS (old, new gen) and instance storage volumes
-  Support for volume encryption
B. Multi (3) zone
- Support for separate compute and storage subnet
- Support for packer images vs. non-packer images
- Compute nodes are provisioned only the primary single zone
- Support for single/combined, separate compute only, separate storage only, separate compute and storage clusters.
-  Support for only EBS (old, new gen).
-  Support for volume encryption


2. Existing VPC Deployment
A. Single zone
- Support for configuration via Bastion  and direct VPN
- Support for separate compute and storage subnet
- Support for packer images vs. non-packer images
- Support for single/combined, separate compute only, separate storage only, separate compute and storage clusters.
-  Support for both EBS (old, new gen) and instance storage volumes
-  Support for volume encryption
B. Multi (3) zone
- Support for configuration via Bastion  and direct VPN
- Support for separate compute and storage subnet
- Support for packer images vs. non-packer images
- Compute nodes are provisioned only the primary single zone
- Support for single/combined, separate compute only, separate storage only, separate compute and storage clusters.
-  Support for only EBS (old, new gen).
-  Support for volume encryption

## Before Starting

Ensure that you have configured your AWS public cloud credentials:

1. [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
2. [Create access keys for IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
3. [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration).

### Configure terraform S3 backend

Refer [Configure terraform S3 backend](../aws_scale_templates/prepare_tf_s3_backend/README.md)

## New VPC Based Configuration

Refer [New VPC Based Configuration](../aws_scale_templates/aws_new_vpc_scale/README.md)

## Existing VPC Based Configuration

Refer [Existing VPC Based Configuration](../aws_scale_templates/sub_modules/instance_template/README.md)
