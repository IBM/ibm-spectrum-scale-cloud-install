# Usage - Microsoft Azure

## Template Parameters

  * [New VNet](gen/azure_new_vnet/README.md)
  * [Existing VNet](gen/azure_existing_vnet/README.md)

## Before Starting

Ensure that you have configured your Azure public cloud credentials:

1. [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
2. Validate the ability to [log in to Azure](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest) using `az login`.

#### Warning: Each run of  `terraform apply` will generate a new SSH key and cause replacement of SSH key dependent resources. 

## New VNet Template

The following steps will provision Azure resources (**new VNet, Bastion, compute and storage vm's**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `azure_new_vnet_scale/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/azure_scale_templates/azure_new_vnet_scale/
    ```

2. Create terraform variable definitions file (`azure_new_vnet_scale_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [Azure New VNet Template Input Parameters](docs/azure_new_vnet/README.md#inputs).)
    ```
    $ cat azure_new_vnet_scale_inputs.auto.tfvars.json
    {
        "location": "eastus",
        "resource_group_name": "Spectrum-Scale-rg",
        "availability_zones": [
            1,
            2
        ],
        "vnet_name": "Spectrum-Scale-vnet",
        "vm_sshlogin_pubkey_path": "/Data/Code/id_rsa.pub",
        "total_compute_vms": "1",
        "compute_vm_os_publisher": "Canonical",
        "compute_vm_os_offer": "UbuntuServer",
        "compute_vm_os_sku": "16.04-LTS",
        "compute_vm_size": "Standard_D1_v2",
        "total_storage_vms": "2",
        "storage_vm_os_publisher": "Canonical",
        "storage_vm_os_offer": "UbuntuServer",
        "storage_vm_os_sku": "16.04-LTS",
        "storage_vm_size": "Standard_D1_v2",
        "total_disks_per_vm": "3",
        "data_disk_size": "1"
    }
    ```

    | Note: In case of single availability zone, provide a single value for the `availability_zone` keyword. Ex: `"availability_zones"=["1"]`|
    | --- |

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

## Existing VNet Template

The following steps will provision Azure resources (**compute and storage vm's in existing VNet**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `vm_template/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/vm_template/
    ```

2. Create terraform variable definitions file (`azure_scale_vms_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [Azure Existing VNet Template Input Parameters](docs/azure_existing_vnet/README.md#inputs).)

    ```
    $ cat azure_scale_vms_inputs.auto.tfvars.json
    {
        "location": "eastus",
        "resource_group_name": "Spectrum-Scale-rg",
        "availability_zones": [
            1,
            2
        ],
        "all_compute_nic_ids": ["/subscriptions/a1-05-4d-89-c9/resourceGroups/Spectrum-Scale-rg/providers/Microsoft.Network/networkInterfaces/spectrumscale-compute-nic-1"],
        "all_storage_nic_ids": ["/subscriptions/a1-05-4d-89-c9/resourceGroups/Spectrum-Scale-rg/providers/Microsoft.Network/networkInterfaces/spectrumscale-storage-nic-1",
                                "/subscriptions/a1-05-4d-89-c9/resourceGroups/Spectrum-Scale-rg/providers/Microsoft.Network/networkInterfaces/spectrumscale-storage-nic-2"],
        "private_zone_vnet_link_name": "private-snet",
        "vm_sshlogin_pubkey_path": "/Data/Code/id_rsa.pub",
        "total_compute_vms": "1",
        "compute_vm_os_publisher": "Canonical",
        "compute_vm_os_offer": "UbuntuServer",
        "compute_vm_os_sku": "16.04-LTS",
        "compute_vm_size": "Standard_D1_v2",
        "total_storage_vms": "2",
        "storage_vm_os_publisher": "Canonical",
        "storage_vm_os_offer": "UbuntuServer",
        "storage_vm_os_sku": "16.04-LTS",
        "storage_vm_size": "Standard_D1_v2",
        "total_disks_per_vm": "3",
        "data_disk_size": "1"
    }
    ```

    | Note: In case of single availability zone, provide a single value for the `availability_zone` keyword. Ex: `"availability_zones"=["1"]`|
    | --- |

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

