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
| <a name="requirement_github"></a> [github](#requirement_github) | 5.41.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | 1.65.1 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | IBM Cloud resource group id. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_key_pair"></a> [storage_cluster_key_pair](#input_storage_cluster_key_pair) | The key pair to use to launch the storage cluster host. | `list(string)` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_client_cluster_dns_service_id"></a> [vpc_client_cluster_dns_service_id](#input_vpc_client_cluster_dns_service_id) | IBM Cloud client cluster DNS service resource id. | `string` |
| <a name="input_vpc_client_cluster_dns_zone_id"></a> [vpc_client_cluster_dns_zone_id](#input_vpc_client_cluster_dns_zone_id) | IBM Cloud client cluster DNS zone id. | `string` |
| <a name="input_vpc_compute_cluster_dns_service_id"></a> [vpc_compute_cluster_dns_service_id](#input_vpc_compute_cluster_dns_service_id) | IBM Cloud compute cluster DNS service resource id. | `string` |
| <a name="input_vpc_compute_cluster_dns_zone_id"></a> [vpc_compute_cluster_dns_zone_id](#input_vpc_compute_cluster_dns_zone_id) | IBM Cloud compute cluster DNS zone id. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_custom_resolver_id"></a> [vpc_custom_resolver_id](#input_vpc_custom_resolver_id) | IBM Cloud DNS custom resolver id. | `string` |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_protocol_cluster_dns_service_id"></a> [vpc_protocol_cluster_dns_service_id](#input_vpc_protocol_cluster_dns_service_id) | IBM Cloud compute cluster DNS service resource id. | `string` |
| <a name="input_vpc_protocol_cluster_dns_zone_id"></a> [vpc_protocol_cluster_dns_zone_id](#input_vpc_protocol_cluster_dns_zone_id) | IBM Cloud compute cluster DNS zone id. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc. | `string` |
| <a name="input_vpc_storage_cluster_dns_service_id"></a> [vpc_storage_cluster_dns_service_id](#input_vpc_storage_cluster_dns_service_id) | IBM Cloud storage cluster DNS service resource id. | `string` |
| <a name="input_vpc_storage_cluster_dns_zone_id"></a> [vpc_storage_cluster_dns_zone_id](#input_vpc_storage_cluster_dns_zone_id) | IBM Cloud storage cluster DNS zone id. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |
| <a name="input_activity_tracker_plan_type"></a> [activity_tracker_plan_type](#input_activity_tracker_plan_type) | IBM Cloud activity tracker plan type (Valid: lite, 7-day, 14-day, 30-day, hipaa-30-day). | `string` |
| <a name="input_bastion_instance_id"></a> [bastion_instance_id](#input_bastion_instance_id) | Bastion instance id. | `string` |
| <a name="input_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#input_bastion_instance_public_ip) | Bastion instance public ip address. | `string` |
| <a name="input_bastion_security_group_id"></a> [bastion_security_group_id](#input_bastion_security_group_id) | Bastion security group id. | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` |
| <a name="input_bastion_user"></a> [bastion_user](#input_bastion_user) | Provide the username for Bastion login. | `string` |
| <a name="input_bms_boot_drive_encryption"></a> [bms_boot_drive_encryption](#input_bms_boot_drive_encryption) | To enable the encryption for the boot drive of bare metal server. Select true or false | `bool` |
| <a name="input_client_cluster_key_pair"></a> [client_cluster_key_pair](#input_client_cluster_key_pair) | The key pair to use to launch the client cluster host. | `list(string)` |
| <a name="input_client_vsi_osimage_name"></a> [client_vsi_osimage_name](#input_client_vsi_osimage_name) | Name of the image that you would like to use to create the client cluster nodes for the IBM Storage Scale cluster. The solution supports only stock images that use RHEL8.8 version. | `string` |
| <a name="input_client_vsi_profile"></a> [client_vsi_profile](#input_client_vsi_profile) | Client nodes vis profile | `string` |
| <a name="input_colocate_protocol_cluster_instances"></a> [colocate_protocol_cluster_instances](#input_colocate_protocol_cluster_instances) | Enable it to use storage instances as protocol instances | `bool` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for compute cluster GUI | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` |
| <a name="input_compute_cluster_key_pair"></a> [compute_cluster_key_pair](#input_compute_cluster_key_pair) | The key pair to use to launch the compute cluster host. | `list(string)` |
| <a name="input_compute_vsi_osimage_id"></a> [compute_vsi_osimage_id](#input_compute_vsi_osimage_id) | Image id to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_vsi_osimage_name"></a> [compute_vsi_osimage_name](#input_compute_vsi_osimage_name) | Image name to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_vsi_profile"></a> [compute_vsi_profile](#input_compute_vsi_profile) | Profile to be used for compute cluster virtual server instance. | `string` |
| <a name="input_create_scale_cluster"></a> [create_scale_cluster](#input_create_scale_cluster) | Flag to represent whether to create scale cluster or not. | `bool` |
| <a name="input_create_separate_namespaces"></a> [create_separate_namespaces](#input_create_separate_namespaces) | Flag to select if separate namespace needs to be created for compute instances. | `bool` |
| <a name="input_deploy_controller_sec_group_id"></a> [deploy_controller_sec_group_id](#input_deploy_controller_sec_group_id) | Deployment controller security group id. Default: null | `string` |
| <a name="input_enable_ldap"></a> [enable_ldap](#input_enable_ldap) | Set this option to true to enable LDAP for IBM Cloud HPC, with the default value set to false. | `bool` |
| <a name="input_filesets"></a> [filesets](#input_filesets) | Mount point(s) and size(s) in GB of file share(s) that can be used to customize shared file storage layout. Provide the details for up to 5 file shares. | <pre>list(object({<br>    mount_path = string,<br>    size       = number<br>  }))</pre> |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | Filesystem block size. | `string` |
| <a name="input_gklm_instance_dns_domain"></a> [gklm_instance_dns_domain](#input_gklm_instance_dns_domain) | IBM Cloud DNS domain name to be used for GKLM instances. | `string` |
| <a name="input_gklm_instance_dns_service_id"></a> [gklm_instance_dns_service_id](#input_gklm_instance_dns_service_id) | IBM Cloud GKLM Instance DNS service resource id. | `string` |
| <a name="input_gklm_instance_dns_zone_id"></a> [gklm_instance_dns_zone_id](#input_gklm_instance_dns_zone_id) | IBM GKLM Instance DNS zone id. | `string` |
| <a name="input_gklm_instance_key_pair"></a> [gklm_instance_key_pair](#input_gklm_instance_key_pair) | The key pair to use to launch the GKLM host. | `list(string)` |
| <a name="input_gklm_vsi_osimage_id"></a> [gklm_vsi_osimage_id](#input_gklm_vsi_osimage_id) | Image id to use for provisioning the GKLM instances. | `string` |
| <a name="input_gklm_vsi_osimage_name"></a> [gklm_vsi_osimage_name](#input_gklm_vsi_osimage_name) | Image name to use for provisioning the GKLM instances. | `string` |
| <a name="input_gklm_vsi_profile"></a> [gklm_vsi_profile](#input_gklm_vsi_profile) | Profile to be used for GKLM virtual server instance. | `string` |
| <a name="input_inventory_format"></a> [inventory_format](#input_inventory_format) | Specify inventory format suited for ansible playbooks. | `string` |
| <a name="input_ldap_admin_password"></a> [ldap_admin_password](#input_ldap_admin_password) | The LDAP administrative password should be 8 to 20 characters long, with a mix of at least three alphabetic characters, including one uppercase and one lowercase letter. It must also include two numerical digits and at least one special character from (~@_+:) are required. It is important to avoid including the username in the password for enhanced security.[This value is ignored for an existing LDAP server]. | `string` |
| <a name="input_ldap_basedns"></a> [ldap_basedns](#input_ldap_basedns) | The dns domain name is used for configuring the LDAP server. If an LDAP server is already in existence, ensure to provide the associated DNS domain name. | `string` |
| <a name="input_ldap_instance_key_pair"></a> [ldap_instance_key_pair](#input_ldap_instance_key_pair) | Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the LDAP Server. Make sure that the SSH key is present in the same resource group and region where the LDAP Servers are provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions. | `list(string)` |
| <a name="input_ldap_server"></a> [ldap_server](#input_ldap_server) | Provide the IP address for the existing LDAP server. If no address is given, a new LDAP server will be created. | `string` |
| <a name="input_ldap_user_name"></a> [ldap_user_name](#input_ldap_user_name) | Custom LDAP User for performing cluster operations. Note: Username should be between 4 to 32 characters, (any combination of lowercase and uppercase letters).[This value is ignored for an existing LDAP server] | `string` |
| <a name="input_ldap_user_password"></a> [ldap_user_password](#input_ldap_user_password) | The LDAP user password should be 8 to 20 characters long, with a mix of at least three alphabetic characters, including one uppercase and one lowercase letter. It must also include two numerical digits and at least one special character from (~@_+:) are required.It is important to avoid including the username in the password for enhanced security.[This value is ignored for an existing LDAP server]. | `string` |
| <a name="input_ldap_vsi_osimage_name"></a> [ldap_vsi_osimage_name](#input_ldap_vsi_osimage_name) | Image name to be used for provisioning the LDAP instances. Note: Debian based OS are only supported for the LDAP feature. | `string` |
| <a name="input_ldap_vsi_profile"></a> [ldap_vsi_profile](#input_ldap_vsi_profile) | Profile to be used for LDAP virtual server instance. | `string` |
| <a name="input_management_vsi_profile"></a> [management_vsi_profile](#input_management_vsi_profile) | Profile to be used for management instance. | `string` |
| <a name="input_protocol_vsi_profile"></a> [protocol_vsi_profile](#input_protocol_vsi_profile) | Profile to be used for compute cluster virtual server instance. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_scale_cluster_resource_tags"></a> [scale_cluster_resource_tags](#input_scale_cluster_resource_tags) | A list of tags for resources created for scale cluster. | `list(string)` |
| <a name="input_scale_encryption_admin_default_password"></a> [scale_encryption_admin_default_password](#input_scale_encryption_admin_default_password) | The default administrator password used for resetting the admin password based on the user input. The password has to be updated which was configured during the GKLM installation. | `string` |
| <a name="input_scale_encryption_admin_password"></a> [scale_encryption_admin_password](#input_scale_encryption_admin_password) | Password that is used for performing administrative operations for the GKLM.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character from this(~@_+:). Make sure that the password doesn't include the username. Visit this [page](https://www.ibm.com/docs/en/gklm/3.0.1?topic=roles-password-policy) to know more about password policy of GKLM. | `string` |
| <a name="input_scale_encryption_admin_username"></a> [scale_encryption_admin_username](#input_scale_encryption_admin_username) | The default Admin username for Security Key Lifecycle Manager(GKLM). | `string` |
| <a name="input_scale_encryption_enabled"></a> [scale_encryption_enabled](#input_scale_encryption_enabled) | To enable the encryption for the filesystem. Select true or false | `bool` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_bare_metal_osimage_id"></a> [storage_bare_metal_osimage_id](#input_storage_bare_metal_osimage_id) | Image Id to use for provisioning the storage Baremetal cluster instances. | `string` |
| <a name="input_storage_bare_metal_osimage_name"></a> [storage_bare_metal_osimage_name](#input_storage_bare_metal_osimage_name) | Image name to use for provisioning the storage Baremetal cluster. | `string` |
| <a name="input_storage_bare_metal_server_profile"></a> [storage_bare_metal_server_profile](#input_storage_bare_metal_server_profile) | Specify the virtual server instance profile type name to be used to create the Baremetal Storage nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui). | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Storage cluster (owningCluster) Filesystem mount point. | `string` |
| <a name="input_storage_type"></a> [storage_type](#input_storage_type) | Select the required scale filesystem deployment method. Note: Choosing the scale scratch or evaluation type will deploy scale filesystem on VSI and scale persistent type will deploy scale filesystem on Baremetal server. | `string` |
| <a name="input_storage_vsi_osimage_id"></a> [storage_vsi_osimage_id](#input_storage_vsi_osimage_id) | Image id to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_vsi_osimage_name"></a> [storage_vsi_osimage_name](#input_storage_vsi_osimage_name) | Image name to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_vsi_profile"></a> [storage_vsi_profile](#input_storage_vsi_profile) | Profile to be used for storage cluster virtual server instance. | `string` |
| <a name="input_total_client_cluster_instances"></a> [total_client_cluster_instances](#input_total_client_cluster_instances) | Total number of client cluster instances that you need to provision. A minimum of 2 nodes and a maximum of 64 nodes are supported | `number` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of instances to be launched for compute cluster. | `number` |
| <a name="input_total_gklm_instances"></a> [total_gklm_instances](#input_total_gklm_instances) | Number of instances to be launched for GKLM. | `number` |
| <a name="input_total_protocol_cluster_instances"></a> [total_protocol_cluster_instances](#input_total_protocol_cluster_instances) | Total number of protocol nodes that you need to provision. A minimum of 2 nodes and a maximum of 16 nodes are supported | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of instances to be launched for storage cluster. | `number` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | If true, will skip the jump/bastion host configuration. | `bool` |
| <a name="input_using_packer_image"></a> [using_packer_image](#input_using_packer_image) | If true, gpfs rpm copy step will be skipped during the configuration. | `bool` |
| <a name="input_using_rest_api_remote_mount"></a> [using_rest_api_remote_mount](#input_using_rest_api_remote_mount) | If false, skips GUI initialization on compute cluster for remote mount configuration. | `string` |
| <a name="input_vpc_client_cluster_dns_domain"></a> [vpc_client_cluster_dns_domain](#input_vpc_client_cluster_dns_domain) | IBM Cloud DNS domain name to be used for client cluster. | `string` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | IBM Cloud DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vpc_create_activity_tracker"></a> [vpc_create_activity_tracker](#input_vpc_create_activity_tracker) | Flag to select if IBM Cloud activity tracker to be created or not. Note: You can only provision 1 instance of this service per IBM Cloud region. | `bool` |
| <a name="input_vpc_protocol_cluster_dns_domain"></a> [vpc_protocol_cluster_dns_domain](#input_vpc_protocol_cluster_dns_domain) | IBM Cloud DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vpc_protocol_cluster_private_subnets"></a> [vpc_protocol_cluster_private_subnets](#input_vpc_protocol_cluster_private_subnets) | List of IDs of protocol nodes private subnets. | `list(string)` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | IBM Cloud DNS domain name to be used for storage cluster. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_baremetal_cluster_instance_ids"></a> [baremetal_cluster_instance_ids](#output_baremetal_cluster_instance_ids) | storage cluster bare metal server ids |
| <a name="output_baremetal_cluster_instance_private_ips"></a> [baremetal_cluster_instance_private_ips](#output_baremetal_cluster_instance_private_ips) | Private IP address of storage cluster bare metal instances. |
| <a name="output_baremetal_cluster_with_data_volume_mapping"></a> [baremetal_cluster_with_data_volume_mapping](#output_baremetal_cluster_with_data_volume_mapping) | Mapping of storage cluster bare meteal server ip vs device path. |
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage_cluster_desc_instance_ids](#output_storage_cluster_desc_instance_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage_cluster_desc_instance_private_ips](#output_storage_cluster_desc_instance_private_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
<!-- END_TF_DOCS -->
