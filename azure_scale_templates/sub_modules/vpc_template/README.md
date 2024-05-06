### Configure Azure VPC

Below steps will provision Azure VPC required for IBM Storage Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/vpc_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/vpc_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```json
    {
        "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
        "client_secret": "xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
        "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
        "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
        "vpc_location": "eastus",
        "resource_group_name": "spectrum-scale",
        "resource_prefix": "spectrum-scale",
        "vpc_address_space": ["10.0.0.0/16"],
        "vpc_public_subnet_address_spaces": ["10.0.1.0/24"],
        "vpc_strg_priv_subnet_address_spaces": ["10.0.2.0/24"],
        "vpc_comp_priv_subnet_address_spaces": ["10.0.3.0/24"],
        "comp_dns_domain": "strgscale.com",
        "strg_dns_domain": "compscale.com",
        "storage_account_name": "spectrumscalestorageaccnt",
        "vpc_tags": {
            "Region": "eastus",
            "Evnironment": "Staging"
        }
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 3.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_client_id"></a> [client_id](#input_client_id) | The Active Directory service principal associated with your account. | `string` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | The password or secret for your service principal. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_create_resource_group"></a> [create_resource_group](#input_create_resource_group) | Create resource group. | `bool` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_vpc_bastion_service_subnets_cidr_blocks"></a> [vpc_bastion_service_subnets_cidr_blocks](#input_vpc_bastion_service_subnets_cidr_blocks) | List of CIDR blocks for azure fully managed bastion subnet. | `list(string)` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | The CIDR block for the vpc. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of cidr_blocks for compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of cidr_blocks of public subnets. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The location/region of the vpc to create. Examples are East US, West US, etc. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of cidr_blocks for storage cluster private subnets. | `list(string)` |
| <a name="input_vpc_tags"></a> [vpc_tags](#input_vpc_tags) | The tags to associate with your network and subnets. | `map(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_compute_nat_gateways"></a> [vpc_compute_nat_gateways](#output_vpc_compute_nat_gateways) | List of IDs of compute cluster nat gateway. |
| <a name="output_vpc_network_security_group_ref"></a> [vpc_network_security_group_ref](#output_vpc_network_security_group_ref) | VNet network security group id/reference. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_ref"></a> [vpc_ref](#output_vpc_ref) | The ID of the vpc. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
| <a name="output_vpc_storage_nat_gateways"></a> [vpc_storage_nat_gateways](#output_vpc_storage_nat_gateways) | List of IDs of storage cluster nat gateway. |
<!-- END_TF_DOCS -->
