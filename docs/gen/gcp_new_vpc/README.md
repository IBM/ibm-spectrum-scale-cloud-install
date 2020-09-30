## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| credentials\_file\_path | The path of a GCP service account key file in JSON format. | `string` | n/a | yes |
| instances\_ssh\_key\_path | SSH public key local path, will be used to login instances. | `string` | n/a | yes |
| operator\_email | GCP service account e-mail address. | `string` | n/a | yes |
| region | GCP region where the resources will be created. | `string` | n/a | yes |
| zones | GCP zones that the instances should be created. | `list(string)` | n/a | yes |
| bastion\_boot\_disk\_size | Bastion boot disk size in gigabytes. | `number` | `10` | no |
| bastion\_boot\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| bastion\_boot\_image | Image from which to initialize this disk. | `string` | `"gce-uefi-images/ubuntu-1804-lts"` | no |
| bastion\_machine\_type | GCP instance machine type to create bastion instance. | `string` | `"n1-standard-1"` | no |
| bastion\_network\_tier | The networking tier to be used for bastion instance (valid: PREMIUM or STANDARD) | `string` | `"STANDARD"` | no |
| compute\_boot\_disk\_size | Compute instances boot disk size in gigabytes. | `number` | `10` | no |
| compute\_boot\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| compute\_boot\_image | Image from which to initialize Spectrum Scale compute instances. | `string` | `"gce-uefi-images/ubuntu-1804-lts"` | no |
| compute\_machine\_type | GCP instance machine type to create Spectrum Scale compute instances. | `string` | `"n1-standard-1"` | no |
| compute\_network\_tier | The networking tier to be used for Spectrum Scale compute instances (valid: PREMIUM or STANDARD) | `string` | `"STANDARD"` | no |
| data\_disk\_physical\_block\_size\_bytes | Physical block size of the persistent disk, in bytes (valid: 4096, 16384). | `number` | `4096` | no |
| data\_disk\_size | Data disk size in gigabytes. | `string` | `5` | no |
| data\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| data\_disks\_per\_instance | Number of data disks to be attached to each storage instance. | `number` | `1` | no |
| gcp\_project\_id | GCP project ID to manage resources. | `string` | `"spectrum-scale"` | no |
| instances\_ssh\_user\_name | Name of the administrator to access the instances. | `string` | `"gcpadmin"` | no |
| private\_subnet\_cidr | Range of internal addresses. | `string` | `"192.168.1.0/24"` | no |
| public\_subnet\_cidr | Range of internal addresses. | `string` | `"192.168.0.0/24"` | no |
| scopes | List of service scopes. | `list(string)` | <pre>[<br>  "cloud-platform"<br>]</pre> | no |
| stack\_name | GCP stack name, will be used for tagging resources. | `string` | `"spectrum-scale"` | no |
| storage\_boot\_disk\_size | Storage instances boot disk size in gigabytes. | `number` | `10` | no |
| storage\_boot\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| storage\_boot\_image | Image from which to initialize Spectrum Scale storage instances. | `string` | `"gce-uefi-images/ubuntu-1804-lts"` | no |
| storage\_machine\_type | GCP instance machine type to create Spectrum Scale storage instances. | `string` | `"n1-standard-1"` | no |
| storage\_network\_tier | The networking tier to be used for Spectrum Scale storage instances (valid: PREMIUM or STANDARD) | `string` | `"STANDARD"` | no |
| total\_compute\_instances | Number of instances to be launched for compute instances. | `number` | `2` | no |
| total\_storage\_instances | Number of instances to be launched for compute instances. | `number` | `2` | no |
| vpc\_description | Description of VPC. | `string` | `"This VPC is used by IBM Spectrum Scale"` | no |
| vpc\_routing\_mode | Network-wide routing mode to use (valid: REGIONAL, GLOBAL). | `string` | `"GLOBAL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_instance\_private\_ip | Private IP address of GCP storage instances. |
| bastion\_instance\_public\_ip | GCP storage instance ids. |
| compute\_instance\_desc\_id | GCP compute desc instance id. |
| compute\_instance\_desc\_ip | Private IP address of GCP desc compute instance. |
| compute\_instance\_ids | GCP compute instance ids. |
| compute\_instance\_ips | Private IP address of GCP compute instances. |
| storage\_instance\_1A\_zone\_ids | GCP storage instance ids. |
| storage\_instance\_1A\_zone\_ips | Private IP address of GCP storage instances. |
| storage\_instance\_2A\_zone\_ids | GCP storage instance ids. |
| storage\_instance\_2A\_zone\_ips | Private IP address of GCP storage instances. |
