### Configure Azure Ansible Jump Host Instance

Below steps will provision Azure Ansible Jump host instance required for IBM Spectrum Scale cloud solution.

1. Change working directory to `azure_scale_templates/sub_modules/ansible_jump_host`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/ansible_jump_host/
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
        "vm_name_prefix": "spectrum-scale",
        "vm_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDeFX5ZECXQwqTjczwuTBWYtx0joQ+2d16z/6DDGcouJ42hD0Pslx2m94jl+dyeb+1NFETBRAJ5PrVd+LjgGeEkPwb0Gu3VLRR2gmcAzMjo6FQewBFds1mBh2fi93bolUG3FHf34su6JYE5Ei7+8/0X9zGCPOKFd6bjj19cvy0kN/LUL4n9dnKWM3vnXU2Tj6aDEiwDrQk87c6nmdxyD4J1MDCab/ARK1dK7iAcy9QMod5UBQpDQu7kH054Mfc21ymIK/EkJZ9gMIuP/5q1IGw8NOlQuhIVJSKvS41EVIeY5w0kIWDIkTEKOYZiQ2br2ymWjQ/1ScsVyqsxROPhi0EP9aYJ2p0UJDEN9V1lg1SWaPN8TKhG/CAlQzGXdnc20a98cqxu5jzvj8Q7SQoAWL0ZMe1zUVJVs0XvBQItDLW6ZDpGyWTsxAcDwLqYCJubrg3aja17iFa+MCsa5esgY4GsawPtV+o9Dqx63m3joEH/fo53vNpJ6wlwaRK65hE5pkM=",
        "vm_size": "Standard_A2_v2",
        "image_publisher": "RedHat",
        "image_offer": "RHEL",
        "image_sku": "8.2",
        "image_version": "latest",
        "os_disk_caching": "ReadWrite",
        "os_storage_account_type": "Standard_LRS"
        "subnet_ids": ["/subscriptions/e652d8de-aea2-4177-a0f1-7117adc604ee/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/spectrum-scale-vnet/subnets/spectrum-scale-comp-snet"]
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
