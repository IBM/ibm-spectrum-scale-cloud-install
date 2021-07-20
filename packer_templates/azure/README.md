# Prerequisites

1. You will need to install [*azure-cli*](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf) and configure your Azure account using `az login` command.

2. Create Azure resource group

    ```cli
    az group create -n <resource-group> -l <location>
    ```

3. Create Azure credentials

    Create a service principal with `az ad sp create-for-rbac` and output the credentials that Packer needs:

    ```cli
    $ az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
    {
        "client_id": "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4",
        "client_secret": "0e760437-bf34-4aad-9f8d-870be799c55d",
        "tenant_id": "72f988bf-86f1-41af-91ab-2d7cd011db47"
    }
    ```

    *NOTE*: These are not real values!

    To authenticate to Azure, you also need to obtain your Azure subscription ID with `az account show`:

    ```cli
    $ az account show --query "{ subscription_id: id }"
    {
        "subscription_id": "e652d8de-aea2-4177-a0f1-7117adc604ee"
    }
    ```

    You use the output from these two commands in the next step.

4. Create Azure storage account

    ```cli
    az storage account create -n <storage-account> -g <resource-group> -l <location>
    ```

5. Create Azure storage container

    ```cli
    az storage container create --account-name <storage-account> --name <container>
    ```

6. Download the IBM Spectrum Scale Data Management Edition install package (from Fix Central) and upload gpfs_rpms to storage container.

    Example:
    [container view](../../docs/images/Azure_container_view.png)

7. Create User-assigned managed identity

    ```cli
    az identity create -g <resource-group> -n <identity-name>
    ```

    You also need to obtain user assigned managed identity ID (Example output below):

    ```cli
    $ az identity show --name ScaleIdentity --resource-group spectrum-scale-rg --query "{ id: id, principalId: principalId }"
    {
        "id": "/subscriptions/e652d8de-aea2-4177-a0f1-7117adc604ee/resourcegroups/spectrum-scale-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ScaleIdentity",
        "principalId": "3d19ee92-cd9d-41c6-a753-e0d97f068032"
    }
    ```

8. Create Azure role assignment

    ```cli
    az role assignment create --role "Storage Blob Data Reader" --scope "/subscriptions/<scope-subscription>/resourcegroups/<scope-resource-group>/providers/Microsoft.Storage/storageAccounts/<scope-resource-storage>/blobServices/default/containers/<scope-container>" --assignee-object-id <identity-principal-id>
    ```

    Assign "Storage Blob Data Reader" to user-assigned managed identity (Example output below):

    ```cli
    az role assignment create --role "Storage Blob Data Reader" --scope "/subscriptions/e652d8de-aea2-4177-a0f1-7117adc604ee/resourcegroups/spectrum-scale-rg/providers/Microsoft.Storage/storageAccounts/scalebucket/blobServices/default/containers/spectrumscale" --assignee-object-id 3d19ee92-cd9d-41c6-a753-e0d97f068032
    ```

9. Download a pre-built [Packer binary](https://www.packer.io/downloads) for your operating system.

## Create Azure (packer) AMI

Below steps will provision Azure VM instance, installs IBM Spectrum Scale rpm's and creates a new AMI.

1. Change working directory to `packer_templates/azure/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/packer_templates/azure/
    ```

2. Create packer variable definitions file (`inputs.auto.pkrvars.hcl`) and provide infrastructure inputs.

    Minimal Example:

    ```jsonc
    $ cat inputs.auto.pkrvars.hcl
    client_id                         = "f5b6a5cf-fbdf-4a9f-b3b8-3c2cd00225a4"
    client_secret                     = "0e760437-bf34-4aad-9f8d-870be799c55d"
    tenant_id                         = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    subscription_id                   = "e652d8de-aea2-4177-a0f1-7117adc604ee"
    managed_image_resource_group_name = "spectrum-scale-rg"
    location                          = "eastus"
    image_publisher                   = "RedHat"
    image_offer                       = "RHEL"
    image_sku                         = "8.2"
    image_version                     = "latest"
    storage_accountname               = "scalebucket"     // Azure storage account.
    spectrumscale_container           = "spectrumscale"   // Azure storage container that contains gpfs/scale rpm's.
    ssh_username                      = "azureuser"
    user_assigned_managed_identities  = ["/subscriptions/e652d8de-aea2-4177-a0f1-7117adc604ee/resourceGroups/spectrum-scale-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ScaleIdentity"]
    ```

3. Run `packer build .` to create Azure managed image.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The Active Directory service principal associated with your builder | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | The password or secret for your service principal. | `string` | n/a | yes |
| <a name="input_image_offer"></a> [image\_offer](#input\_image\_offer) | Name of the publisher's offer to use for your base image (Azure Marketplace Images only). | `string` | `null` | no |
| <a name="input_image_publisher"></a> [image\_publisher](#input\_image\_publisher) | Name of the publisher to use for your base image (Azure Marketplace Images only). | `string` | `null` | no |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | SKU of the image offer to use for your base image (Azure Marketplace Images only). | `string` | `null` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | URL to a custom VHD to use for your base image. If this value is set, image\_publisher, image\_offer, image\_sku should not be set. | `string` | `null` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) |  | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location in which the resources will be created. Examples are East US, West US, etc. | `string` | n/a | yes |
| <a name="input_managed_image_name"></a> [managed\_image\_name](#input\_managed\_image\_name) | Specify the managed image name where the result of the Packer build will be saved. | `string` | `"scale-image"` | no |
| <a name="input_managed_image_resource_group_name"></a> [managed\_image\_resource\_group\_name](#input\_managed\_image\_resource\_group\_name) | The name of the resource group in which the resources will be created. | `string` | n/a | yes |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | The size of the OS disk, in GB. | `string` | `"100"` | no |
| <a name="input_spectrumscale_container"></a> [spectrumscale\_container](#input\_spectrumscale\_container) | Data storage container which contains IBM Spectrum Scale rpm(s). | `string` | n/a | yes |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | The username to connect to SSH with. | `string` | `"azureuser"` | no |
| <a name="input_storage_accountname"></a> [storage\_accountname](#input\_storage\_accountname) | Azure storage account that contains container with IBM Spectrum Scale rpm(s). | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription ID to use. | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` | n/a | yes |
| <a name="input_user_assigned_managed_identities"></a> [user\_assigned\_managed\_identities](#input\_user\_assigned\_managed\_identities) | A list of one or more fully-qualified resource IDs of user assigned managed identities to be configured on the VM. | `list(string)` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the VM used for building. | `string` | `"Standard_A2_v2"` | no |

<!-- END_TF_DOCS -->
