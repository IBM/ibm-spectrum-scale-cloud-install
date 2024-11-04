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
| <a name="requirement_google"></a> [google](#requirement_google) | ~> 5.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_airgap"></a> [airgap](#input_airgap) | If true, instance iam profile, git utils which need internet access will be skipped. | `bool` |
| <a name="input_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#input_bastion_instance_public_ip) | Bastion instance public ip address. | `string` |
| <a name="input_bastion_instance_ref"></a> [bastion_instance_ref](#input_bastion_instance_ref) | Bastion instance reference. | `string` |
| <a name="input_bastion_security_group_ref"></a> [bastion_security_group_ref](#input_bastion_security_group_ref) | Bastion security group reference (id/self-link). | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` |
| <a name="input_bastion_user"></a> [bastion_user](#input_bastion_user) | Bastion login username. | `string` |
| <a name="input_client_security_group_ref"></a> [client_security_group_ref](#input_client_security_group_ref) | Client security group reference (id/self-link). | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_compute_cluster_boot_disk_size"></a> [compute_cluster_boot_disk_size](#input_compute_cluster_boot_disk_size) | Compute instances boot disk size in gigabytes. | `string` |
| <a name="input_compute_cluster_boot_disk_type"></a> [compute_cluster_boot_disk_type](#input_compute_cluster_boot_disk_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for Compute cluster GUI. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` |
| <a name="input_compute_cluster_image_ref"></a> [compute_cluster_image_ref](#input_compute_cluster_image_ref) | Image from which to initialize Spectrum Scale compute instances. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_public_key_path"></a> [compute_cluster_public_key_path](#input_compute_cluster_public_key_path) | SSH public key local path for compute instances. | `string` |
| <a name="input_create_remote_mount_cluster"></a> [create_remote_mount_cluster](#input_create_remote_mount_cluster) | Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup. | `bool` |
| <a name="input_create_scale_cluster"></a> [create_scale_cluster](#input_create_scale_cluster) | Flag to represent whether to create scale cluster or not. | `bool` |
| <a name="input_credential_json_path"></a> [credential_json_path](#input_credential_json_path) | The path of a GCP service account key file in JSON format. | `string` |
| <a name="input_filesystem_parameters"></a> [filesystem_parameters](#input_filesystem_parameters) | Filesystem parameters in relationship with disk parameters. | <pre>list(object({<br/>    name                         = string<br/>    filesystem_config_file       = string<br/>    filesystem_kms_key_ring_ref  = string<br/>    filesystem_kms_key_ref       = string<br/>    device_delete_on_termination = bool<br/>    disk_config = list(object({<br/>      filesystem_pool                    = string<br/>      block_devices_per_storage_instance = number<br/>      block_device_volume_type           = string<br/>      block_device_volume_size           = string<br/>    }))<br/>  }))</pre> |
| <a name="input_gateway_instance_type"></a> [gateway_instance_type](#input_gateway_instance_type) | Instance type to use for provisioning the gateway instances. | `string` |
| <a name="input_instances_ssh_user_name"></a> [instances_ssh_user_name](#input_instances_ssh_user_name) | Compute/Storage VM login username. | `string` |
| <a name="input_inventory_format"></a> [inventory_format](#input_inventory_format) | Specify inventory format suited for ansible playbooks. | `string` |
| <a name="input_marked_vm_names_to_attach_disks"></a> [marked_vm_names_to_attach_disks](#input_marked_vm_names_to_attach_disks) | Specify the instance names for which disks needs to be attached | `list(string)` |
| <a name="input_physical_block_size_bytes"></a> [physical_block_size_bytes](#input_physical_block_size_bytes) | Physical block size of the persistent disk, in bytes (valid: 4096, 16384). | `number` |
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID to manage resources. | `string` |
| <a name="input_protocol_instance_type"></a> [protocol_instance_type](#input_protocol_instance_type) | Instance type to use for provisioning the protocol instances. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | GCP stack name, will be used for tagging resources. | `string` |
| <a name="input_root_device_kms_key_ref"></a> [root_device_kms_key_ref](#input_root_device_kms_key_ref) | GCP KMS Key reference to use when encrypting the volume. | `string` |
| <a name="input_root_device_kms_key_ring_ref"></a> [root_device_kms_key_ring_ref](#input_root_device_kms_key_ring_ref) | GCP KMS Key ring reference to use when encrypting the volume. | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_scopes"></a> [scopes](#input_scopes) | List of service scopes. | `list(string)` |
| <a name="input_scratch_devices_per_storage_instance"></a> [scratch_devices_per_storage_instance](#input_scratch_devices_per_storage_instance) | Number of scratch disks to be attached to each storage instance. | `number` |
| <a name="input_service_email"></a> [service_email](#input_service_email) | GCP service account e-mail address. | `string` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_cluster_boot_disk_size"></a> [storage_cluster_boot_disk_size](#input_storage_cluster_boot_disk_size) | Storage instances boot disk size in gigabytes. | `number` |
| <a name="input_storage_cluster_boot_disk_type"></a> [storage_cluster_boot_disk_type](#input_storage_cluster_boot_disk_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for Storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_image_ref"></a> [storage_cluster_image_ref](#input_storage_cluster_image_ref) | Image from which to initialize Spectrum Scale storage instances. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | GCP instance machine type to create Spectrum Scale storage instances. | `string` |
| <a name="input_storage_cluster_public_key_path"></a> [storage_cluster_public_key_path](#input_storage_cluster_public_key_path) | SSH public key local path for storage instances. | `string` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of GCP instances to be launched for compute cluster. | `number` |
| <a name="input_total_gateway_instances"></a> [total_gateway_instances](#input_total_gateway_instances) | Number of EC2 instances to be launched for gateway nodes. | `number` |
| <a name="input_total_protocol_instances"></a> [total_protocol_instances](#input_total_protocol_instances) | Number of EC2 instances to be launched for protocol nodes. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of instances to be launched for storage instances. | `number` |
| <a name="input_using_cloud_connection"></a> [using_cloud_connection](#input_using_cloud_connection) | This flag is intended to enable ansible related communication between a cloud virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `client_security_group_ref` (make sure it is in the same vpc), as the cloud VM security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups. | `bool` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud virtual private cloud (VPC) via a VPN or direct connection. This mode requires variable `client_ip_ranges`, as the on-premise client ip will be added to the allowed ingress list of scale (storage/compute) cluster security groups. | `bool` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups. | `bool` |
| <a name="input_using_packer_image"></a> [using_packer_image](#input_using_packer_image) | If true, gpfs rpm copy step will be skipped during the configuration. | `bool` |
| <a name="input_using_rest_api_remote_mount"></a> [using_rest_api_remote_mount](#input_using_rest_api_remote_mount) | If false, skips GUI initialization on compute cluster for remote mount configuration. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | GCP Cloud DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_forward_dns_zone"></a> [vpc_forward_dns_zone](#input_vpc_forward_dns_zone) | GCP Cloud DNS zone name to be used for scale cluster (Ex: example-zone). | `string` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | GCP region where the resources will be created. | `string` |
| <a name="input_vpc_reverse_dns_domain"></a> [vpc_reverse_dns_domain](#input_vpc_reverse_dns_domain) | DNS reverse domain (Ex: 10.in-addr.arpa). | `string` |
| <a name="input_vpc_reverse_dns_zone"></a> [vpc_reverse_dns_zone](#input_vpc_reverse_dns_zone) | GCP Cloud DNS reverse zone lookup to be used for scale cluster (Ex: example-zone-reverse). | `string` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | GCP Cloud DNS domain name to be used for storage cluster. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_airgap"></a> [airgap](#output_airgap) | Air gap environment |
| <a name="output_compute_cluster_instance_details"></a> [compute_cluster_instance_details](#output_compute_cluster_instance_details) | Compute cluster instance details (map of id, private_ip, dns) |
| <a name="output_compute_cluster_security_group_id"></a> [compute_cluster_security_group_id](#output_compute_cluster_security_group_id) | Compute cluster security ids. |
| <a name="output_gateway_instance_details"></a> [gateway_instance_details](#output_gateway_instance_details) | Gateway instance details (map of id, private_ip, dns) |
| <a name="output_protocol_instance_details"></a> [protocol_instance_details](#output_protocol_instance_details) | Protocol instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_dec_instance_details"></a> [storage_cluster_dec_instance_details](#output_storage_cluster_dec_instance_details) | Storage cluster desc instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_instance_details"></a> [storage_cluster_instance_details](#output_storage_cluster_instance_details) | Protocol instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_security_group_id"></a> [storage_cluster_security_group_id](#output_storage_cluster_security_group_id) | Storage cluster security ids. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
<!-- END_TF_DOCS -->
