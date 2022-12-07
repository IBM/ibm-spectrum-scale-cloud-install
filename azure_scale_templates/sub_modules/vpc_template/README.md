### Configure Azure VPC

Below steps will provision Azure VPC required for IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/vpc_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/vpc_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```json
    {
        "client_id": "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4",
        "client_secret": "0e760437-bf34-4aad-9f8d-870be799c55d",
        "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47",
        "subscription_id": "e652d8de-aea2-4177-a0f1-7117adc604ee",
        "vpc_location": "eastus",
        "resource_group_name": "spectrum-scale"
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 3.34 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_vpc_location"></a> [vpc_location](#input_vpc_location) | The location/region of the vpc to create. Examples are East US, West US, etc. | `string` |
| <a name="input_comp_dns_domain"></a> [comp_dns_domain](#input_comp_dns_domain) | Azure DNS domain name to be used for compute cluster. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_storage_account_name"></a> [storage_account_name](#input_storage_account_name) | Name for the storage account. | `string` |
| <a name="input_strg_dns_domain"></a> [strg_dns_domain](#input_strg_dns_domain) | Azure DNS domain name to be used for storage cluster. | `string` |
| <a name="input_vpc_address_space"></a> [vpc_address_space](#input_vpc_address_space) | The CIDR block for the VPC. | `list(string)` |
| <a name="input_vpc_comp_priv_subnet_address_spaces"></a> [vpc_comp_priv_subnet_address_spaces](#input_vpc_comp_priv_subnet_address_spaces) | List of cidr_blocks for compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_public_subnet_address_spaces"></a> [vpc_public_subnet_address_spaces](#input_vpc_public_subnet_address_spaces) | List of cidr_blocks of public subnets. | `list(string)` |
| <a name="input_vpc_strg_priv_subnet_address_spaces"></a> [vpc_strg_priv_subnet_address_spaces](#input_vpc_strg_priv_subnet_address_spaces) | List of cidr_blocks for storage cluster private subnets. | `list(string)` |
| <a name="input_vpc_tags"></a> [vpc_tags](#input_vpc_tags) | The tags to associate with your network and subnets. | `map(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_comp_priv_dns_zone_name"></a> [comp_priv_dns_zone_name](#output_comp_priv_dns_zone_name) | n/a |
| <a name="output_private_endpoint_dns_name"></a> [private_endpoint_dns_name](#output_private_endpoint_dns_name) | n/a |
| <a name="output_resource_group_name"></a> [resource_group_name](#output_resource_group_name) | New resource group name |
| <a name="output_strg_priv_dns_zone_name"></a> [strg_priv_dns_zone_name](#output_strg_priv_dns_zone_name) | n/a |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the vpc. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
