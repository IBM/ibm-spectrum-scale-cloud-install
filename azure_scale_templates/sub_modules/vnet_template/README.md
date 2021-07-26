### Configure Azure VNET

Below steps will provision Azure VNET required for IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/vnet_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/vnet_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```json
    {
        "client_id": "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4",
        "client_secret": "0e760437-bf34-4aad-9f8d-870be799c55d",
        "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47",
        "subscription_id": "e652d8de-aea2-4177-a0f1-7117adc604ee",
        "vnet_location": "eastus",
        "resource_group_name": "spectrum-scale"
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 2.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_client_id"></a> [client_id](#input_client_id) | The Active Directory service principal associated with your account. | `string` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | The password or secret for your service principal. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_vnet_location"></a> [vnet_location](#input_vnet_location) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_vnet_address_space"></a> [vnet_address_space](#input_vnet_address_space) | The address space that is used by the virtual network. | `list(string)` |
| <a name="input_vnet_compute_cluster_dns_domain"></a> [vnet_compute_cluster_dns_domain](#input_vnet_compute_cluster_dns_domain) | Azure DNS domain name to be used for compute cluster. | `string` |
| <a name="input_vnet_compute_cluster_private_subnets_address_space"></a> [vnet_compute_cluster_private_subnets_address_space](#input_vnet_compute_cluster_private_subnets_address_space) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vnet_create_separate_subnets"></a> [vnet_create_separate_subnets](#input_vnet_create_separate_subnets) | Flag to select if separate private subnet to be created for compute cluster. | `bool` |
| <a name="input_vnet_public_subnets_address_space"></a> [vnet_public_subnets_address_space](#input_vnet_public_subnets_address_space) | List of address prefix to use for public subnets. | `list(string)` |
| <a name="input_vnet_storage_cluster_dns_domain"></a> [vnet_storage_cluster_dns_domain](#input_vnet_storage_cluster_dns_domain) | Azure DNS domain name to be used for storage cluster. | `string` |
| <a name="input_vnet_storage_cluster_private_subnets_address_space"></a> [vnet_storage_cluster_private_subnets_address_space](#input_vnet_storage_cluster_private_subnets_address_space) | List of address prefix to use for storage cluster private subnets. | `list(string)` |
| <a name="input_vnet_tags"></a> [vnet_tags](#input_vnet_tags) | The tags to associate with your network and subnets. | `map(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource_group_name](#output_resource_group_name) | New resource group name |
| <a name="output_vnet_compute_cluster_private_subnets"></a> [vnet_compute_cluster_private_subnets](#output_vnet_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vnet_compute_private_dns_zone_name"></a> [vnet_compute_private_dns_zone_name](#output_vnet_compute_private_dns_zone_name) | Compute cluster private DNS zone name. |
| <a name="output_vnet_id"></a> [vnet_id](#output_vnet_id) | The ID of the VNET. |
| <a name="output_vnet_public_subnets"></a> [vnet_public_subnets](#output_vnet_public_subnets) | List of IDs of public subnets. |
| <a name="output_vnet_storage_cluster_private_subnets"></a> [vnet_storage_cluster_private_subnets](#output_vnet_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
| <a name="output_vnet_storage_private_dns_zone_name"></a> [vnet_storage_private_dns_zone_name](#output_vnet_storage_private_dns_zone_name) | Storage cluster private DNS zone name. |
<!-- END_TF_DOCS -->
