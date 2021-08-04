# Microsoft Azure

The terraform templates provided in this repository offer following features;

  1. Supports provisioning Spectrum Scale resources within a single availability zone.
        - Allows different compute and storage subnet.
        - Allows different compute and storage Image's.
        - Allows packer/custom image vs. non-packer (stock) image.
        - Allows single/combined, separate compute only, separate storage only and separate compute and storage cluster (remote mount configuration) configuration (**Spectrum Scale filesystem will be configured such that only one copy of data is stored and two copies of metadata will be stored**).
        - Allows managed disk (Standard_LRS, StandardSSD_LRS and Premium_LRS) types.
  2. Supports provisioning Spectrum Scale resources within a multi (3) availability zones.
        - Allows different compute and storage subnet.
        - Allows different compute and storage Image's.
        - Allows packer/custom image vs. non-packer (stock) image.
        - Allows single/combined, separate compute only, separate storage only and separate compute and storage cluster (remote mount configuration) configuration (**Spectrum Scale filesystem will be configured such that data and metadata will be replicated across 2 availability zones (Synchronous Replication). AZ-3, will be used as tiebreaker site.**).
        - Allows EBS (Standard_LRS, StandardSSD_LRS and Premium_LRS) types.

  > **_NOTE:_** In order to create a Custom VM Image, refer to [Packer Azure Image Creation](../packer_templates/azure/README.md) for detailed steps, options.

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

    - Install [Python3.6](https://www.python.org/downloads/) and validate:

        ```bash
        # python --version
        Python 3.6.14
        ```

2. Create Azure credentials

    Terraform templates authenticates with Azure using a service principal.

    - Create a service principal with [az ad sp create-for-rbac](https://docs.microsoft.com/en-us/cli/azure/ad/sp) and output the credentials that Packer needs:

    ```azurecli
    az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
    ```

    An example of the output from the preceding commands is as follows:

    ```azurecli
    {
        "client_id": "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4",
        "client_secret": "0e760437-bf34-4aad-9f8d-870be799c55d",
        "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47"
    }
    ```

    To authenticate to Azure, you also need to obtain your Azure subscription ID with [az account show](https://docs.microsoft.com/en-us/cli/azure/account):

    ```azurecli
    az account show --query "{ subscription_id: id }"
    ```

    An example of the output from the preceding commands is as follows:

    ```azurecli
    {
        "subscription_id": "e652d8de-aea2-4177-a0f1-7117adc604ee"
    }
    ```

    Keep the outputs from these two commands handy, they are needed to configure both deployment options in the next steps.

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

## Deployment Options

The terraform templates provided in this repository offer following deployment options;

> **_NOTE:_** By default below options use *terraform local backend*.
In order to configure below options to use *terraform S3 backend*, use `./tools/enable_azure_s3_backend.sh`.

### (Option-1) New VNet Based Configuration (Single AZ, Multi AZ)

This option provisions a new Azure VNet environment consisting of the subnets, security groups, bastion, ansible jump host, compute (instances with NO managed data disks attached) and storage (instances with managed data disks attached) instances, and then deploys IBM Spectrum Scale into this new VNet with a single or multi availability zone(s).

Refer to [New VNet Based Configuration](../azure_scale_templates/azure_new_vnet_scale/README.md) for detailed steps, options.

### (Option-2) Existing VNet Based Configuration (Single AZ, Multi AZ)

This option deploys IBM Spectrum Scale in to an existing VNet (which can have subnets with multiple availability zones).

Refer [Existing VNet Based Configuration](../azure_scale_templates/sub_modules/instance_template/README.md) for detailed steps, options.

> This mode provides flexibility to bypass bastion/jump host, incase local/cloud VM has direct connectivity to VNet.
