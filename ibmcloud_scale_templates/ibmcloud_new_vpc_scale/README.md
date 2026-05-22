# New VPC Template

The following steps will provision IBM Cloud resources (*new vpc, bastion/VPC-peering, compute and storage instances*) and configures IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/ibmcloud_new_vpc_scale/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/ibmcloud_new_vpc_scale/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones": ["us-south-1", "us-south-2", "us-south-3"]` |
    | --- |

    Minimal Example (create storage-only cluster):

    ```jsonc
    {
        "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
        "resource_group": null,
        "resource_prefix": "ibm-storage-scale",
        "vpc_region": "us-south",
        "vpc_availability_zones": [
            "us-south-1"
        ],
        "vpc_cidr_block": "10.241.0.0/18",
        "vpc_storage_cluster_private_subnets_cidr_blocks": [
            "10.241.1.0/24"
        ],
        "vpc_storage_cluster_dns_domain": "strgscale.com",
        "enable_bastion": true,
        "bastion_public_key_path": "/path/to/your/ssh/public_key.pub",
        "bastion_osimage_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "bastion_vsi_profile": "cx2-2x4",
        "remote_cidr_blocks": [
            "YOUR_IP_ADDRESS/32"
        ],
        "total_storage_cluster_instances": 4,
        "storage_cluster_public_key_path": "/path/to/your/ssh/public_key.pub",
        "storage_vsi_osimage_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "storage_vsi_profile": "bx2d-8x32",
        "total_storage_volumes": 4,
        "cluster_type": "Storage-only",
        "enable_placement_group": true,
        "tags": ["project:storage-scale", "owner:terraform"]
    }
    ```

    Minimal Example (with VPC peering and direct connection):

    ```jsonc
    {
        "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
        "resource_group": null,
        "resource_prefix": "ibm-storage-scale",
        "vpc_region": "us-south",
        "vpc_availability_zones": [
            "us-south-1"
        ],
        "vpc_cidr_block": "10.241.0.0/18",
        "vpc_storage_cluster_private_subnets_cidr_blocks": [
            "10.241.1.0/24"
        ],
        "vpc_storage_cluster_dns_domain": "strgscale.com",
        "enable_bastion": false,
        "enable_transit_gateway": true,
        "peer_vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:VPC_ID",
        "using_direct_connection": true,
        "client_ip_ranges": [
            "YOUR_NETWORK_CIDR"
        ],
        "total_storage_cluster_instances": 4,
        "storage_cluster_public_key_path": "/path/to/your/ssh/public_key.pub",
        "storage_vsi_osimage_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "storage_vsi_profile": "bx2d-8x32",
        "total_storage_volumes": 4,
        "cluster_type": "Storage-only",
        "enable_placement_group": true,
        "tags": ["project:storage-scale", "owner:terraform"]
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
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | IBM Cloud API key for authentication. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | List of availability zone names or IDs within the selected region for multi-zone deployment. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where VPC and all resources will be deployed (e.g., us-east, us-south, eu-de). | `string` |
| <a name="input_bastion_osimage_id"></a> [bastion_osimage_id](#input_bastion_osimage_id) | IBM Cloud OS image ID for bastion virtual server instance. Use 'ibmcloud is images' to find available image IDs in your region. | `string` |
| <a name="input_bastion_public_key_path"></a> [bastion_public_key_path](#input_bastion_public_key_path) | Path to the SSH public key file for bastion host access. Required only if enable_bastion is true. | `string` |
| <a name="input_bastion_vsi_profile"></a> [bastion_vsi_profile](#input_bastion_vsi_profile) | IBM Cloud VSI profile (instance type) for bastion host. | `string` |
| <a name="input_boot_disk_type"></a> [boot_disk_type](#input_boot_disk_type) | Boot disk profile/type for all cluster instances (e.g., general-purpose, 5iops-tier, 10iops-tier). | `string` |
| <a name="input_ces_ip_addresses"></a> [ces_ip_addresses](#input_ces_ip_addresses) | List of CES (Cluster Export Services) IP addresses for protocol nodes. Length must equal total_protocol_instances. | `list(string)` |
| <a name="input_client_ip_ranges"></a> [client_ip_ranges](#input_client_ip_ranges) | List of client IP/CIDR ranges for direct connection access via VPN or direct connection. | `list(string)` |
| <a name="input_client_security_group_id"></a> [client_security_group_id](#input_client_security_group_id) | Client security group ID for cloud connection access from another VPC. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Options: 'Storage-only', 'Compute-only', 'Combined-compute-storage'. | `string` |
| <a name="input_compute_cluster_public_key_path"></a> [compute_cluster_public_key_path](#input_compute_cluster_public_key_path) | The ssh public key to be created used to launch the compute cluster. Required only when total_compute_cluster_instances > 0. | `string` |
| <a name="input_compute_vsi_osimage_id"></a> [compute_vsi_osimage_id](#input_compute_vsi_osimage_id) | IBM Cloud OS image ID for compute cluster virtual server instances. Format: r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx. Use 'ibmcloud is images' to find available image IDs in your region. | `string` |
| <a name="input_compute_vsi_profile"></a> [compute_vsi_profile](#input_compute_vsi_profile) | IBM Cloud VSI profile (instance type) for compute cluster nodes. | `string` |
| <a name="input_create_dns_zone"></a> [create_dns_zone](#input_create_dns_zone) | Flag to create new private DNS zones. Set to false to reuse existing DNS zones. | `bool` |
| <a name="input_dns_service_instance_id"></a> [dns_service_instance_id](#input_dns_service_instance_id) | GUID of the IBM Cloud DNS Services instance for DNS record management. If not provided, a new DNS service instance will be created. | `string` |
| <a name="input_enable_bastion"></a> [enable_bastion](#input_enable_bastion) | Flag to enable or disable bastion host deployment. Set to false to skip bastion creation. | `bool` |
| <a name="input_enable_placement_group"></a> [enable_placement_group](#input_enable_placement_group) | Enable IBM Cloud placement group to distribute instances in single-AZ deployments. | `bool` |
| <a name="input_enable_transit_gateway"></a> [enable_transit_gateway](#input_enable_transit_gateway) | Flag to enable Transit Gateway connection between the newly created VPC and an existing user-provided VPC. Transit Gateway enables connectivity across VPCs in the same or different regions. | `bool` |
| <a name="input_gateway_vsi_profile"></a> [gateway_vsi_profile](#input_gateway_vsi_profile) | IBM Cloud VSI profile (instance type) for gateway cluster nodes. | `string` |
| <a name="input_peer_vpc_crn"></a> [peer_vpc_crn](#input_peer_vpc_crn) | CRN of the existing VPC to connect via Transit Gateway. Required only if enable_transit_gateway is true and creating a new Transit Gateway. | `string` |
| <a name="input_placement_group_strategy"></a> [placement_group_strategy](#input_placement_group_strategy) | Placement group strategy. Options: 'host_spread' (place on different compute hosts), 'power_spread' (place on compute hosts that use different power sources). Note: Strategy is required and forces new resource if changed. | `string` |
| <a name="input_protocol_vsi_profile"></a> [protocol_vsi_profile](#input_protocol_vsi_profile) | IBM Cloud VSI profile (instance type) for protocol cluster nodes. | `string` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDR blocks allowed to access the bastion host via SSH. | `list(string)` |
| <a name="input_resource_group"></a> [resource_group](#input_resource_group) | Name of an existing IBM Cloud resource group. If not provided, a new resource group will be created using the resource_prefix. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix added to all resource names for identification and organization. | `string` |
| <a name="input_root_device_kms_key_id"></a> [root_device_kms_key_id](#input_root_device_kms_key_id) | GUID of the IBM Key Protect or Hyper Protect Crypto Services (HPCS) instance for encrypting root volumes. If not provided, root volumes will not be encrypted. | `string` |
| <a name="input_root_device_kms_key_name"></a> [root_device_kms_key_name](#input_root_device_kms_key_name) | Name of the root key or standard key in Key Protect/HPCS to use for root volume encryption. Required only if root_device_kms_key_id is provided. | `string` |
| <a name="input_storage_cluster_public_key_path"></a> [storage_cluster_public_key_path](#input_storage_cluster_public_key_path) | The ssh public key to be created used to launch the storage cluster. Required only when total_storage_cluster_instances > 0. | `string` |
| <a name="input_storage_cluster_tiebreaker_instance_type"></a> [storage_cluster_tiebreaker_instance_type](#input_storage_cluster_tiebreaker_instance_type) | IBM Cloud VSI profile (instance type) for tie-breaker instance in Multi-AZ deployments. Set to null for single-zone deployments or to use the same profile as storage nodes. | `string` |
| <a name="input_storage_volume_iops"></a> [storage_volume_iops](#input_storage_volume_iops) | IOPS for unattached storage volumes. Only applicable for custom IOPS profiles. | `number` |
| <a name="input_storage_volume_profile"></a> [storage_volume_profile](#input_storage_volume_profile) | IBM Cloud volume profile for unattached storage volumes (e.g., general-purpose, 5iops-tier, 10iops-tier, custom). | `string` |
| <a name="input_storage_volume_size"></a> [storage_volume_size](#input_storage_volume_size) | Size of each unattached storage volume in GB. | `number` |
| <a name="input_storage_vsi_osimage_id"></a> [storage_vsi_osimage_id](#input_storage_vsi_osimage_id) | IBM Cloud OS image ID for storage cluster virtual server instances. Format: r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx. Use 'ibmcloud is images' to find available image IDs in your region. | `string` |
| <a name="input_storage_vsi_profile"></a> [storage_vsi_profile](#input_storage_vsi_profile) | IBM Cloud VSI profile (instance type) for storage cluster nodes. | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | List of tags to be attached to all resources created by this module. | `list(string)` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Total number of virtual server instances to deploy for the compute cluster. Set to 0 for storage-only deployments. | `number` |
| <a name="input_total_gateway_instances"></a> [total_gateway_instances](#input_total_gateway_instances) | Total number of virtual server instances to deploy for gateway nodes. Set to 0 to skip gateway node deployment. | `number` |
| <a name="input_total_protocol_instances"></a> [total_protocol_instances](#input_total_protocol_instances) | Total number of virtual server instances to deploy for protocol nodes (CES/NFS). Set to 0 to skip protocol node deployment. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Total number of virtual server instances to deploy for the storage cluster. Set to 0 to skip storage cluster deployment. | `number` |
| <a name="input_total_storage_volumes"></a> [total_storage_volumes](#input_total_storage_volumes) | Total number of unattached storage volumes to provision. These volumes will be created but not attached to any instances. | `number` |
| <a name="input_transit_gateway_global_routing"></a> [transit_gateway_global_routing](#input_transit_gateway_global_routing) | Enable global routing for Transit Gateway to allow connections across different regions. Set to true if peer VPC is in a different region. | `bool` |
| <a name="input_transit_gateway_id"></a> [transit_gateway_id](#input_transit_gateway_id) | ID of an existing Transit Gateway to attach the new VPC to. If not provided and enable_transit_gateway is true, a new Transit Gateway will be created. | `string` |
| <a name="input_transit_gateway_name"></a> [transit_gateway_name](#input_transit_gateway_name) | Name for the new Transit Gateway. Used only if enable_transit_gateway is true and transit_gateway_id is not provided. Defaults to '<resource_prefix>-tgw'. | `string` |
| <a name="input_using_cloud_connection"></a> [using_cloud_connection](#input_using_cloud_connection) | Enable communication from a cloud VM to the VPC. Supports: (1) Same VPC with different security group, (2) Different VPC via VPC peering. Requires client_security_group_id. | `bool` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | Enable communication from on-premise VM to VPC via VPN or Direct Connect. Requires client_ip_ranges. | `bool` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | Enable communication from on-premise VM to VPC via bastion/jumphost. When enable_bastion=true, this is automatically enabled unless explicitly set to false. Requires bastion_security_group_id (either from module.bastion or external). | `bool` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | CIDR block for VPC that will be automatically subdivided into address prefixes for each availability zone. | `string` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | DNS domain name for compute cluster nodes. Required only if deploying compute nodes. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of CIDR blocks for compute cluster private subnets. Set to empty array [] to use storage cluster subnets or skip compute subnet creation. | `list(string)` |
| <a name="input_vpc_protocol_cluster_dns_domain"></a> [vpc_protocol_cluster_dns_domain](#input_vpc_protocol_cluster_dns_domain) | DNS domain name for protocol cluster nodes. Required only if deploying protocol nodes. | `string` |
| <a name="input_vpc_protocol_private_subnets_cidr_blocks"></a> [vpc_protocol_private_subnets_cidr_blocks](#input_vpc_protocol_private_subnets_cidr_blocks) | List of CIDR blocks for protocol node private subnets, one per availability zone. Required only if deploying protocol nodes. Set to empty array [] to skip protocol subnet creation. | `list(string)` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of CIDR blocks for public subnets, one per availability zone. Set to empty array [] if no public subnets are needed. | `list(string)` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | DNS domain name for storage cluster nodes. Required when deploying storage nodes. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of CIDR blocks for storage cluster private subnets, one per availability zone. | `list(string)` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_instance_crn"></a> [bastion_instance_crn](#output_bastion_instance_crn) | Bastion instance autoscaling group CRN. |
| <a name="output_bastion_instance_id"></a> [bastion_instance_id](#output_bastion_instance_id) | Bastion instance autoscaling group ID. |
| <a name="output_bastion_public_ip_addresses"></a> [bastion_public_ip_addresses](#output_bastion_public_ip_addresses) | List of public IP addresses for bastion instances. Use these IPs to SSH into the bastion. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group ID. |
| <a name="output_compute_cluster_instance_ids"></a> [compute_cluster_instance_ids](#output_compute_cluster_instance_ids) | Compute cluster instance ids. |
| <a name="output_compute_cluster_instance_private_ips"></a> [compute_cluster_instance_private_ips](#output_compute_cluster_instance_private_ips) | Private IP address of compute cluster instances. |
| <a name="output_dns_service_instance_crn"></a> [dns_service_instance_crn](#output_dns_service_instance_crn) | IBM Cloud DNS Service Instance CRN (only available if newly created). |
| <a name="output_dns_service_instance_id"></a> [dns_service_instance_id](#output_dns_service_instance_id) | IBM Cloud DNS Service Instance ID. |
| <a name="output_new_vpc_connection_id"></a> [new_vpc_connection_id](#output_new_vpc_connection_id) | ID of the Transit Gateway connection for the newly created VPC. |
| <a name="output_nodes"></a> [nodes](#output_nodes) | Node inventory for the scale-operator cluster controller. |
| <a name="output_peer_vpc_connection_id"></a> [peer_vpc_connection_id](#output_peer_vpc_connection_id) | ID of the Transit Gateway connection for the peer VPC. |
| <a name="output_placement_group_id"></a> [placement_group_id](#output_placement_group_id) | IBM Cloud placement group id for single-AZ deployments. |
| <a name="output_resource_group_id"></a> [resource_group_id](#output_resource_group_id) | The ID of the resource group used for VPC resources. |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_desc_instance_ids"></a> [storage_cluster_desc_instance_ids](#output_storage_cluster_desc_instance_ids) | Storage cluster desc instance id. |
| <a name="output_storage_cluster_desc_instance_private_ips"></a> [storage_cluster_desc_instance_private_ips](#output_storage_cluster_desc_instance_private_ips) | Private IP address of storage cluster desc instance. |
| <a name="output_storage_cluster_instance_ids"></a> [storage_cluster_instance_ids](#output_storage_cluster_instance_ids) | Storage cluster instance ids. |
| <a name="output_storage_cluster_instance_private_ips"></a> [storage_cluster_instance_private_ips](#output_storage_cluster_instance_private_ips) | Private IP address of storage cluster instances. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
| <a name="output_transit_gateway_crn"></a> [transit_gateway_crn](#output_transit_gateway_crn) | CRN of the Transit Gateway used for VPC connectivity. |
| <a name="output_transit_gateway_id"></a> [transit_gateway_id](#output_transit_gateway_id) | ID of the Transit Gateway used for VPC connectivity. |
| <a name="output_transit_gateway_name"></a> [transit_gateway_name](#output_transit_gateway_name) | Name of the Transit Gateway. |
| <a name="output_transit_gateway_status"></a> [transit_gateway_status](#output_transit_gateway_status) | Status of the Transit Gateway. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_compute_cluster_private_subnets_crn"></a> [vpc_compute_cluster_private_subnets_crn](#output_vpc_compute_cluster_private_subnets_crn) | List of CRNs of compute cluster private subnets. |
| <a name="output_vpc_compute_cluster_private_subnets_name"></a> [vpc_compute_cluster_private_subnets_name](#output_vpc_compute_cluster_private_subnets_name) | List of names of compute cluster private subnets. |
| <a name="output_vpc_compute_dns_zone_id"></a> [vpc_compute_dns_zone_id](#output_vpc_compute_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_crn"></a> [vpc_crn](#output_vpc_crn) | The CRN of the VPC. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output_vpc_name) | The name of the VPC. |
| <a name="output_vpc_protocol_dns_zone_id"></a> [vpc_protocol_dns_zone_id](#output_vpc_protocol_dns_zone_id) | IBM Cloud DNS protocol cluster zone ID. |
| <a name="output_vpc_protocol_private_subnets"></a> [vpc_protocol_private_subnets](#output_vpc_protocol_private_subnets) | List of IDs of protocol cluster private subnets. |
| <a name="output_vpc_protocol_private_subnets_crn"></a> [vpc_protocol_private_subnets_crn](#output_vpc_protocol_private_subnets_crn) | List of CRNs of protocol cluster private subnets. |
| <a name="output_vpc_protocol_private_subnets_name"></a> [vpc_protocol_private_subnets_name](#output_vpc_protocol_private_subnets_name) | List of names of protocol cluster private subnets. |
| <a name="output_vpc_public_gateway_ids"></a> [vpc_public_gateway_ids](#output_vpc_public_gateway_ids) | List of IDs of public gateways. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_public_subnets_crn"></a> [vpc_public_subnets_crn](#output_vpc_public_subnets_crn) | List of CRNs of public subnets. |
| <a name="output_vpc_public_subnets_name"></a> [vpc_public_subnets_name](#output_vpc_public_subnets_name) | List of names of public subnets. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
| <a name="output_vpc_storage_cluster_private_subnets_crn"></a> [vpc_storage_cluster_private_subnets_crn](#output_vpc_storage_cluster_private_subnets_crn) | List of CRNs of storage cluster private subnets. |
| <a name="output_vpc_storage_cluster_private_subnets_name"></a> [vpc_storage_cluster_private_subnets_name](#output_vpc_storage_cluster_private_subnets_name) | List of names of storage cluster private subnets. |
| <a name="output_vpc_storage_dns_zone_id"></a> [vpc_storage_dns_zone_id](#output_vpc_storage_dns_zone_id) | IBM Cloud DNS storage cluster zone ID. |
<!-- END_TF_DOCS -->
