## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| all\_compute\_nic\_ids | n/a | `list(string)` | n/a | yes |
| all\_storage\_nic\_ids | n/a | `list(string)` | n/a | yes |
| availability\_zones | n/a | `list(string)` | n/a | yes |
| compute\_vm\_os\_offer | n/a | `string` | n/a | yes |
| compute\_vm\_os\_publisher | n/a | `string` | n/a | yes |
| compute\_vm\_os\_sku | n/a | `string` | n/a | yes |
| compute\_vm\_size | n/a | `string` | n/a | yes |
| data\_disk\_size | n/a | `string` | n/a | yes |
| location | n/a | `string` | n/a | yes |
| private\_zone\_vnet\_link\_name | n/a | `string` | n/a | yes |
| resource\_group\_name | n/a | `string` | n/a | yes |
| storage\_vm\_os\_offer | n/a | `string` | n/a | yes |
| storage\_vm\_os\_publisher | n/a | `string` | n/a | yes |
| storage\_vm\_os\_sku | n/a | `string` | n/a | yes |
| storage\_vm\_size | n/a | `string` | n/a | yes |
| total\_compute\_vms | n/a | `string` | n/a | yes |
| total\_disks\_per\_vm | n/a | `string` | n/a | yes |
| total\_storage\_vms | n/a | `string` | n/a | yes |
| vm\_sshlogin\_pubkey\_path | n/a | `string` | n/a | yes |
| data\_disk\_caching | n/a | `string` | `"ReadWrite"` | no |
| data\_disk\_create\_option | n/a | `string` | `"Empty"` | no |
| data\_disk\_type | n/a | `string` | `"Empty"` | no |
| delete\_data\_disks\_on\_termination | n/a | `bool` | `true` | no |
| delete\_os\_disk\_on\_termination | n/a | `bool` | `true` | no |
| vm\_admin\_username | n/a | `string` | `"azureuser"` | no |
| vm\_osdisk\_caching | n/a | `string` | `"ReadWrite"` | no |
| vm\_osdisk\_create\_option | n/a | `string` | `"FromImage"` | no |
| vm\_osdisk\_type | n/a | `string` | `"Standard_LRS"` | no |

## Outputs

| Name | Description |
|------|-------------|
| compute\_vm\_ids | n/a |
| compute\_vms\_by\_az | n/a |
| storage\_vm\_ids | n/a |
| storage\_vms\_by\_az | n/a |
