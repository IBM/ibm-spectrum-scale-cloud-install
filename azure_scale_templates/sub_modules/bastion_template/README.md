### Configure Azure Bastion Service

Below steps will provision Azure Bastion service required for IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/bastion_template`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/bastion_template/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:
    ```jsonc
    {
        "client_id": "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4",
        "client_secret": "0e760437-bf34-4aad-9f8d-870be799c55d",
        "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47",
        "subscription_id": "e652d8de-aea2-4177-a0f1-7117adc604ee",
        "vnet_location": "eastus",
        "resource_group_name": "spectrum-scale-rg",
        "vnet_public_subnet_id": "/subscriptions/e652d8de-aea2-4177-a0f1-7117adc604ee/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vnet/subnets/AzureBastionSubnet"
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
| <a name="input_vnet_public_subnet_id"></a> [vnet_public_subnet_id](#input_vnet_public_subnet_id) | Public subnet id to be used for Bastion host. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_fqdn"></a> [bastion_instance_fqdn](#output_bastion_instance_fqdn) | Bastion instance fqdn. |
| <a name="output_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#output_bastion_instance_public_ip) | Bastion instance public ip address. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group id. |
<!-- END_TF_DOCS -->
