# Configure Azure Bastion Service

Azure Bastion service cannot be used as jump host for provision scale cluster as it doesn't provide SSH connectivity.
Hence additional Non-Azure bastion host will be deployed to access VMs via SSH and for further scale deployment

Note : To enable Azure provided Bastion host deployment then 'azure_bastion_service : true' need to set as input parameter

Below steps will provision Bastion host required for IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/bastion_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/bastion_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```jsonc
        {
            "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
            "client_secret": "xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
            "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
            "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
            "vpc_region": "eastus",
            "vpc_ref": "spectrum-scale-vpc",
            "resource_prefix": "production01",
            "bastion_public_subnet_ids": [
                "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vpc/subnets/AzureBastionSubnet-0"
            ],
            "vpc_bastion_service_subnets_cidr_blocks": [ "10.0.5.0/24"],
            "resource_group_name": "spectrum-scaleprvn-rg",
            "user_public_key": "/root/.ssh/id_rsa.pub",
            "os_storage_account_type": "Standard_LRS",
            "remote_cidr_blocks": ["0.0.0.0/0"],
            "azure_bastion_service": false
        }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 3.37 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_client_id"></a> [client_id](#input_client_id) | The Active Directory service principal associated with your account. | `string` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | The password or secret for your service principal. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_user_public_key"></a> [user_public_key](#input_user_public_key) | The SSH public key to use to launch the image vm. | `string` |
| <a name="input_azure_bastion_service"></a> [azure_bastion_service](#input_azure_bastion_service) | Enable Azure Bastion service | `bool` |
| <a name="input_bastion_instance_type"></a> [bastion_instance_type](#input_bastion_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_bastion_login_username"></a> [bastion_login_username](#input_bastion_login_username) | Bastion default login username | `string` |
| <a name="input_bastion_public_subnet_ids"></a> [bastion_public_subnet_ids](#input_bastion_public_subnet_ids) | List of IDs of bastion subnets. | `list(string)` |
| <a name="input_image_offer"></a> [image_offer](#input_image_offer) | Specifies the offer of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_image_publisher"></a> [image_publisher](#input_image_publisher) | Specifies the publisher of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_image_sku"></a> [image_sku](#input_image_sku) | Specifies the SKU of the image used to create the storage cluster virtual machines. | `string` |
| <a name="input_image_version"></a> [image_version](#input_image_version) | Specifies the version of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_os_disk_caching"></a> [os_disk_caching](#input_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_os_storage_account_type"></a> [os_storage_account_type](#input_os_storage_account_type) | Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS). | `string` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDRs that can access to the bastion. Default : 0.0.0.0/0 | `list(string)` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_vpc_bastion_service_subnets_cidr_blocks"></a> [vpc_bastion_service_subnets_cidr_blocks](#input_vpc_bastion_service_subnets_cidr_blocks) | Azure Bastion service subnet cidr block | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id to where bastion needs to deploy. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_id"></a> [bastion_instance_id](#output_bastion_instance_id) | Bastion instance id. |
| <a name="output_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#output_bastion_instance_public_ip) | Bastion instance public ip address. |
| <a name="output_bastion_service_instance_dns_name"></a> [bastion_service_instance_dns_name](#output_bastion_service_instance_dns_name) | Bastion instance dns name. |
| <a name="output_bastion_service_instance_id"></a> [bastion_service_instance_id](#output_bastion_service_instance_id) | Bastion service instance id. |
<!-- END_TF_DOCS -->
