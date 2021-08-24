# IBM Cloud

The terraform templates provided in this repository offer following features;

  1. Supports provisioning Spectrum Scale resources within a single availability zone.
        - Allows different compute and storage subnet.
        - Allows different compute and storage Image's.
        - Allows packer/custom image vs. non-packer (stock) image.
        - Allows single/combined, separate compute only, separate storage only and separate compute and storage cluster (remout mount configuration) configuration (**Spectrum Scale filesystem will be configured such that only one copy of data is stored and two copies of metadata will be stored**).
        - Allows Instance storage VSI profiles.

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

    - Install [git](https://github.com/git-guides/install-git) and validate:

      ```bash
      # git --version
      git version 2.32.0
      ```

        > Ensure git version is greater than or equal to 2.1.4 version

2. Ensure that you have configured your IBM Cloud (`IC_API_KEY`) infrastructure key credentials.

    - Log in to the [IBM Cloud portal](https://cloud.ibm.com/login).
    - Select Account > Users.
    - On the Users page, find your user credentials in the Active User list.
    - Under API Key, click Generate.
    - Click View to display the API key that was generated for the user.
    - On the View API Key page, copy the key into your system buffer.

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

### (Option-1) New VPC Based Configuration (Single AZ)

This option provisions a new IBM Cloud VPC environment consisting of the address prefix, subnets, public gateway, security groups, bastion VSI, compute (instances with NO data volumes attached) and storage (instance storage volumes attached) VSI's, and then deploys IBM Spectrum Scale into this new VPC with a single availability zone.

Refer to [New VPC Based Configuration](../ibmcloud_scale_templates/ibmcloud_new_vpc_scale/README.md) for detailed steps, options.

### (Option-2) Existing VPC Based Configuration (Single AZ)

This option deploys IBM Spectrum Scale in to an existing VPC.

Refer [Existing VPC Based Configuration](../ibmcloud_scale_templates/sub_modules/instance_template/README.md) for detailed steps, options.

> This mode provides flexibility to bypass bastion/jump host, incase local/cloud VM has direct connectivity to VPC.
