# Configure IBM Cloud VPC

Below steps will provision IBM Cloud VPC required for IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/sub_modules/vpc_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/vpc_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones"=["us-south-1", "us-south-2", "us-south-3"]` |
    | --- |

    Minimal Example (Multi-Az):

    ```json
    {
        "cluster_type": "Storage-only",
        "ibmcloud_api_key": "xxx",
        "create_resource_group": true,
        "resource_group_name": "test-rg",
        "resource_prefix": "test-vpc",
        "vpc_region": "us-south",
        "vpc_availability_zones": ["us-south-1", "us-south-2", "us-south-3"],
        "vpc_cidr_block": "10.0.0.0/16",
        "vpc_public_subnets_cidr_blocks": ["10.0.0.0/24", "10.0.67.0/24", "10.0.134.0/24"],
        "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.0.1.0/24", "10.0.68.0/24", "10.0.135.0/24"],
        "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.0.2.0/24", "10.0.69.0/24", "10.0.136.0/24"],
        "vpc_protocol_private_subnets_cidr_blocks": ["10.0.3.0/24", "10.0.70.0/24", "10.0.137.0/24"]
    }
    ```

    Minimal Example (Single-Az):

    ```json
    {
        "cluster_type": "Storage-only",
        "ibmcloud_api_key": "xxx",
        "create_resource_group": true,
        "resource_group_name": "test-rg",
        "resource_prefix": "test-vpc",
        "vpc_region": "us-south",
        "vpc_availability_zones": ["us-south-1"],
        "vpc_cidr_block": "10.0.0.0/16",
        "vpc_public_subnets_cidr_blocks": ["10.0.1.0/24"],
        "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.0.2.0/24"],
        "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.0.3.0/24"],
        "vpc_protocol_private_subnets_cidr_blocks": ["10.0.4.0/24"]
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 1.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_create_resource_group"></a> [create_resource_group](#input_create_resource_group) | Create resource group. | `bool` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a resource group in which the resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | The CIDR block for the VPC. Example: 10.0.0.0/16 | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vpc_protocol_private_subnets_cidr_blocks"></a> [vpc_protocol_private_subnets_cidr_blocks](#input_vpc_protocol_private_subnets_cidr_blocks) | List of cidr_blocks of protocol private subnets. | `list(string)` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of cidr_blocks of public subnets. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_name"></a> [vpc_name](#output_vpc_name) | The Name of the VPC. |
| <a name="output_vpc_protocol_private_subnets"></a> [vpc_protocol_private_subnets](#output_vpc_protocol_private_subnets) | List of IDs of protocol cluster private subnets. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_public_subnets_name"></a> [vpc_public_subnets_name](#output_vpc_public_subnets_name) | List of Name of public subnets. |
| <a name="output_vpc_ref"></a> [vpc_ref](#output_vpc_ref) | The ID of the VPC. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
