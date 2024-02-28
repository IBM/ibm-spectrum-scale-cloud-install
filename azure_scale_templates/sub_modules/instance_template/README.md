# Existing VNet Template

The following steps will provision Azure resources (compute and storage instances in existing VPC) and configures IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/instance_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/instance_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vnet_availability_zones` keyword. Ex: `"vpc_availability_zones"=["1", "2", "3"]` |
    | --- |

    Minimal Example-1 (create only storage cluster):

    ```jsonc
    {
        "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
        "client_secret": "xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
        "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
        "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
        "vpc_region": "eastus",
        "vpc_availability_zones": [
            "1"
        ],
        "vpc_storage_cluster_private_subnets": [
            "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vpc/subnets/spectrum-scale-strg-priv-snet-0"
        ],
        "resource_group_name": "spectrum-scale-rg",
        "total_compute_cluster_instances": 0,
        "total_storage_cluster_instances": 4,
        "storage_boot_disk_type": "Standard_LRS",
        "compute_cluster_ssh_public_key": "/root/.ssh/id_rsa.pub",
        "compute_cluster_dns_zone": "compscale.com",
        "storage_cluster_dns_zone": "strgscale.com",
        "storage_cluster_ssh_public_key": "/root/.ssh/id_rsa.pub",
        "compute_cluster_gui_password": "Passw0rd",
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "ansible_jump_host_id": "/subscriptions/5cd3cd6f-667b-4a89-a046-de077806c368/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/virtualMachines/scale-bastion-0",
        "bastion_instance_public_ip": "XXX.190.42.XX",
        "bastion_ssh_private_key": "/root/.ssh/id_rsa",
        "bastion_user": "azureuser",
        "inventory_format": "json",
        "create_scale_cluster": false,
        "using_direct_connection": false,
        "spectrumscale_rpms_path": "/opt/IBM/ibm-spectrumscale-cloud-deploy",
        "compute_cluster_gui_username": "create_scale_cluster",
        "create_remote_mount_cluster": true,
        "using_jumphost_connection": true,
        "vm_size": "Standard_A2_v2",
        "storage_cluster_image_ref": "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/images/scale-image-52b8dae6836b0519"
    }
    ```

    Minimal Example-2 (create only compute cluster):

    ```jsonc
    {
        "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
        "client_secret": "xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
        "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
        "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
        "vpc_region": "eastus",
        "vpc_availability_zones": [
            "1"
        ],
        "vpc_compute_cluster_private_subnets": [
            "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vpc/subnets/spectrum-scale-comp-priv-snet-0"
        ],
        "resource_group_name": "spectrum-scale-rg",
        "total_compute_cluster_instances": 4,
        "total_storage_cluster_instances": 0,
        "compute_cluster_ssh_public_key": "/root/.ssh/id_rsa.pub",
        "compute_cluster_dns_zone": "eastus.compscale.com",
        "storage_cluster_dns_zone": "eastus.strgscale.com",
        "storage_cluster_ssh_public_key": "/root/.ssh/id_rsa.pub",
        "compute_cluster_gui_password": "Passw0rd",
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "ansible_jump_host_id": "/subscriptions/5cd3cd6f-667b-4a89-a046-de077806c368/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/virtualMachines/scale-bastion-0",
        "bastion_instance_public_ip": "XXX.190.42.167",
        "bastion_ssh_private_key": "/root/.ssh/id_rsa",
        "bastion_user": "azureuser",
        "inventory_format": "json",
        "create_scale_cluster": false,
        "using_direct_connection": false,
        "spectrumscale_rpms_path": "/opt/IBM/ibm-spectrumscale-cloud-deploy",
        "compute_cluster_gui_username": "create_scale_cluster",
        "create_remote_mount_cluster": true,
        "using_jumphost_connection": true,
        "vm_size": "Standard_A2_v2",
        "compute_cluster_image_ref": "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/images/scale-image-52b8dae6836b0519"
    }
    ```

    Minimal Example-3 (create remote mount based compute and storage instances):

    ```jsonc
    {
        "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
        "client_secret": "xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
        "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
        "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
        "vpc_region": "eastus",
        "vpc_availability_zones": [
            "1"
        ],
        "vpc_storage_cluster_private_subnets": [
            "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vpc/subnets/spectrum-scale-strg-priv-snet-0"
        ],
        "vpc_compute_cluster_private_subnets": [
            "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vpc/subnets/spectrum-scale-comp-priv-snet-0"
        ],
        "resource_group_name": "spectrum-scale-rg",
        "total_compute_cluster_instances": 2,
        "total_storage_cluster_instances": 4,
        "compute_cluster_ssh_public_key": "/root/.ssh/id_rsa.pub",
        "compute_cluster_dns_zone": "eastus.compscale.com",
        "storage_cluster_dns_zone": "eastus.strgscale.com",
        "storage_cluster_ssh_public_key": "/root/.ssh/id_rsa.pub",
        "compute_cluster_gui_password": "Passw0rd",
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "ansible_jump_host_id": "/subscriptions/5cd3cd6f-667b-4a89-a046-de077806c368/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/virtualMachines/scale-bastion-0",
        "bastion_instance_public_ip": "172.190.42.167",
        "bastion_ssh_private_key": "/root/.ssh/id_rsa",
        "bastion_user": "azureuser",
        "inventory_format": "json",
        "create_scale_cluster": false,
        "using_direct_connection": false,
        "spectrumscale_rpms_path": "/opt/IBM/ibm-spectrumscale-cloud-deploy",
        "compute_cluster_gui_username": "create_scale_cluster",
        "create_remote_mount_cluster": true,
        "using_jumphost_connection": true,
        "vm_size": "Standard_A2_v2",
        "storage_cluster_image_ref": "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/images/scale-image-52b8dae6836b0519",
        "compute_cluster_image_ref": "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Compute/images/scale-image-52b8dae6836b0519"
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

#### Proximity Placement Groups
The instances deployed as part of the cluster now supported Proximity Placement Groups._(Proximity Placement Groups is a logical grouping used to make sure that resources are physically located close to each other)_.

**This feature is supported only for single AZ's.**

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 3.37 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_client_id"></a> [client_id](#input_client_id) | The Active Directory service principal associated with your account. | `string` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | The password or secret for your service principal. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_enable_placement_group"></a> [enable_placement_group](#input_enable_placement_group) | If true, a placement group will be created and all instances will be created with strategy - cluster. | `bool` |
| <a name="input_resource_group_ref"></a> [resource_group_ref](#input_resource_group_ref) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for Storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_key_pair"></a> [storage_cluster_key_pair](#input_storage_cluster_key_pair) | The SSH public key pair to use to launch the storage cluster host. | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones ids in the region/location. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |
| <a name="input_ansible_jump_host_id"></a> [ansible_jump_host_id](#input_ansible_jump_host_id) | Ansible jump host instance id. | `string` |
| <a name="input_ansible_jump_host_public_ip"></a> [ansible_jump_host_public_ip](#input_ansible_jump_host_public_ip) | Ansible jump host instance public ip address. | `string` |
| <a name="input_ansible_jump_host_ssh_private_key"></a> [ansible_jump_host_ssh_private_key](#input_ansible_jump_host_ssh_private_key) | Ansible jump host SSH private key path, which will be used to login to ansible jump host. | `string` |
| <a name="input_bastion_asg_id"></a> [bastion_asg_id](#input_bastion_asg_id) | Azure Bastion Asg id. | `string` |
| <a name="input_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#input_bastion_instance_public_ip) | Bastion instance public ip address. | `string` |
| <a name="input_bastion_instance_ref"></a> [bastion_instance_ref](#input_bastion_instance_ref) | Bastion instance reference. | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` |
| <a name="input_bastion_user"></a> [bastion_user](#input_bastion_user) | Bastion login username. | `string` |
| <a name="input_block_device_volume_type"></a> [block_device_volume_type](#input_block_device_volume_type) | Type of storage to use for the managed disk (Ex: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS). | `string` |
| <a name="input_compute_boot_disk_type"></a> [compute_boot_disk_type](#input_compute_boot_disk_type) | Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS). | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for Compute cluster GUI. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` |
| <a name="input_compute_cluster_image_ref"></a> [compute_cluster_image_ref](#input_compute_cluster_image_ref) | Image from which to initialize Spectrum Scale compute instances. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_key_pair"></a> [compute_cluster_key_pair](#input_compute_cluster_key_pair) | The SSH public key pair to use to launch the compute cluster host. | `string` |
| <a name="input_compute_cluster_login_username"></a> [compute_cluster_login_username](#input_compute_cluster_login_username) | The username of the local administrator used for the Virtual Machine. | `string` |
| <a name="input_compute_cluster_os_disk_caching"></a> [compute_cluster_os_disk_caching](#input_compute_cluster_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_create_remote_mount_cluster"></a> [create_remote_mount_cluster](#input_create_remote_mount_cluster) | Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup. | `bool` |
| <a name="input_create_scale_cluster"></a> [create_scale_cluster](#input_create_scale_cluster) | Flag to represent whether to create scale cluster or not. | `bool` |
| <a name="input_create_separate_namespaces"></a> [create_separate_namespaces](#input_create_separate_namespaces) | Flag to select if separate namespace needs to be created for compute instances. | `bool` |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | Filesystem block size. | `string` |
| <a name="input_filesystem_data_replication"></a> [filesystem_data_replication](#input_filesystem_data_replication) | Filesystem default replication factor (-r) for data blocks. | `number` |
| <a name="input_filesystem_metadata_replication"></a> [filesystem_metadata_replication](#input_filesystem_metadata_replication) | Filesystem default replication factor (-m) for metadata. | `number` |
| <a name="input_filesystem_parameters"></a> [filesystem_parameters](#input_filesystem_parameters) | Filesystem parameters in relationship with disk parameters. | <pre>list(object({<br>    name                         = string<br>    filesystem_config_file       = string<br>    filesystem_encrypted         = bool<br>    filesystem_kms_key_ref       = string<br>    filesystem_kms_key_ring_ref  = string<br>    device_delete_on_termination = bool<br>    disk_config = list(object({<br>      filesystem_pool                    = string<br>      block_devices_per_storage_instance = number<br>      block_device_volume_type           = string<br>      block_device_volume_size           = string<br>      block_device_iops                  = string<br>      block_device_throughput            = string<br>    }))<br>  }))</pre> |
| <a name="input_instances_ssh_user_name"></a> [instances_ssh_user_name](#input_instances_ssh_user_name) | Compute/Storage VM login username. | `string` |
| <a name="input_inventory_format"></a> [inventory_format](#input_inventory_format) | Specify inventory format suited for ansible playbooks. | `string` |
| <a name="input_os_diff_disk"></a> [os_diff_disk](#input_os_diff_disk) | Ephemeral OS disk placement option, possible values: CacheDisk, ResourceDisk | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_scratch_devices_per_storage_instance"></a> [scratch_devices_per_storage_instance](#input_scratch_devices_per_storage_instance) | Number of scratch disks to be attached to each storage instance. | `number` |
| <a name="input_source_image_id"></a> [source_image_id](#input_source_image_id) | Image id for scale instance. | `string` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_cluster_boot_disk_type"></a> [storage_cluster_boot_disk_type](#input_storage_cluster_boot_disk_type) | Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS). | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Storage cluster (owningCluster) Filesystem mount point. | `string` |
| <a name="input_storage_cluster_image_ref"></a> [storage_cluster_image_ref](#input_storage_cluster_image_ref) | Image from which to initialize Spectrum Scale storage instances. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | Instance type to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_login_username"></a> [storage_cluster_login_username](#input_storage_cluster_login_username) | The username of the local administrator used for the Virtual Machine. | `string` |
| <a name="input_storage_cluster_os_disk_caching"></a> [storage_cluster_os_disk_caching](#input_storage_cluster_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of Azure instances (vms) to be launched for compute cluster. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of Azure instances (vms) to be launched for storage cluster. | `number` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | If true, will skip the jump/bastion host configuration. | `bool` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups. | `bool` |
| <a name="input_using_packer_image"></a> [using_packer_image](#input_using_packer_image) | If true, gpfs rpm copy step will be skipped during the configuration. | `bool` |
| <a name="input_using_rest_api_remote_mount"></a> [using_rest_api_remote_mount](#input_using_rest_api_remote_mount) | If false, skips GUI initialization on compute cluster for remote mount configuration. | `string` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | Compute cluster DNS zone. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_compute_cluster_public_subnet"></a> [vpc_compute_cluster_public_subnet](#input_vpc_compute_cluster_public_subnet) | List of IDs of compute cluster public subnets. | `list(string)` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | Storage cluster DNS zone. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |
| <a name="input_vpc_storage_cluster_public_subnet"></a> [vpc_storage_cluster_public_subnet](#input_vpc_storage_cluster_public_subnet) | List of IDs of storage cluster public subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_user"></a> [bastion_user](#output_bastion_user) | Bastion OS Login username. |
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_compute_cluster_security_group_id"></a> [compute_cluster_security_group_id](#output_compute_cluster_security_group_id) | Compute cluster security group id. |
| <a name="output_scale_cluster_asg_id"></a> [scale_cluster_asg_id](#output_scale_cluster_asg_id) | Scale cluster Asg id. |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage_cluster_desc_instance_ids](#output_storage_cluster_desc_instance_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage_cluster_desc_instance_private_ips](#output_storage_cluster_desc_instance_private_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_security_group_id"></a> [storage_cluster_security_group_id](#output_storage_cluster_security_group_id) | Storage cluster security group id. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
<!-- END_TF_DOCS -->
