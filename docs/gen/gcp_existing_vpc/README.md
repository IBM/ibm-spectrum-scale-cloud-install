## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compute\_instance\_tags | List of tags to attach to the compute instance. | `list(string)` | n/a | yes |
| credentials\_file\_path | The path of a GCP service account key file in JSON format. | `string` | n/a | yes |
| instances\_ssh\_key\_path | SSH public key local path, will be used to login bastion instance. | `string` | n/a | yes |
| operator\_email | GCP service account e-mail address. | `string` | n/a | yes |
| region | GCP region where the resources will be created. | `string` | n/a | yes |
| zones | GCP zones that the instances should be created. | `list(string)` | n/a | yes |
| compute\_boot\_disk\_size | Compute instances boot disk size in gigabytes. | `number` | `10` | no |
| compute\_boot\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| compute\_boot\_image | Image from which to initialize Spectrum Scale compute instances. | `string` | `"gce-uefi-images/ubuntu-1804-lts"` | no |
| compute\_instance\_name\_prefix | Compute instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]\*[a-z0-9])? | `string` | `"compute"` | no |
| compute\_machine\_type | GCP instance machine type to create Spectrum Scale compute instances. | `string` | `"n1-standard-1"` | no |
| compute\_network\_tier | The networking tier to be used for Spectrum Scale compute instances (valid: PREMIUM or STANDARD). | `string` | `"STANDARD"` | no |
| data\_disk\_physical\_block\_size\_bytes | Physical block size of the persistent disk, in bytes (valid: 4096, 16384). | `number` | `4096` | no |
| data\_disk\_size | Data disk size in gigabytes. | `string` | `5` | no |
| data\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| data\_disks\_per\_instance | Number of data disks to be attached to each storage instance. | `number` | `1` | no |
| gcp\_project\_id | GCP project ID to manage resources. | `string` | `"spectrum-scale"` | no |
| instances\_ssh\_user\_name | Name of the administrator to access the bastion instance. | `string` | `"gcpadmin"` | no |
| private\_subnet\_name | Subnetwork of a Virtual Private Cloud network with one primary IP range | `string` | `"spectrum-scale-private-subnet"` | no |
| scopes | List of service scopes. | `list(string)` | <pre>[<br>  "cloud-platform"<br>]</pre> | no |
| stack\_name | GCP stack name, will be used for tagging resources. | `string` | `"spectrum-scale"` | no |
| storage\_boot\_disk\_size | Storage instances boot disk size in gigabytes. | `number` | `10` | no |
| storage\_boot\_disk\_type | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| storage\_boot\_image | Image from which to initialize Spectrum Scale storage instances. | `string` | `"gce-uefi-images/ubuntu-1804-lts"` | no |
| storage\_instance\_name\_prefix | Storage instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]\*[a-z0-9])? | `string` | `"storage"` | no |
| storage\_machine\_type | GCP instance machine type to create Spectrum Scale storage instances. | `string` | `"n1-standard-1"` | no |
| storage\_network\_tier | The networking tier to be used for Spectrum Scale compute instances (valid: PREMIUM or STANDARD). | `string` | `"STANDARD"` | no |
| tf\_data\_path | Data path to be used by terraform for storing ssh keys. | `string` | `"~/tf_data_path"` | no |
| total\_compute\_instances | Number of instances to be launched for compute instances. | `number` | `2` | no |
| total\_storage\_instances | Number of instances to be launched for storage instances. | `number` | `2` | no |
| vpc\_name | GCP VPC name. | `string` | `"spectrum-scale=vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| compute\_instance\_desc\_id | GCP compute desc instance id. |
| compute\_instance\_desc\_ip | Private IP address of GCP desc compute instance. |
| compute\_instance\_ids | GCP compute instance ids. |
| compute\_instance\_ips | Private IP address of GCP compute instances. |
| storage\_instance\_1A\_zone\_ids | GCP storage instance ids. |
| storage\_instance\_1A\_zone\_ips | Private IP address of GCP storage instances. |
| storage\_instance\_2A\_zone\_ids | GCP storage instance ids. |
| storage\_instance\_2A\_zone\_ips | Private IP address of GCP storage instances. |
