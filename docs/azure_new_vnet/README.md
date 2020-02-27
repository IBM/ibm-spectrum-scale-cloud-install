## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| availability\_zones | List of Azure Availability Zones. | `list(string)` | <pre>[<br>  1,<br>  2<br>]</pre> | no |
| bastion\_subnet\_name | n/a | `string` | `"AzureBastionSubnet"` | no |
| compute\_vm\_os\_offer | Name of the offer of the image that you want to deploy for compute VMs. | `string` | n/a | yes |
| compute\_vm\_os\_publisher | Name of the publisher of the image that you want to deploy for compute VMs. | `string` | n/a | yes |
| compute\_vm\_os\_sku | Sku of the image that you want to deploy for compute VMs | `string` | n/a | yes |
| compute\_vm\_size | Size of the virtual machine that will be deployed for compute VMs. | `string` | n/a | yes |
| data\_disk\_caching | Caching requirements for the Data Disk. Possible values: None, ReadOnly and ReadWrite. | `string` | `"ReadWrite"` | no |
| data\_disk\_create\_option | Create an empty managed disk | `string` | `"Empty"` | no |
| data\_disk\_size | Data disk size in GiB. | `string` | `500` | no |
| data\_disk\_type | Type of storage to use for the data disk. Possible values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS or UltraSSD\_LRS | `string` | `"Standard_LRS"` | no |
| delete\_data\_disks\_on\_termination | Whether data disk to be deleted on VM termination | `bool` | `false` | no |
| delete\_os\_disk\_on\_termination | Whether OS disk to be deleted on VM termination | `bool` | `true` | no |
| location | Azure location where the resources will be created. | `string` | n/a | yes |
| public\_subnet\_address\_prefix | Address space that is used for public subnet. | `string` | `"10.0.1.0/27"` | no |
| resource\_group\_name | Azure resource group name, will be used for tagging resources. | `string` | `"Spectrum-Scale-rg"` | no |
| storage\_vm\_os\_offer | Name of the offer of the image that you want to deploy for storage VMs. | `string` | n/a | yes |
| storage\_vm\_os\_publisher | Name of the publisher of the image that you want to deploy for storage VMs. | `string` | n/a | yes |
| storage\_vm\_os\_sku | Sku of the image that you want to deploy for storage VMs. | `string` | n/a | yes |
| storage\_vm\_size | Size of the virtual machine that will be deployed for storage VMs. | `string` | n/a | yes |
| total\_compute\_vms | Number of VM's to be launched for compute nodes. | `string` | `2` | no |
| total\_disks\_per\_vm | Number of data disks to be attached to each storage VM. | `string` | `1` | no |
| total\_storage\_vms | Number of VM's to be launched for storage nodes | `string` | `2` | no |
| vm\_admin\_username | Name of the administrator to access the VM. | `string` | `"azureuser"` | no |
| vm\_hostname | Local name of the VM. | `string` | `"spectrumscale"` | no |
| vm\_osdisk\_caching | Type of Caching which should be used for the OS Disk. | `string` | `"ReadWrite"` | no |
| vm\_osdisk\_create\_option | Copy a Platform Image. | `string` | `"FromImage"` | no |
| vm\_osdisk\_type | Type of storage to use for the OS disk. Possible values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS or UltraSSD\_LRS | `string` | `"Standard_LRS"` | no |
| vm\_sshlogin\_pubkey\_path | SH public key local path, will be used to login VM. | `string` | n/a | yes |
| vnet\_address\_space | Address space that is used for virtual network. | `string` | `"10.0.0.0/16"` | no |
| vnet\_name | Azure virtual network name. | `string` | `"Spectrum-Scale-vnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_subnet\_name | Azure bastion public subnet name. |
| cloud\_infrastructure | Flag to represent cloud platform. |
| cloud\_platform | Flag to represent Azure cloud. |
| compute\_vms\_by\_private\_ip | Private IP address of Azure compute vms. |
| private\_subnet\_name | Azure private subnet name. |
| resource\_group\_name | Azure resource group name. |
| storage\_vmips\_lun\_number\_map | Dictionary of storage vm ip vs. data disk device path. |
| storage\_vms\_by\_private\_ip | Private IP address of Azure storage vms. |
| vnet\_name | Azure virtual network name. |

