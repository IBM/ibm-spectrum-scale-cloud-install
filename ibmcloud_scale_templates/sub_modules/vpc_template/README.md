### Configure IBM Cloud VPC

Below steps will provision IBM Cloud VPC required for IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/sub_modules/vpc_template`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/vpc_template/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones"=["us-south-1", "us-south-2", "us-south-3"]` |
    | --- |

    Minimal Example:
    ```json
    {
        "vpc_region": "us-south",
        "resource_group_id": "5c5d77eb1c3f4cd4b158dbbf62b5841c",
        "vpc_availability_zones": ["us-south-1"]
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | IBM Cloud resource group id. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | IBM Cloud VPC address prefixes. | `list(string)` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | IBM Cloud DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vpc_create_separate_subnets"></a> [vpc_create_separate_subnets](#input_vpc_create_separate_subnets) | Flag to select if separate private subnet to be created for compute cluster. | `bool` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | IBM Cloud DNS domain name to be used for storage cluster. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_dns_service_id"></a> [vpc_compute_cluster_dns_service_id](#output_vpc_compute_cluster_dns_service_id) | IBM Cloud DNS compute cluster resource instance server ID. |
| <a name="output_vpc_compute_cluster_dns_zone_id"></a> [vpc_compute_cluster_dns_zone_id](#output_vpc_compute_cluster_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_storage_cluster_dns_service_id"></a> [vpc_storage_cluster_dns_service_id](#output_vpc_storage_cluster_dns_service_id) | IBM Cloud DNS storage cluster resource instance server ID. |
| <a name="output_vpc_storage_cluster_dns_zone_id"></a> [vpc_storage_cluster_dns_zone_id](#output_vpc_storage_cluster_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
