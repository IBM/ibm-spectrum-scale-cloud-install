# Configure GCP resources (compute and storage instances in existing VPC)

The following steps will provision GCP resources (compute and storage instances in existing VPC) and configure the IBM Spectrum Scale cloud solution.

1. Change the working directory to `gcp_scale_templates/sub_modules/instance_template/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/sub_modules/instance_template/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones"=[ "us-central1-a" , "us-central1-b" , "us-central1-c"]` |
    | --- |

    Minimal Example-1 (create three compute cluster only):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 0,
        "total_compute_cluster_instances": 3,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : [],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0"]
    }
    EOF
    ```

    Minimal Example-2 (create three storage cluster only):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",   // Use an existing public ssh path
        "total_storage_cluster_instances": 3,
        "total_compute_cluster_instances": 0,
        "data_disks_per_instance" : "2",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0"],
        "vpc_compute_cluster_private_subnets" : []
    }
    EOF
    ```

    Minimal Example-2 (create three storage cluster only with local NVME ssd disk):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",   // Use an existing public ssh path
        "total_storage_cluster_instances": 3,
        "data_disk_type" : "local-ssd",
        "total_compute_cluster_instances": 0,
        "data_disks_per_instance" : "2",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0"],
        "vpc_compute_cluster_private_subnets" : []
    }
    EOF
    ```

    Minimal Example-3 (create three compute cluster with multi zone):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a" , "us-central1-b"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 0,
        "total_compute_cluster_instances": 3,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : [],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0" , "spectrum-scale-comp-pvt-subnet-1"]
    }
    EOF
    ```

    Minimal Example-4 (create three storage cluster only):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a" , "us-central1-b"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 3,
        "total_compute_cluster_instances": 0,
        "data_disks_per_instance" : "2",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0" ,"spectrum-scale-strg-pvt-subnet-1"],
        "vpc_compute_cluster_private_subnets" : []
    }
    EOF
    ```

    Minimal Example-5 (create compute and storage cluster in multi zone ):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : [ "us-central1-a" , "us-central1-b" ],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 2,
        "total_compute_cluster_instances": 2,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0" ,"spectrum-scale-strg-pvt-subnet-1" ],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0" , "spectrum-scale-comp-pvt-subnet-1" ]
    }
    EOF
    ```

    Minimal Example-6 (create compute and storage cluster with one tie breaker for 3 AZ ):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : [ "us-central1-a" , "us-central1-b" , "us-central1-c" ],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 2,
        "total_compute_cluster_instances": 2,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0" ,"spectrum-scale-strg-pvt-subnet-1" , "spectrum-scale-strg-pvt-subnet-2"],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0" , "spectrum-scale-comp-pvt-subnet-1", "spectrum-scale-strg-pvt-subnet-2"]
    }
    EOF
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | ~> 4.0.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_credential_json_path"></a> [credential_json_path](#input_credential_json_path) | The path of a GCP service account key file in JSON format. | `string` |
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID to manage resources. | `string` |
| <a name="input_bastion_instance_id"></a> [bastion_instance_id](#input_bastion_instance_id) | Bastion instance id. | `string` |
| <a name="input_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#input_bastion_instance_public_ip) | Bastion instance public ip address. | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` |
| <a name="input_bastion_user"></a> [bastion_user](#input_bastion_user) | Bastion login username. | `string` |
| <a name="input_block_device_volume_size"></a> [block_device_volume_size](#input_block_device_volume_size) | Data disk size in gigabytes. | `string` |
| <a name="input_block_device_volume_type"></a> [block_device_volume_type](#input_block_device_volume_type) | GCE disk type (valid: pd-standard, pd-ssd , local-ssd). | `any` |
| <a name="input_block_devices_per_storage_instance"></a> [block_devices_per_storage_instance](#input_block_devices_per_storage_instance) | Number of data disks to be attached to each storage instance. | `number` |
| <a name="input_compute_boot_disk_size"></a> [compute_boot_disk_size](#input_compute_boot_disk_size) | Compute instances boot disk size in gigabytes. | `number` |
| <a name="input_compute_boot_disk_type"></a> [compute_boot_disk_type](#input_compute_boot_disk_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_image_ref"></a> [compute_cluster_image_ref](#input_compute_cluster_image_ref) | Image from which to initialize Spectrum Scale compute instances. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_public_key_path"></a> [compute_cluster_public_key_path](#input_compute_cluster_public_key_path) | SSH public key local path for compute instances. | `string` |
| <a name="input_compute_instance_tags"></a> [compute_instance_tags](#input_compute_instance_tags) | Image from which to initialize Spectrum Scale compute instances. | `list(string)` |
| <a name="input_create_remote_mount_cluster"></a> [create_remote_mount_cluster](#input_create_remote_mount_cluster) | Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup. | `bool` |
| <a name="input_create_scale_cluster"></a> [create_scale_cluster](#input_create_scale_cluster) | Flag to represent whether to create scale cluster or not. | `bool` |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | Filesystem block size. | `string` |
| <a name="input_instances_ssh_user_name"></a> [instances_ssh_user_name](#input_instances_ssh_user_name) | Name of the administrator to access the bastion instance. | `string` |
| <a name="input_inventory_format"></a> [inventory_format](#input_inventory_format) | Specify inventory format suited for ansible playbooks. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | GCP stack name, will be used for tagging resources. | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_scopes"></a> [scopes](#input_scopes) | List of service scopes. | `list(string)` |
| <a name="input_scratch_devices_per_storage_instance"></a> [scratch_devices_per_storage_instance](#input_scratch_devices_per_storage_instance) | Number of scratch disks to be attached to each storage instance. | `number` |
| <a name="input_service_email"></a> [service_email](#input_service_email) | GCP service account e-mail address. | `string` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_boot_disk_size"></a> [storage_boot_disk_size](#input_storage_boot_disk_size) | Storage instances boot disk size in gigabytes. | `number` |
| <a name="input_storage_boot_disk_type"></a> [storage_boot_disk_type](#input_storage_boot_disk_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Storage cluster (owningCluster) Filesystem mount point. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for Storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_image_ref"></a> [storage_cluster_image_ref](#input_storage_cluster_image_ref) | Image from which to initialize Spectrum Scale storage instances. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | GCP instance machine type to create Spectrum Scale storage instances. | `string` |
| <a name="input_storage_cluster_public_key_path"></a> [storage_cluster_public_key_path](#input_storage_cluster_public_key_path) | SSH public key local path for storage instances. | `string` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of GCP instances to be launched for compute cluster. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of instances to be launched for storage instances. | `number` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | If true, will skip the jump/bastion host configuration. | `bool` |
| <a name="input_using_packer_image"></a> [using_packer_image](#input_using_packer_image) | If true, gpfs rpm copy step will be skipped during the configuration. | `bool` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_cluster_public_subnets"></a> [vpc_cluster_public_subnets](#input_vpc_cluster_public_subnets) | List of public subnet for bastion/jumphost cluster. | `list(string)` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | GCP region where the resources will be created. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Compute cluster private ips. |
| <a name="output_compute_cluster_security_id"></a> [compute_cluster_security_id](#output_compute_cluster_security_id) | Compute cluster security ids. |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage_cluster_desc_instance_ids](#output_storage_cluster_desc_instance_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage_cluster_desc_instance_private_ips](#output_storage_cluster_desc_instance_private_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Storage cluster private ips. |
| <a name="output_storage_cluster_security_id"></a> [storage_cluster_security_id](#output_storage_cluster_security_id) | Storage cluster security ids. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Storage cluster data volume mapping. |
| <a name="output_storage_cluster_with_dns_hostname"></a> [storage_cluster_with_dns_hostname](#output_storage_cluster_with_dns_hostname) | Storage cluster dns hostname mapping. |
<!-- END_TF_DOCS -->
