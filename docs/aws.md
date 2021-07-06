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

## Configure local/cloud VM

1. Ensure that the following requirements are met on the local/cloud VM where this repository is cloned.

    - Install [Terraform](https://www.terraform.io/downloads.html) and validate:
        ```bash
        # terraform -v
        ```
    - Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) and validate:
        ```bash
        # ansible --version
        ```
        > Currently, spectrum scale ansible playbooks support only 2.9 version (can be installed using `pip3 install ansible==2.9`)
    
    - Install [Python36](https://www.python.org/downloads/) and validate:
        ```bash
        # python --version
        Python 3.6.14
        ```

2. Ensure that you have configured your AWS CLI credentials;
    - [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
    - [Create access keys for IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
    - [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration).

3. Download the IBM Spectrum Scale Data Management Edition install package (from Fix Central) and perform below steps;
    ```bash
    # mkdir -p /opt/IBM/gpfs_cloud_rpms
    # ls -lrth Spectrum_Scale_Data_Management-<package_code_version>-x86_64-Linux-install
      -rwxr-xr-x 1 root root 1.6G Jul  6 14:02 Spectrum_Scale_Data_Management-<package_code_version>-x86_64-Linux-install
    # ./Spectrum_Scale_Data_Management-<package_code_version>-x86_64-Linux-install --silent
    # ls /usr/lpp/mmfs/package_code_version/
      Public_Keys      ganesha_debs  gpfs_debs  hdfs_debs  license   object_rpms  smb_rpms  zimon_debs
      ansible-toolkit  ganesha_rpms  gpfs_rpms  hdfs_rpms  manifest  smb_debs     tools     zimon_rpms
    # cd /usr/lpp/mmfs/<package_code_version>/gpfs_rpms
    # cp gpfs.adv* gpfs.base* gpfs.crypto* gpfs.docs* gpfs.gpl* gpfs.gskit* gpfs.gui* gpfs.java* gpfs.license.dm* gpfs.msg.en_US* /opt/IBM/gpfs_cloud_rpms/
    # cd /usr/lpp/mmfs/<package_code_version>/zimon_rpms/rhel7
    # cp gpfs.gss.pmcollector*  gpfs.gss.pmsensors* /opt/IBM/gpfs_cloud_rpms
    # cd /usr/lpp/mmfs/<package_code_version>/zimon_rpms/rhel8
    # cp gpfs.gss.pmcollector*  gpfs.gss.pmsensors* /opt/IBM/gpfs_cloud_rpms
    # cd /usr/lpp/mmfs/<package_code_version>/Public_Keys
    # cp SpectrumScale_public_key.pgp /opt/IBM/gpfs_cloud_rpms/
    ```

### Configure terraform S3 backend

Refer [Configure terraform S3 backend](../aws_scale_templates/prepare_tf_s3_backend/README.md)

## New VPC Based Configuration

Refer [New VPC Based Configuration](../aws_scale_templates/aws_new_vpc_scale/README.md)

## Existing VPC Based Configuration

Refer [Existing VPC Based Configuration](../aws_scale_templates/sub_modules/instance_template/README.md)
