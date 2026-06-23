# Existing VPC Template

The following steps will provision IBM Cloud resources (compute and storage instances in existing VPC) and configure the IBM Spectrum Scale cloud solution.

1. Change the working directory to `ibmcloud_scale_templates/sub_modules/instance_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones": ["us-south-1", "us-south-2", "us-south-3"]` |
    | --- |

    **Example 1: Storage-only Cluster**

    ```json
    {
        "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
        "vpc_region": "us-south",
        "vpc_availability_zones": ["us-south-1"],
        "resource_prefix": "spectrum-scale",
        "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
        "vpc_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "vpc_storage_cluster_private_subnets": ["0717-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"],
        "cluster_type": "Storage-only",
        "total_storage_cluster_instances": 4,
        "storage_cluster_instance_type": "bx2d-8x32",
        "storage_cluster_image_id": "r006-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
        "storage_cluster_public_key": "ssh-rsa AAAA...your-public-key-content...",
        "bastion_security_group_id": "r006-xxxx-xxxx-xxxx-xxxx",
        "dns_service_instance_id": "my-dns-service",
        "vpc_storage_cluster_dns_zone_id": "zone-id-for-storage",
        "using_jumphost_connection": true,
        "airgap": false
    }
    ```

    **Example 2: Compute-only Cluster**

    ```json
    {
        "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
        "vpc_region": "us-south",
        "vpc_availability_zones": ["us-south-1"],
        "resource_prefix": "spectrum-scale",
        "resource_group_id": "default",
        "vpc_id": "r006-xxxx-xxxx-xxxx-xxxx",
        "vpc_compute_cluster_private_subnets": ["r006-xxxx-xxxx-xxxx-xxxx"],
        "cluster_type": "Compute-only",
        "total_compute_cluster_instances": 3,
        "compute_cluster_instance_type": "cx2-4x8",
        "compute_cluster_image_id": "r006-xxxx-xxxx-xxxx",
        "compute_cluster_public_key": "ssh-rsa AAAA...your-public-key-content...",
        "bastion_security_group_id": "r006-xxxx-xxxx-xxxx-xxxx",
        "dns_service_instance_id": "my-dns-service",
        "vpc_compute_cluster_dns_zone_id": "zone-id-for-compute",
        "using_jumphost_connection": true,
        "airgap": false
    }
    ```

    **Example 3: Combined Storage and Compute Cluster**

    ```json
    {
        "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
        "vpc_region": "us-south",
        "vpc_availability_zones": ["us-south-1"],
        "resource_prefix": "spectrum-scale",
        "resource_group_id": "default",
        "vpc_id": "r006-xxxx-xxxx-xxxx-xxxx",
        "vpc_storage_cluster_private_subnets": ["r006-xxxx-xxxx-xxxx-xxxx"],
        "vpc_compute_cluster_private_subnets": ["r006-xxxx-xxxx-xxxx-xxxx"],
        "cluster_type": "Combined-compute-storage",
        "total_storage_cluster_instances": 4,
        "total_compute_cluster_instances": 3,
        "storage_cluster_instance_type": "bx2d-8x32",
        "compute_cluster_instance_type": "cx2-4x8",
        "storage_cluster_image_id": "r006-xxxx-xxxx-xxxx",
        "compute_cluster_image_id": "r006-xxxx-xxxx-xxxx",
        "storage_cluster_public_key": "ssh-rsa AAAA...your-public-key-content...",
        "compute_cluster_public_key": "ssh-rsa AAAA...your-public-key-content...",
        "bastion_security_group_id": "r006-xxxx-xxxx-xxxx-xxxx",
        "dns_service_instance_id": "my-dns-service",
        "vpc_storage_cluster_dns_zone_id": "zone-id-for-storage",
        "vpc_compute_cluster_dns_zone_id": "zone-id-for-compute",
        "using_jumphost_connection": true,
        "airgap": false
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 2 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_airgap"></a> [airgap](#input_airgap) | If true, instance iam profile, git utils which need internet access will be skipped. | `bool` |
| <a name="input_bastion_security_group_id"></a> [bastion_security_group_id](#input_bastion_security_group_id) | Bastion security group ID. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_orchestrator_server"></a> [orchestrator_server](#input_orchestrator_server) | IP or hostname of the scale-orchestrator server, e.g. 10.x.x.x. Injected as http://<value>:57096 into /etc/scale-agent/config.yaml on each VM at first boot. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | IBM Cloud resource group ID. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_storage_cluster_image_id"></a> [storage_cluster_image_id](#input_storage_cluster_image_id) | Image ID to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | Instance type to use for provisioning the storage cluster instances. | `string` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of virtual server instances to be launched for storage cluster. | `number` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where resources will be provisioned. Example: us-south. | `string` |
| <a name="input_boot_disk_type"></a> [boot_disk_type](#input_boot_disk_type) | Boot disk type for all cluster instances. | `string` |
| <a name="input_ces_ip_addresses"></a> [ces_ip_addresses](#input_ces_ip_addresses) | CES IP addresses (length must be equal to number of protocol nodes). | `list(string)` |
| <a name="input_client_ip_ranges"></a> [client_ip_ranges](#input_client_ip_ranges) | List of client IP/CIDR ranges for direct connection access. | `list(string)` |
| <a name="input_client_security_group_id"></a> [client_security_group_id](#input_client_security_group_id) | Client security group ID for cloud connection access (same VPC or peered VPC). | `string` |
| <a name="input_compute_cluster_image_id"></a> [compute_cluster_image_id](#input_compute_cluster_image_id) | Image ID to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_public_key"></a> [compute_cluster_public_key](#input_compute_cluster_public_key) | SSH public key content for the compute cluster. Required when total_compute_cluster_instances > 0. | `string` |
| <a name="input_dns_service_instance_id"></a> [dns_service_instance_id](#input_dns_service_instance_id) | IBM Cloud DNS Service Instance Id | `string` |
| <a name="input_enable_placement_group"></a> [enable_placement_group](#input_enable_placement_group) | If true, an IBM Cloud placement group will be created for single-AZ deployments and attached to storage instances. | `bool` |
| <a name="input_gateway_instance_type"></a> [gateway_instance_type](#input_gateway_instance_type) | Instance type to use for provisioning the gateway instances. | `string` |
| <a name="input_placement_group_strategy"></a> [placement_group_strategy](#input_placement_group_strategy) | Placement group strategy. Options: 'host_spread' (place on different compute hosts), 'power_spread' (place on compute hosts that use different power sources). | `string` |
| <a name="input_protocol_instance_type"></a> [protocol_instance_type](#input_protocol_instance_type) | Instance type to use for provisioning the protocol instances. | `string` |
| <a name="input_root_device_kms_key_id"></a> [root_device_kms_key_id](#input_root_device_kms_key_id) | GUID of the Key Protect/HPCS instance to be used when encrypting the root volume. | `string` |
| <a name="input_root_device_kms_key_name"></a> [root_device_kms_key_name](#input_root_device_kms_key_name) | Name of the root/standard key to be used when encrypting the root volume. | `string` |
| <a name="input_storage_cluster_public_key"></a> [storage_cluster_public_key](#input_storage_cluster_public_key) | SSH public key content for the storage cluster. Required when total_storage_cluster_instances > 0. | `string` |
| <a name="input_storage_cluster_tiebreaker_instance_type"></a> [storage_cluster_tiebreaker_instance_type](#input_storage_cluster_tiebreaker_instance_type) | Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration). | `string` |
| <a name="input_storage_volume_iops"></a> [storage_volume_iops](#input_storage_volume_iops) | IOPS for unattached storage volumes. | `number` |
| <a name="input_storage_volume_profile"></a> [storage_volume_profile](#input_storage_volume_profile) | IBM Cloud volume profile for unattached storage volumes. | `string` |
| <a name="input_storage_volume_size"></a> [storage_volume_size](#input_storage_volume_size) | Size of each unattached storage volume in GB. | `number` |
| <a name="input_tags"></a> [tags](#input_tags) | List of tags to attach to resources in format key:value | `list(string)` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of virtual server instances to be launched for compute cluster. | `number` |
| <a name="input_total_gateway_instances"></a> [total_gateway_instances](#input_total_gateway_instances) | Number of virtual server instances to be launched for gateway nodes. | `number` |
| <a name="input_total_protocol_instances"></a> [total_protocol_instances](#input_total_protocol_instances) | Number of virtual server instances to be launched for protocol nodes. | `number` |
| <a name="input_total_storage_volumes"></a> [total_storage_volumes](#input_total_storage_volumes) | Number of unattached storage volumes to provision. | `number` |
| <a name="input_using_cloud_connection"></a> [using_cloud_connection](#input_using_cloud_connection) | Enable communication from a cloud VM to the VPC. Supports: (1) Same VPC with different security group, (2) Different VPC via VPC peering. Requires `client_security_group_id` - the deployment VM's security group will be added to the allowed ingress list of scale cluster security groups. | `bool` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | Enable communication from on-premise VM to VPC via VPN or Direct Connect. Requires `client_ip_ranges` - the on-premise client IPs/CIDRs will be added to the allowed ingress list of scale cluster security groups. | `bool` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | Enable communication from on-premise VM to VPC via bastion/jumphost. Requires `bastion_user`, `bastion_instance_public_ip`, `bastion_security_group_id`, `bastion_ssh_private_key` - the bastion security group will be added to the allowed ingress list of scale cluster security groups. | `bool` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | DNS domain name for compute cluster. | `string` |
| <a name="input_vpc_compute_cluster_dns_zone_id"></a> [vpc_compute_cluster_dns_zone_id](#input_vpc_compute_cluster_dns_zone_id) | DNS zone ID for compute cluster. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | DNS domain name for storage cluster. | `string` |
| <a name="input_vpc_storage_cluster_dns_zone_id"></a> [vpc_storage_cluster_dns_zone_id](#input_vpc_storage_cluster_dns_zone_id) | DNS zone ID for storage cluster. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_airgap"></a> [airgap](#output_airgap) | Air gap environment |
| <a name="output_ces_private_ips"></a> [ces_private_ips](#output_ces_private_ips) | CES/Protocol ENI (secondary private) ips. |
| <a name="output_compute_cluster_instance_details"></a> [compute_cluster_instance_details](#output_compute_cluster_instance_details) | Compute cluster instance details (map of id, private_ip, dns) |
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_compute_cluster_security_group_id"></a> [compute_cluster_security_group_id](#output_compute_cluster_security_group_id) | Compute cluster security group id. |
| <a name="output_gateway_instance_details"></a> [gateway_instance_details](#output_gateway_instance_details) | Gateway instance details (map of id, private_ip, dns) |
| <a name="output_placement_group_id"></a> [placement_group_id](#output_placement_group_id) | IBM Cloud placement group id. |
| <a name="output_protocol_cluster_security_group_id"></a> [protocol_cluster_security_group_id](#output_protocol_cluster_security_group_id) | Protocol cluster security group id. |
| <a name="output_protocol_instance_details"></a> [protocol_instance_details](#output_protocol_instance_details) | Protocol instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_dec_instance_details"></a> [storage_cluster_dec_instance_details](#output_storage_cluster_dec_instance_details) | Storage cluster desc instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage_cluster_desc_instance_ids](#output_storage_cluster_desc_instance_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage_cluster_desc_instance_private_ips](#output_storage_cluster_desc_instance_private_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_details"></a> [storage_cluster_instance_details](#output_storage_cluster_instance_details) | Protocol instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_security_group_id"></a> [storage_cluster_security_group_id](#output_storage_cluster_security_group_id) | Storage cluster security group id. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
| <a name="output_storage_instance_ips_with_disk_mapping"></a> [storage_instance_ips_with_disk_mapping](#output_storage_instance_ips_with_disk_mapping) | n/a |
| <a name="output_storage_vm_zone_map"></a> [storage_vm_zone_map](#output_storage_vm_zone_map) | n/a |
<!-- END_TF_DOCS -->
