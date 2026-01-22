# Existing VPC Template

Below steps will provision IBM Cloud resources (compute and storage instances in existing VPC) and and configures IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/sub_modules/instance_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```jsonc
    {
        "vpc_region": "us-south",
        "vpc_availability_zones": ["us-south-1"],
        "vpc_id": null,                                 // Use an existing vpc id
        "vpc_custom_resolver_id": null,                 // Use existing DNS custom resolver id
        "resource_group_id": null,                      // Use an existing resource group
        "bastion_security_group_id": null,              // Use an existing bastion security group id
        "bastion_instance_public_ip": null,             // Use an existing bastion public ip
        "bastion_instance_id": null,                    // Use an existing bastion instance id
        "bastion_ssh_private_key": "/root/.ssh/id_rsa",
        "compute_cluster_gui_username": "admin",
        "compute_cluster_gui_password": "Passw0rd",
        "compute_cluster_key_pair": null,               // Use an existing key pair
        "vpc_compute_cluster_private_subnets": [],      // Use an existing private subnet id
        "vpc_storage_cluster_private_subnets": [],      // Use an existing private subnet id
        "storage_cluster_key_pair": null,               // Use an existing key pair
        "storage_cluster_gui_username": "admin",
        "storage_cluster_gui_password": "Passw0rd",
        "vpc_compute_cluster_dns_service_id": null,     // Use an existing DNS service id
        "vpc_storage_cluster_dns_service_id": null,     // Use an existing DNS service id
        "vpc_compute_cluster_dns_zone_id": null,        // Use an existing DNS zone id
        "vpc_storage_cluster_dns_zone_id": null         // Use an existing DNS zone id
    }
    ```

3. Export your IBM Cloud credentials by exporting the `IC_API_KEY` as environment variables.

    Example:

    ```cli
    export IC_API_KEY=68jfz8VDfQzMNUFE_JcU5mCqd6zSmmznrwUbZqwrKJ5k
    ```

4. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | 1.84.3 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_airgap"></a> [airgap](#input_airgap) | If true, instance iam profile, git utils which need internet access will be skipped. | `bool` |
| <a name="input_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#input_bastion_instance_public_ip) | Bastion instance public ip address. | `string` |
| <a name="input_bastion_instance_ref"></a> [bastion_instance_ref](#input_bastion_instance_ref) | Bastion instance ref. | `string` |
| <a name="input_bastion_security_group_ref"></a> [bastion_security_group_ref](#input_bastion_security_group_ref) | Bastion security group reference (id/self-link). | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` |
| <a name="input_bastion_user"></a> [bastion_user](#input_bastion_user) | Bastion login username. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_compute_cluster_boot_disk_type"></a> [compute_cluster_boot_disk_type](#input_compute_cluster_boot_disk_type) | EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1. | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for Compute cluster GUI. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` |
| <a name="input_compute_cluster_image_ref"></a> [compute_cluster_image_ref](#input_compute_cluster_image_ref) | ID of AMI to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_public_key_path"></a> [compute_cluster_public_key_path](#input_compute_cluster_public_key_path) | The ssh public key to be created used to launch the compute cluster. | `string` |
| <a name="input_compute_cluster_tags"></a> [compute_cluster_tags](#input_compute_cluster_tags) | Additional tags for the compute cluster. | `map(string)` |
| <a name="input_compute_cluster_volume_tags"></a> [compute_cluster_volume_tags](#input_compute_cluster_volume_tags) | Additional tags for the compute cluster volume(s). | `map(string)` |
| <a name="input_create_remote_mount_cluster"></a> [create_remote_mount_cluster](#input_create_remote_mount_cluster) | Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup. | `bool` |
| <a name="input_create_scale_cluster"></a> [create_scale_cluster](#input_create_scale_cluster) | Flag to represent whether to create scale cluster or not. | `bool` |
| <a name="input_filesystem_parameters"></a> [filesystem_parameters](#input_filesystem_parameters) | Filesystem parameters in relationship with disk parameters. | <pre>list(object({<br/>    name                         = string<br/>    filesystem_config_file       = string<br/>    filesystem_encrypted         = bool<br/>    filesystem_kms_key_ref       = string<br/>    device_delete_on_termination = bool<br/>    disk_config = list(object({<br/>      filesystem_pool                    = string<br/>      block_devices_per_storage_instance = number<br/>      block_device_volume_type           = string<br/>      block_device_volume_size           = string<br/>      block_device_iops                  = string<br/>      block_device_throughput            = string<br/>    }))<br/>  }))</pre> |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_instances_ssh_user_name"></a> [instances_ssh_user_name](#input_instances_ssh_user_name) | Compute/Storage EC2 instances login username. | `string` |
| <a name="input_inventory_format"></a> [inventory_format](#input_inventory_format) | Specify inventory format suited for ansible playbooks. Examples: ini, json | `string` |
| <a name="input_marked_vm_names_to_attach_disks"></a> [marked_vm_names_to_attach_disks](#input_marked_vm_names_to_attach_disks) | Specify the instance names for which disks needs to be attached | `list(string)` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | IBM Cloud resource group name. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_root_device_encrypted"></a> [root_device_encrypted](#input_root_device_encrypted) | Whether to enable volume encryption for root device. | `bool` |
| <a name="input_root_device_kms_key_ref"></a> [root_device_kms_key_ref](#input_root_device_kms_key_ref) | GUID of the Key Protect/HPCS instance to be used when encrypting the root volume. | `string` |
| <a name="input_root_device_kms_key_ref_name"></a> [root_device_kms_key_ref_name](#input_root_device_kms_key_ref_name) | Name of the root/standard key to be used when encrypting the root volume. | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_service_instance_ref"></a> [service_instance_ref](#input_service_instance_ref) | IBM Cloud DNS Service Instance Id | `string` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_cluster_boot_disk_type"></a> [storage_cluster_boot_disk_type](#input_storage_cluster_boot_disk_type) | EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for Storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_image_ref"></a> [storage_cluster_image_ref](#input_storage_cluster_image_ref) | ID of AMI to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | Instance type to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_public_key_path"></a> [storage_cluster_public_key_path](#input_storage_cluster_public_key_path) | The ssh public key to be created used to launch the storage cluster. | `string` |
| <a name="input_storage_cluster_tags"></a> [storage_cluster_tags](#input_storage_cluster_tags) | Additional tags for the storage cluster. | `map(string)` |
| <a name="input_storage_cluster_tiebreaker_instance_type"></a> [storage_cluster_tiebreaker_instance_type](#input_storage_cluster_tiebreaker_instance_type) | Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration). | `string` |
| <a name="input_storage_cluster_volume_tags"></a> [storage_cluster_volume_tags](#input_storage_cluster_volume_tags) | Additional tags for the storage cluster volume(s). | `map(string)` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of EC2 instances to be launched for compute cluster. | `number` |
| <a name="input_total_protocol_instances"></a> [total_protocol_instances](#input_total_protocol_instances) | Number of EC2 instances to be launched for protocol nodes. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of EC2 instances to be launched for storage cluster. | `number` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_security_group_ref`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups. | `bool` |
| <a name="input_using_packer_image"></a> [using_packer_image](#input_using_packer_image) | If true, gpfs rpm copy step will be skipped during the configuration. | `bool` |
| <a name="input_using_rest_api_remote_mount"></a> [using_rest_api_remote_mount](#input_using_rest_api_remote_mount) | If false, skips GUI initialization on compute cluster for remote mount configuration. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | DNS domain name to be used for storage cluster. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_airgap"></a> [airgap](#output_airgap) | Air gap environment |
| <a name="output_bastion_user"></a> [bastion_user](#output_bastion_user) | Bastion OS Login username. |
| <a name="output_compute_cluster_security_group_id"></a> [compute_cluster_security_group_id](#output_compute_cluster_security_group_id) | Compute cluster security group id. |
| <a name="output_local_block_device_count"></a> [local_block_device_count](#output_local_block_device_count) | n/a |
| <a name="output_profile_disks_debug"></a> [profile_disks_debug](#output_profile_disks_debug) | n/a |
| <a name="output_profile_name_debug"></a> [profile_name_debug](#output_profile_name_debug) | n/a |
| <a name="output_protocol_cluster_security_group_id"></a> [protocol_cluster_security_group_id](#output_protocol_cluster_security_group_id) | Protocol cluster security group id. |
| <a name="output_storage_cluster_security_group_id"></a> [storage_cluster_security_group_id](#output_storage_cluster_security_group_id) | Storage cluster security group id. |
<!-- END_TF_DOCS -->
