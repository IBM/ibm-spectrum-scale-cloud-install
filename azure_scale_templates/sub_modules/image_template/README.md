### Create Azure Scale Image

Below steps will create Azure Scale Image required for IBM Spectrum Scale cloud deployment.

1. Change working directory to `azure_scale_templates/sub_modules/image_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/image_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```json
        {
            "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
            "client_secret": "xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
            "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
            "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
            "vpc_region": "eastus",
            "subnet_id": "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vpc/subnets/AzureBastionSubnet-0",
            "resource_group_name": "spectrum-scale-rg",
            "resource_prefix": "imagecreator",
            "image_publisher": "RedHat",
            "image_offer": "RHEL",
            "image_sku": "8_7",
            "image_version": "latest",
            "vm_size": "Standard_A2_v2",
            "login_username": "azureuser",
            "os_disk_caching": "ReadWrite",
            "os_storage_account_type": "Standard_LRS",
            "user_public_key": "/home/user1/.ssh/id_rsa.pub",
            "user_private_key": "/home/user1/.ssh/id_rsa",
            "dns_zone": "eastus.compscale.com",
            "availability_zone": "1",
            "blob_container": "ibm-storage-scale",
            "storage_account": "storageuseraccount",
            "createimage": true,
            "skip_cli_generalize_vm": false
        }
    ```
    Note : This image_template uses az cli for deallocating and generalizing image vm , hence make sure you have 'az cli installed' . if you don't have az cli installed then 
    you need to manually deallocate/generalize vm and then set 'skip_cli_generalize_vm' : true as input parameter and re-run to create image.

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
| <a name="input_availability_zone"></a> [availability_zone](#input_availability_zone) | availability zones id in the region/location. | `number` |
| <a name="input_blob_container"></a> [blob_container](#input_blob_container) | Storage Blob container name. | `string` |
| <a name="input_client_id"></a> [client_id](#input_client_id) | n/a | `any` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | n/a | `any` |
| <a name="input_dns_zone"></a> [dns_zone](#input_dns_zone) | Image VM DNS zone. | `string` |
| <a name="input_os_storage_account_type"></a> [os_storage_account_type](#input_os_storage_account_type) | Type of storage account which should back this the internal OS disk. | `any` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_storage_account"></a> [storage_account](#input_storage_account) | Type of storage account which should back this the internal OS disk. | `string` |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id) | ID of image public subnets. | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | n/a | `any` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | n/a | `any` |
| <a name="input_user_private_key"></a> [user_private_key](#input_user_private_key) | The SSH private key to use to launch the image host. | `string` |
| <a name="input_user_public_key"></a> [user_public_key](#input_user_public_key) | The SSH public key to use to launch the image host. | `string` |
| <a name="input_createimage"></a> [createimage](#input_createimage) | Storage cluster DNS zone. | `bool` |
| <a name="input_image_offer"></a> [image_offer](#input_image_offer) | Specifies the offer of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_image_publisher"></a> [image_publisher](#input_image_publisher) | Specifies the publisher of the image used to create the virtual machines. | `string` |
| <a name="input_image_sku"></a> [image_sku](#input_image_sku) | Specifies the SKU of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_image_version"></a> [image_version](#input_image_version) | Specifies the version of the image used to create the compute cluster virtual machines. | `string` |
| <a name="input_login_username"></a> [login_username](#input_login_username) | The username of the local administrator used for the Virtual Machine. | `string` |
| <a name="input_os_disk_caching"></a> [os_disk_caching](#input_os_disk_caching) | Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite). | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_skip_cli_generalize_vm"></a> [skip_cli_generalize_vm](#input_skip_cli_generalize_vm) | Skips az cli generalize steps. | `bool` |
| <a name="input_vm_size"></a> [vm_size](#input_vm_size) | The virtual machine size. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The location/region of the vnet to create. Examples are East US, West US, etc. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_id"></a> [image_id](#output_image_id) | n/a |
| <a name="output_image_instance"></a> [image_instance](#output_image_instance) | n/a |
| <a name="output_image_name"></a> [image_name](#output_image_name) | n/a |
<!-- END_TF_DOCS -->
