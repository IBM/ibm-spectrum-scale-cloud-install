<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 3.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_compute_cluster_ami_id"></a> [compute_cluster_ami_id](#input_compute_cluster_ami_id) | ID of AMI to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for Compute cluster GUI. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` |
| <a name="input_compute_cluster_key_pair"></a> [compute_cluster_key_pair](#input_compute_cluster_key_pair) | The key pair to use to launch the compute cluster host. | `string` |
| <a name="input_operator_email"></a> [operator_email](#input_operator_email) | SNS notifications will be sent to provided email id. | `string` |
| <a name="input_scale_version"></a> [scale_version](#input_scale_version) | IBM Spectrum Scale version. | `string` |
| <a name="input_storage_cluster_ami_id"></a> [storage_cluster_ami_id](#input_storage_cluster_ami_id) | ID of AMI to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for Storage cluster GUI | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` |
| <a name="input_storage_cluster_key_pair"></a> [storage_cluster_key_pair](#input_storage_cluster_key_pair) | The key pair to use to launch the storage cluster host. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |
| <a name="input_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#input_bastion_instance_public_ip) | Bastion instance public ip address. | `string` |
| <a name="input_bastion_security_group_id"></a> [bastion_security_group_id](#input_bastion_security_group_id) | Bastion security group id. | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_root_volume_type"></a> [compute_cluster_root_volume_type](#input_compute_cluster_root_volume_type) | EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1. | `string` |
| <a name="input_compute_cluster_tags"></a> [compute_cluster_tags](#input_compute_cluster_tags) | Additional tags for the compute cluster. | `map(string)` |
| <a name="input_compute_cluster_volume_tags"></a> [compute_cluster_volume_tags](#input_compute_cluster_volume_tags) | Additional tags for the compute cluster volume(s). | `map(string)` |
| <a name="input_create_separate_namespaces"></a> [create_separate_namespaces](#input_create_separate_namespaces) | Flag to select if separate namespace needs to be created for compute instances. | `bool` |
| <a name="input_ebs_block_device_delete_on_termination"></a> [ebs_block_device_delete_on_termination](#input_ebs_block_device_delete_on_termination) | If true, all ebs volumes will be destroyed on instance termination. | `bool` |
| <a name="input_ebs_block_device_encrypted"></a> [ebs_block_device_encrypted](#input_ebs_block_device_encrypted) | Whether to enable volume encryption. | `bool` |
| <a name="input_ebs_block_device_iops"></a> [ebs_block_device_iops](#input_ebs_block_device_iops) | Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3. | `number` |
| <a name="input_ebs_block_device_kms_key_id"></a> [ebs_block_device_kms_key_id](#input_ebs_block_device_kms_key_id) | Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. | `string` |
| <a name="input_ebs_block_device_volume_size"></a> [ebs_block_device_volume_size](#input_ebs_block_device_volume_size) | Size of the volume in gibibytes (GiB). | `number` |
| <a name="input_ebs_block_device_volume_type"></a> [ebs_block_device_volume_type](#input_ebs_block_device_volume_type) | EBS volume types: io1, io2, gp2, gp3, st1 and sc1. | `string` |
| <a name="input_ebs_block_devices_per_storage_instance"></a> [ebs_block_devices_per_storage_instance](#input_ebs_block_devices_per_storage_instance) | Additional EBS block devices to attach per storage cluster instance. | `number` |
| <a name="input_enable_nvme_block_device"></a> [enable_nvme_block_device](#input_enable_nvme_block_device) | Enable NVMe block devices (built on Nitro instances). | `bool` |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | Filesystem block size. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale_ansible_repo_clone_path](#input_scale_ansible_repo_clone_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale_rpms_path](#input_spectrumscale_rpms_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Storage cluster (owningCluster) Filesystem mount point. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | Instance type to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_root_volume_type"></a> [storage_cluster_root_volume_type](#input_storage_cluster_root_volume_type) | EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1. | `string` |
| <a name="input_storage_cluster_tags"></a> [storage_cluster_tags](#input_storage_cluster_tags) | Additional tags for the storage cluster. | `map(string)` |
| <a name="input_storage_cluster_tiebreaker_instance_type"></a> [storage_cluster_tiebreaker_instance_type](#input_storage_cluster_tiebreaker_instance_type) | Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration). | `string` |
| <a name="input_storage_cluster_volume_tags"></a> [storage_cluster_volume_tags](#input_storage_cluster_volume_tags) | Additional tags for the storage cluster volume(s). | `map(string)` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of EC2 instances to be launched for compute cluster. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of EC2 instances to be launched for storage cluster. | `number` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage_cluster_desc_instance_ids](#output_storage_cluster_desc_instance_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage_cluster_desc_instance_private_ips](#output_storage_cluster_desc_instance_private_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
<!-- END_TF_DOCS -->
