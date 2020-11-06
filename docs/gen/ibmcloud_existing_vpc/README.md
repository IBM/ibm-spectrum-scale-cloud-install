## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cidr\_block | IBM Cloud VPC subnet CIDR blocks. | `list(string)` | n/a | yes |
| ibmcloud\_api\_key | IBM Cloud api key. | `string` | n/a | yes |
| instance\_key\_name | SSH key name to be used for Compute, Storage virtual server instance. | `string` | n/a | yes |
| private\_subnet\_ids | Subnet id to be used for Compute, Storage virtual server instance. | `list(string)` | n/a | yes |
| region | IBM Cloud region where the resources will be created. | `string` | n/a | yes |
| vpc\_id | IBM Cloud VPC ID. | `string` | n/a | yes |
| zones | IBM Cloud zone names. | `list(string)` | n/a | yes |
| compute\_generation | IBM Cloud compute generation. | `string` | `2` | no |
| compute\_instance\_osimage\_name | Compute instance OS image name. | `string` | `"ibm-ubuntu-18-04-1-minimal-amd64-2"` | no |
| compute\_vsi\_profile | Profile to be used for Compute virtual server instance. | `string` | `"cx2-2x4"` | no |
| data\_disks\_per\_instance | Number of data disks to be attached to each storage instance. | `number` | `1` | no |
| stack\_name | IBM Cloud stack name (keep all lower case). | `string` | `"spectrum-scale"` | no |
| storage\_instance\_osimage\_name | Storage instance OS image name. | `string` | `"ibm-ubuntu-18-04-1-minimal-amd64-2"` | no |
| storage\_vsi\_profile | Profile to be used for Storage virtual server instance. | `string` | `"cx2-2x4"` | no |
| tf\_data\_path | Data path to be used by terraform for storing ssh keys. | `string` | `"~/tf_data_path"` | no |
| total\_compute\_instances | Total Compute instances. | `string` | `2` | no |
| total\_storage\_instances | Total Storage instances. | `string` | `2` | no |
| volume\_capacity | Capacity of the volume in gigabytes. | `number` | `100` | no |
| volume\_iops | Total input/output operations per second. | `number` | `10000` | no |
| volume\_profile | Profile to use for this volume. | `string` | `"10iops-tier"` | no |

## Outputs

| Name | Description |
|------|-------------|
| stack\_name | n/a |
| volume\_1A\_ids | n/a |
| volume\_2A\_ids | n/a |
| vpc\_id | n/a |