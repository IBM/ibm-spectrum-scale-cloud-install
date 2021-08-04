# New VNet Template

The following steps will provision Azure resources (new vnet, bastion, ansible jump host, compute and storage instances) and configures IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/azure_new_vnet_scale/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/azure_new_vnet_scale/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zone` keyword. Ex: `"vnet_availability_zones"=["1", "2", "3"]` |
    | --- |

    Minimal Example-1 (create compute, storage cluster with managed disks and remote mount configuration):

    ```jsonc
    {
        "client_id": "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4",
        "client_secret": "0e760437-bf34-4aad-9f8d-870be799c55d",
        "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47",
        "subscription_id": "e652d8de-aea2-4177-a0f1-7117adc604ee",
        "vnet_location": "eastus",
        "vnet_availability_zones": ["1"],
        "resource_group_name": "spectrum-scale",
        "compute_cluster_ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDeFX5ZECXQwqTjczwuTBWYtx0joQ+2d16z/6DDGcouJ42hD0Pslx2m94jl+dyeb+1NFETBRAJ5PrVd+LjgGeEkPwb0Gu3VLRR2gmcAzMjo6FQewBFds1mBh2fi93bolUG3FHf34su6JYE5Ei7+8/0X9zGCPOKFd6bjj19cvy0kN/LUL4n9dnKWM3vnXU2Tj6aDEiwDrQk87c6nmdxyD4J1MDCab/ARK1dK7iAcy9QMod5UBQpDQu7kH054Mfc21ymIK/EkJZ9gMIuP/5q1IGw8NOlQuhIVJSKvS41EVIeY5w0kIWDIkTEKOYZiQ2br2ymWjQ/ 1ScsVyqsxROPhi0EP9aYJ2p0UJDEN9V1lg1SWaPN8TKhG/CAlQzGXdnc20a98cqxu5jzvj8Q7SQoAWL0ZMe1zUVJVs0XvBQItDLW6ZDpGyWTsxAcDwLqYCJubrg3aja17iFa+MCsa5esgY4GsawPtV+o9Dqx63m3joEH/fo53vNpJ6wlwaRK65hE5pkM=",
        "storage_cluster_ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDeFX5ZECXQwqTjczwuTBWYtx0joQ+2d16z/6DDGcouJ42hD0Pslx2m94jl+dyeb+1NFETBRAJ5PrVd+LjgGeEkPwb0Gu3VLRR2gmcAzMjo6FQewBFds1mBh2fi93bolUG3FHf34su6JYE5Ei7+8/0X9zGCPOKFd6bjj19cvy0kN/LUL4n9dnKWM3vnXU2Tj6aDEiwDrQk87c6nmdxyD4J1MDCab/ARK1dK7iAcy9QMod5UBQpDQu7kH054Mfc21ymIK/EkJZ9gMIuP/5q1IGw8NOlQuhIVJSKvS41EVIeY5w0kIWDIkTEKOYZiQ2br2ymWjQ/ 1ScsVyqsxROPhi0EP9aYJ2p0UJDEN9V1lg1SWaPN8TKhG/CAlQzGXdnc20a98cqxu5jzvj8Q7SQoAWL0ZMe1zUVJVs0XvBQItDLW6ZDpGyWTsxAcDwLqYCJubrg3aja17iFa+MCsa5esgY4GsawPtV+o9Dqx63m3joEH/fo53vNpJ6wlwaRK65hE5pkM=",
        "scale_version": "5.1.1.0",
        "compute_cluster_gui_username": "admin",
        "compute_cluster_gui_password": "Passw0rd",
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "total_storage_cluster_instances": 4,
        "total_compute_cluster_instances": 3,
        "ansible_jump_host_ssh_private_key": "/root/.ssh/id_rsa"
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
| <a name="input_vnet_location"></a> [vnet_location](#input_vnet_location) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |
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
| <a name="input_vnet_address_space"></a> [vnet_address_space](#input_vnet_address_space) | The address space that is used by the virtual network. | `list(string)` |
| <a name="input_vnet_compute_cluster_dns_domain"></a> [vnet_compute_cluster_dns_domain](#input_vnet_compute_cluster_dns_domain) | Azure DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vnet_compute_cluster_private_subnets_address_space"></a> [vnet_compute_cluster_private_subnets_address_space](#input_vnet_compute_cluster_private_subnets_address_space) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vnet_create_separate_subnets"></a> [vnet_create_separate_subnets](#input_vnet_create_separate_subnets) | Flag to select if separate private subnet to be created for compute cluster. | `bool` |
| <a name="input_vnet_public_subnets_address_space"></a> [vnet_public_subnets_address_space](#input_vnet_public_subnets_address_space) | List of address prefix to use for public subnets. | `list(string)` |
| <a name="input_vnet_storage_cluster_dns_domain"></a> [vnet_storage_cluster_dns_domain](#input_vnet_storage_cluster_dns_domain) | Azure DNS domain name to be used for storage cluster. | `string` |
| <a name="input_vnet_storage_cluster_private_subnets_address_space"></a> [vnet_storage_cluster_private_subnets_address_space](#input_vnet_storage_cluster_private_subnets_address_space) | List of address prefix to use for storage cluster private subnets. | `list(string)` |
| <a name="input_vnet_tags"></a> [vnet_tags](#input_vnet_tags) | The tags to associate with your network and subnets. | `map(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_jump_host_id"></a> [ansible_jump_host_id](#output_ansible_jump_host_id) | Ansible jump host instance id. |
| <a name="output_ansible_jump_host_private_ip"></a> [ansible_jump_host_private_ip](#output_ansible_jump_host_private_ip) | Ansible jump host instance private ip addresses. |
| <a name="output_ansible_jump_host_public_ip"></a> [ansible_jump_host_public_ip](#output_ansible_jump_host_public_ip) | Ansible jump host instance public ip addresses. |
| <a name="output_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#output_bastion_instance_public_ip) | Bastion instance public ip addresses. |
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_resource_group_name"></a> [resource_group_name](#output_resource_group_name) | New resource group name |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
| <a name="output_vnet_id"></a> [vnet_id](#output_vnet_id) | The ID of the VNET. |
<!-- END_TF_DOCS -->
