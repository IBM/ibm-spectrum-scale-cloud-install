# Amazon Web Services (AWS)

| Note: IBM Spectrum Scale is supported on AWS via marketplace. For detailed information refer to the offering and supported features, refer to [IBM Spectrum Scale on AWS](https://www.ibm.com/docs/en/spectrum-scale-aws).|
| --- |

The terraform templates provided in this repository offer following features;
  1. Supports provisioning Spectrum Scale resources within a single availability zone.
        - Allows different compute and storage subnet.
        - Allows different compute and storage AMI's.
        - Allows packer image vs. non-packer (stock) image.
        - Allows single/combined, separate compute only, separate storage only and separate compute and storage cluster (remout mount configuration) configuration (**Spectrum Scale filesystem will be configured such that only one copy of data is stored and two copies of metadata will be stored**).
        - Allows EBS (gp2, gp3, io1, io2 and sc1 or st1) and nitro instance profiles.
        - Allows EBS encryption.
  2. Supports provisioning Spectrum Scale resources within a multi (3) availability zones.
        - Allows different compute and storage subnet.
        - Allows different compute and storage AMI's.
        - Allows packer image vs. non-packer (stock) image.
        - Allows single/combined, separate compute only, separate storage only and separate compute and storage cluster (remout mount configuration) configuration (**Spectrum Scale filesystem will be configured such that data and metadata will be replicated across 2 availability zones (Synchronous Replication). AZ-3, will be used as tiebreaker site.**).
        - Allows EBS (gp2, gp3, io1, io2 and sc1 or st1) and nitro instance profiles.
        - Allows EBS encryption.

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
