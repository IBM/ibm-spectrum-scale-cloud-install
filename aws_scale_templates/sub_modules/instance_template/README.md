<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_instance_public_ip"></a> [bastion\_instance\_public\_ip](#input\_bastion\_instance\_public\_ip) | Bastion instance public ip address. | `string` | `null` | no |
| <a name="input_bastion_security_group_id"></a> [bastion\_security\_group\_id](#input\_bastion\_security\_group\_id) | Bastion security group id. | `string` | `null` | no |
| <a name="input_bastion_ssh_private_key"></a> [bastion\_ssh\_private\_key](#input\_bastion\_ssh\_private\_key) | Bastion SSH private key path, which will be used to login to bastion host. | `string` | `null` | no |
| <a name="input_compute_cluster_ami_id"></a> [compute\_cluster\_ami\_id](#input\_compute\_cluster\_ami\_id) | ID of AMI to use for provisioning the compute cluster instances. | `string` | n/a | yes |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute\_cluster\_filesystem\_mountpoint](#input\_compute\_cluster\_filesystem\_mountpoint) | Compute cluster (accessingCluster) Filesystem mount point. | `string` | `"/gpfs/fs1"` | no |
| <a name="input_compute_cluster_gui_password"></a> [compute\_cluster\_gui\_password](#input\_compute\_cluster\_gui\_password) | Password for Compute cluster GUI. | `string` | n/a | yes |
| <a name="input_compute_cluster_gui_username"></a> [compute\_cluster\_gui\_username](#input\_compute\_cluster\_gui\_username) | GUI user to perform system management and monitoring tasks on compute cluster. | `string` | n/a | yes |
| <a name="input_compute_cluster_instance_type"></a> [compute\_cluster\_instance\_type](#input\_compute\_cluster\_instance\_type) | Instance type to use for provisioning the compute cluster instances. | `string` | `"t2.medium"` | no |
| <a name="input_compute_cluster_key_pair"></a> [compute\_cluster\_key\_pair](#input\_compute\_cluster\_key\_pair) | The key pair to use to launch the compute cluster host. | `string` | n/a | yes |
| <a name="input_compute_cluster_root_volume_type"></a> [compute\_cluster\_root\_volume\_type](#input\_compute\_cluster\_root\_volume\_type) | EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1. | `string` | `"gp2"` | no |
| <a name="input_compute_cluster_tags"></a> [compute\_cluster\_tags](#input\_compute\_cluster\_tags) | Additional tags for the compute cluster. | `map(string)` | `{}` | no |
| <a name="input_compute_cluster_volume_tags"></a> [compute\_cluster\_volume\_tags](#input\_compute\_cluster\_volume\_tags) | Additional tags for the compute cluster volume(s). | `map(string)` | `{}` | no |
| <a name="input_create_separate_namespaces"></a> [create\_separate\_namespaces](#input\_create\_separate\_namespaces) | Flag to select if separate namespace needs to be created for compute instances. | `bool` | `true` | no |
| <a name="input_ebs_block_device_delete_on_termination"></a> [ebs\_block\_device\_delete\_on\_termination](#input\_ebs\_block\_device\_delete\_on\_termination) | If true, all ebs volumes will be destroyed on instance termination. | `bool` | `true` | no |
| <a name="input_ebs_block_device_encrypted"></a> [ebs\_block\_device\_encrypted](#input\_ebs\_block\_device\_encrypted) | Whether to enable volume encryption. | `bool` | `false` | no |
| <a name="input_ebs_block_device_iops"></a> [ebs\_block\_device\_iops](#input\_ebs\_block\_device\_iops) | Amount of provisioned IOPS. Only valid for volume\_type of io1, io2 or gp3. | `number` | `0` | no |
| <a name="input_ebs_block_device_kms_key_id"></a> [ebs\_block\_device\_kms\_key\_id](#input\_ebs\_block\_device\_kms\_key\_id) | Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. | `string` | `null` | no |
| <a name="input_ebs_block_device_volume_size"></a> [ebs\_block\_device\_volume\_size](#input\_ebs\_block\_device\_volume\_size) | Size of the volume in gibibytes (GiB). | `number` | `500` | no |
| <a name="input_ebs_block_device_volume_type"></a> [ebs\_block\_device\_volume\_type](#input\_ebs\_block\_device\_volume\_type) | EBS volume types: io1, io2, gp2, gp3, st1 and sc1. | `string` | `"gp2"` | no |
| <a name="input_ebs_block_devices_per_storage_instance"></a> [ebs\_block\_devices\_per\_storage\_instance](#input\_ebs\_block\_devices\_per\_storage\_instance) | Additional EBS block devices to attach per storage cluster instance. | `number` | `1` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| <a name="input_filesystem_block_size"></a> [filesystem\_block\_size](#input\_filesystem\_block\_size) | Filesystem block size. | `string` | `"4M"` | no |
| <a name="input_operator_email"></a> [operator\_email](#input\_operator\_email) | SNS notifications will be sent to provided email id. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix is added to all resources that are created. | `string` | `"spectrum-scale"` | no |
| <a name="input_scale_ansible_repo_clone_path"></a> [scale\_ansible\_repo\_clone\_path](#input\_scale\_ansible\_repo\_clone\_path) | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` | `"/opt/IBM/ibm-spectrumscale-cloud-deploy"` | no |
| <a name="input_scale_version"></a> [scale\_version](#input\_scale\_version) | IBM Spectrum Scale version. | `string` | n/a | yes |
| <a name="input_spectrumscale_rpms_path"></a> [spectrumscale\_rpms\_path](#input\_spectrumscale\_rpms\_path) | Path that contains IBM Spectrum Scale product cloud rpms. | `string` | `"/opt/IBM/gpfs_cloud_rpms"` | no |
| <a name="input_storage_cluster_ami_id"></a> [storage\_cluster\_ami\_id](#input\_storage\_cluster\_ami\_id) | ID of AMI to use for provisioning the storage cluster instances. | `string` | n/a | yes |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage\_cluster\_filesystem\_mountpoint](#input\_storage\_cluster\_filesystem\_mountpoint) | Storage cluster (owningCluster) Filesystem mount point. | `string` | `"/gpfs/fs1"` | no |
| <a name="input_storage_cluster_gui_password"></a> [storage\_cluster\_gui\_password](#input\_storage\_cluster\_gui\_password) | Password for Storage cluster GUI | `string` | n/a | yes |
| <a name="input_storage_cluster_gui_username"></a> [storage\_cluster\_gui\_username](#input\_storage\_cluster\_gui\_username) | GUI user to perform system management and monitoring tasks on storage cluster. | `string` | n/a | yes |
| <a name="input_storage_cluster_instance_type"></a> [storage\_cluster\_instance\_type](#input\_storage\_cluster\_instance\_type) | Instance type to use for provisioning the storage cluster instances. | `string` | `"t2.medium"` | no |
| <a name="input_storage_cluster_key_pair"></a> [storage\_cluster\_key\_pair](#input\_storage\_cluster\_key\_pair) | The key pair to use to launch the storage cluster host. | `string` | n/a | yes |
| <a name="input_storage_cluster_root_volume_type"></a> [storage\_cluster\_root\_volume\_type](#input\_storage\_cluster\_root\_volume\_type) | EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1. | `string` | `"gp2"` | no |
| <a name="input_storage_cluster_tags"></a> [storage\_cluster\_tags](#input\_storage\_cluster\_tags) | Additional tags for the storage cluster. | `map(string)` | `{}` | no |
| <a name="input_storage_cluster_tiebreaker_instance_type"></a> [storage\_cluster\_tiebreaker\_instance\_type](#input\_storage\_cluster\_tiebreaker\_instance\_type) | Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration). | `string` | `"t2.medium"` | no |
| <a name="input_storage_cluster_volume_tags"></a> [storage\_cluster\_volume\_tags](#input\_storage\_cluster\_volume\_tags) | Additional tags for the storage cluster volume(s). | `map(string)` | `{}` | no |
| <a name="input_total_compute_cluster_instances"></a> [total\_compute\_cluster\_instances](#input\_total\_compute\_cluster\_instances) | Number of EC2 instances to be launched for compute cluster. | `number` | `3` | no |
| <a name="input_total_storage_cluster_instances"></a> [total\_storage\_cluster\_instances](#input\_total\_storage\_cluster\_instances) | Number of EC2 instances to be launched for storage cluster. | `number` | `4` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | A list of availability zones names or ids in the region. | `list(string)` | n/a | yes |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc\_compute\_cluster\_private\_subnets](#input\_vpc\_compute\_cluster\_private\_subnets) | List of IDs of compute cluster private subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id were to deploy the bastion. | `string` | n/a | yes |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` | n/a | yes |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc\_storage\_cluster\_private\_subnets](#input\_vpc\_storage\_cluster\_private\_subnets) | List of IDs of storage cluster private subnets. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_cluster_instance_ids"></a> [compute\_cluster\_instance\_ids](#output\_compute\_cluster\_instance\_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute\_cluster\_instance\_private\_ips](#output\_compute\_cluster\_instance\_private\_ips) | Private IP address of compute cluster instances. |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage\_cluster\_desc\_data\_volume\_mapping](#output\_storage\_cluster\_desc\_data\_volume\_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage\_cluster\_desc\_instance\_ids](#output\_storage\_cluster\_desc\_instance\_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage\_cluster\_desc\_instance\_private\_ips](#output\_storage\_cluster\_desc\_instance\_private\_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_ids"></a> [storage\_cluster\_instance\_ids](#output\_storage\_cluster\_instance\_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage\_cluster\_instance\_private\_ips](#output\_storage\_cluster\_instance\_private\_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage\_cluster\_with\_data\_volume\_mapping](#output\_storage\_cluster\_with\_data\_volume\_mapping) | Mapping of storage cluster instance ip vs. device path. |
<!-- END_TF_DOCS -->
