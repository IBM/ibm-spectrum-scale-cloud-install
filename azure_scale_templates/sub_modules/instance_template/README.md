### Existing VPC Template

The following steps will provision AWS resources (compute and storage instances in existing VPC) and configures IBM Spectrum Scale cloud solution.

1. Change working directory to `aws_scale_templates/sub_modules/instance_template`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/aws_scale_templates/sub_modules/instance_template/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zone` keyword. Ex: `"vpc_availability_zones"=["us-east-1a", "us-east-1b", "us-east-1c"]` |
    | --- |

    Minimal Example-1 (create only storage cluster with gp2):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": null,                                  // Use an existing vpc id
        "vpc_storage_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "vpc_compute_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "total_storage_cluster_instances": 4,
        "total_compute_cluster_instances": 0,            // Make compute nodes count to zero
        "ebs_block_devices_per_storage_instance": 1,
        "ebs_block_device_volume_size": 500,
        "ebs_block_device_volume_type": "gp2",
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": null,                          // Email address for notification
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "storage_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "bastion_ssh_private_key": null,                 // Use bastion ssh private key path
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "bastion_instance_public_ip": null,              // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                // Use null if direct connectivity to vpc exists
    }
    ```

    Minimal Example-2 (create only storage cluster with gp3):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": null,                                  // Use an existing vpc id
        "vpc_storage_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "vpc_compute_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "total_storage_cluster_instances": 4,
        "total_compute_cluster_instances": 0,            // Make compute nodes count to zero
        "ebs_block_devices_per_storage_instance": 1,
        "ebs_block_device_volume_type": "gp3",
        "ebs_block_device_iops": 3000,
        "ebs_block_device_throughput": 125,
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": null,                          // Email address for notification
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "storage_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "bastion_ssh_private_key": null,                 // Use bastion ssh private key path
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "bastion_instance_public_ip": null,              // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                // Use null if direct connectivity to vpc exists
    }
    ```

    Minimal Example-3 (create only storage cluster with iop1, iop2):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": null,                                  // Use an existing vpc id
        "vpc_storage_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "vpc_compute_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "total_storage_cluster_instances": 4,
        "ebs_block_devices_per_storage_instance": 1,
        "ebs_block_device_volume_type": "gp3",
        "ebs_block_device_iops": 3000,
        "total_compute_cluster_instances": 0,
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": "sasikanth.eda@in.ibm.com",
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "storage_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "bastion_ssh_private_key": null,                 // Use bastion ssh private key path
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "bastion_instance_public_ip": null,              // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                // Use null if direct connectivity to vpc exists
    }
    ```

    Minimal Example-4 (create only storage cluster with NVMe/nitro instances):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": null,                                   // Use an existing vpc id
        "vpc_storage_cluster_private_subnets": [],        // Use an existing vpc private subnet
        "vpc_compute_cluster_private_subnets": [],        // Use an existing vpc private subnet
        "total_storage_cluster_instances": 4,
        "ebs_block_devices_per_storage_instance": 1,
        "ebs_block_device_volume_type": "gp3",
        "ebs_block_device_iops": 3000,
        "ebs_block_device_throughput": 125,
        "total_compute_cluster_instances": 0,
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": "sasikanth.eda@in.ibm.com",
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_key_pair": null,                 // Use an existing AWS EC2 key pair
        "storage_cluster_key_pair": null,                 // Use an existing AWS EC2 key pair
        "bastion_ssh_private_key": null,                  // Use bastion ssh private key path
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "bastion_instance_public_ip": null,               // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                 // Use null if direct connectivity to vpc exists
    }
    ```

    Minimal Example-5 (create only compute cluster):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": null,                                  // Use an existing vpc id
        "vpc_storage_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "vpc_compute_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "total_storage_cluster_instances": 0,            // Make storage nodes count to zero
        "total_compute_cluster_instances": 3,
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": "sasikanth.eda@in.ibm.com",
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "storage_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "compute_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "bastion_ssh_private_key": null,                 // Use bastion ssh private key path
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd"
        "bastion_instance_public_ip": null,              // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                // Use null if direct connectivity to vpc exists
    }
    ```

    Minimal Example-6 (create remote mount based compute and storage instances):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": null,                                  // Use an existing vpc id
        "vpc_storage_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "vpc_compute_cluster_private_subnets": [],       // Use an existing vpc private subnet
        "create_separate_namespaces": false,
        "total_storage_cluster_instances": 4,
        "total_compute_cluster_instances": 3,
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": "sasikanth.eda@in.ibm.com",
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "storage_cluster_key_pair": null,                // Use an existing AWS EC2 key pair
        "bastion_ssh_private_key": null,                 // Use bastion ssh private key path
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "bastion_instance_public_ip": null,              // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                // Use null if direct connectivity to vpc exists
    }
    ```

    Minimal Example-7 (create single cluster with both compute and storage instances):
    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"],
        "resource_prefix": "spectrum-scale",
        "vpc_id": "vpc-0b24596ced49f9407",
        "vpc_storage_cluster_private_subnets": ["subnet-0d74f55f21106371a"],
        "vpc_compute_cluster_private_subnets": ["subnet-0e2a0fda0cca020a7"],
        "create_separate_namespaces": false,
        "total_storage_cluster_instances": 4,
        "total_compute_cluster_instances": 3,
        "compute_cluster_key_pair": null,
        "compute_cluster_image_id": "ami-0b0af3577fe5e3532",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_gui_username": "admin",
        "operator_email": "sasikanth.eda@in.ibm.com",
        "scale_version": "5.1.1.0",
        "storage_cluster_image_id": "ami-0b0af3577fe5e3532",
        "storage_cluster_key_pair": null,
        "bastion_ssh_private_key": null,                 [[** Use bastion ssh private key path **]]
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "bastion_instance_public_ip": null,              // Use null if direct connectivity to vpc exists
        "bastion_security_group_id": null                // Use null if direct connectivity to vpc exists
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 2.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_client_id"></a> [client_id](#input_client_id) | The Active Directory service principal associated with your account. | `string` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | The password or secret for your service principal. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for Compute cluster GUI. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` |
| <a name="input_compute_cluster_ssh_public_key"></a> [compute_cluster_ssh_public_key](#input_compute_cluster_ssh_public_key) | The SSH public key to use to launch the compute cluster host. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_scale_version"></a> [scale_version](#input_scale_version) | IBM Spectrum Scale version. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for Storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_ssh_public_key"></a> [storage_cluster_ssh_public_key](#input_storage_cluster_ssh_public_key) | The SSH public key to use to launch the storage cluster host. | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_vnet_availability_zones"></a> [vnet_availability_zones](#input_vnet_availability_zones) | A list of availability zones ids in the region/location. | `list(string)` |
| <a name="input_vnet_compute_cluster_private_subnets"></a> [vnet_compute_cluster_private_subnets](#input_vnet_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vnet_location"></a> [vnet_location](#input_vnet_location) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |
| <a name="input_vnet_storage_cluster_private_subnets"></a> [vnet_storage_cluster_private_subnets](#input_vnet_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |
| <a name="input_ansible_jump_host_public_ip"></a> [ansible_jump_host_public_ip](#input_ansible_jump_host_public_ip) | Ansible jump host instance public ip address. | `string` |
| <a name="input_ansible_jump_host_ssh_private_key"></a> [ansible_jump_host_ssh_private_key](#input_ansible_jump_host_ssh_private_key) | Ansible jump host SSH private key path, which will be used to login to ansible jump host. | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_image_offer"></a> [compute_cluster_image_offer](#input_compute_cluster_image_offer) | Specifies the offer of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_compute_cluster_image_publisher"></a> [compute_cluster_image_publisher](#input_compute_cluster_image_publisher) | Specifies the publisher of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_compute_cluster_image_sku"></a> [compute_cluster_image_sku](#input_compute_cluster_image_sku) | Specifies the SKU of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_compute_cluster_image_version"></a> [compute_cluster_image_version](#input_compute_cluster_image_version) | Specifies the version of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_compute_cluster_login_username"></a> [compute_cluster_login_username](#input_compute_cluster_login_username) | The username of the local administrator used for the Virtual Machine. | `string` |
| <a name="input_compute_cluster_os_disk_caching"></a> [compute_cluster_os_disk_caching](#input_compute_cluster_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_compute_cluster_os_storage_account_type"></a> [compute_cluster_os_storage_account_type](#input_compute_cluster_os_storage_account_type) | Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS). | `string` |
| <a name="input_compute_cluster_vm_size"></a> [compute_cluster_vm_size](#input_compute_cluster_vm_size) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_create_separate_namespaces"></a> [create_separate_namespaces](#input_create_separate_namespaces) | Flag to select if separate namespace needs to be created for compute instances. | `bool` |
| <a name="input_data_disk_size"></a> [data_disk_size](#input_data_disk_size) | Size of the volume in gibibytes (GB). | `number` |
| <a name="input_data_disk_storage_account_type"></a> [data_disk_storage_account_type](#input_data_disk_storage_account_type) | Type of storage to use for the managed disk (Ex: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS). | `string` |
| <a name="input_data_disks_per_storage_instance"></a> [data_disks_per_storage_instance](#input_data_disks_per_storage_instance) | Additional Data disks to attach per storage cluster instance. | `number` |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | Filesystem block size. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Storage cluster (owningCluster) Filesystem mount point. | `string` |
| <a name="input_storage_cluster_image_offer"></a> [storage_cluster_image_offer](#input_storage_cluster_image_offer) | Specifies the offer of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_storage_cluster_image_publisher"></a> [storage_cluster_image_publisher](#input_storage_cluster_image_publisher) | Specifies the publisher of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_storage_cluster_image_sku"></a> [storage_cluster_image_sku](#input_storage_cluster_image_sku) | Specifies the SKU of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_storage_cluster_image_version"></a> [storage_cluster_image_version](#input_storage_cluster_image_version) | Specifies the version of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_storage_cluster_login_username"></a> [storage_cluster_login_username](#input_storage_cluster_login_username) | The username of the local administrator used for the Virtual Machine. | `string` |
| <a name="input_storage_cluster_os_disk_caching"></a> [storage_cluster_os_disk_caching](#input_storage_cluster_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_storage_cluster_os_storage_account_type"></a> [storage_cluster_os_storage_account_type](#input_storage_cluster_os_storage_account_type) | Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS). | `string` |
| <a name="input_storage_cluster_vm_size"></a> [storage_cluster_vm_size](#input_storage_cluster_vm_size) | Instance type to use for provisioning the storage cluster instances. | `string` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of Azure instances (vms) to be launched for compute cluster. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of Azure instances (vms) to be launched for storage cluster. | `number` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | If true, will skip the jump/bastion host configuration. | `bool` |
| <a name="input_using_packer_image"></a> [using_packer_image](#input_using_packer_image) | If true, gpfs rpm copy step will be skipped during the configuration. | `bool` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
<!-- END_TF_DOCS -->
