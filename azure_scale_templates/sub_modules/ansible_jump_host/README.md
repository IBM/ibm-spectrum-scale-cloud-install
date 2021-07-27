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
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids) | List of IDs of cluster private subnets. | `list(string)` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_vm_name_prefix"></a> [vm_name_prefix](#input_vm_name_prefix) | Prefix is added to jump host resource that are created. | `string` |
| <a name="input_vm_public_key"></a> [vm_public_key](#input_vm_public_key) | The key pair to use to launch the jump host. | `string` |
| <a name="input_vnet_location"></a> [vnet_location](#input_vnet_location) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |
| <a name="input_image_offer"></a> [image_offer](#input_image_offer) | Specifies the offer of the image used to create the jump host virtual machine. | `string` |
| <a name="input_image_publisher"></a> [image_publisher](#input_image_publisher) | Specifies the publisher of the image used to create the jump host virtual machine. | `string` |
| <a name="input_image_sku"></a> [image_sku](#input_image_sku) | Specifies the SKU of the image used to create the jump host virtual machine. | `string` |
| <a name="input_image_version"></a> [image_version](#input_image_version) | Specifies the version of the image used to create the jump host virtual machine. | `string` |
| <a name="input_os_disk_caching"></a> [os_disk_caching](#input_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_os_storage_account_type"></a> [os_storage_account_type](#input_os_storage_account_type) | Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS). | `string` |
| <a name="input_using_direct_connection"></a> [using_direct_connection](#input_using_direct_connection) | If true, will skip the jump/bastion host configuration. | `bool` |
| <a name="input_vm_size"></a> [vm_size](#input_vm_size) | Instance type to use for provisioning the jump host virtual machine. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_jump_host_id"></a> [ansible_jump_host_id](#output_ansible_jump_host_id) | Ansible jump host instance ids. |
| <a name="output_ansible_jump_host_private_ip"></a> [ansible_jump_host_private_ip](#output_ansible_jump_host_private_ip) | Ansible jump host instance private ip address. |
| <a name="output_ansible_jump_host_public_ip"></a> [ansible_jump_host_public_ip](#output_ansible_jump_host_public_ip) | Ansible jump host instance public ip address. |
<!-- END_TF_DOCS -->
