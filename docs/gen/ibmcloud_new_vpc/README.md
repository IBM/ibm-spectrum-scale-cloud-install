## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_key\_name | SSH key name to be used for Bastion virtual server instance. | `string` | n/a | yes |
| ibmcloud\_api\_key | IBM Cloud api key. | `string` | n/a | yes |
| instance\_key\_name | SSH key name to be used for Compute, Storage virtual server instance. | `string` | n/a | yes |
| region | IBM Cloud region where the resources will be created. | `string` | n/a | yes |
| zones | IBM Cloud zone names. | `list(string)` | n/a | yes |
| addr\_prefixes | IBM Cloud VPC address prefixes. | `list(string)` | <pre>[<br>  "10.241.0.0/18",<br>  "10.241.64.0/18",<br>  "10.241.128.0/18"<br>]</pre> | no |
| bastion\_incoming\_remote | Bastion security group inbound remote. | `string` | `"0.0.0.0/0"` | no |
| bastion\_osimage\_name | Bastion OS image name. | `string` | `"ibm-ubuntu-18-04-1-minimal-amd64-2"` | no |
| bastion\_vsi\_profile | Profile to be used for Bastion virtual server instance. | `string` | `"cx2-2x4"` | no |
| cidr\_block | IBM Cloud VPC subnet CIDR blocks. | `list(string)` | <pre>[<br>  "10.241.0.0/24",<br>  "10.241.64.0/24",<br>  "10.241.128.0/24"<br>]</pre> | no |
| compute\_generation | IBM Cloud compute generation. | `string` | `2` | no |
| compute\_osimage\_name | Compute instance OS image name. | `string` | `"ibm-redhat-8-1-minimal-amd64-1"` | no |
| compute\_vsi\_profile | Profile to be used for Compute virtual server instance. | `string` | `"cx2-2x4"` | no |
| data\_disks\_per\_instance | Number of data disks to be attached to each storage instance. | `number` | `1` | no |
| operating\_env | Operating environement (valid: local). | `string` | `"local"` | no |
| stack\_name | IBM Cloud stack name (keep all lower case). | `string` | `"spectrum-scale"` | no |
| storage\_osimage\_name | Storage instance OS image name. | `string` | `"ibm-redhat-8-1-minimal-amd64-1"` | no |
| storage\_vsi\_profile | Profile to be used for Storage virtual server instance. | `string` | `"cx2-2x4"` | no |
| tf\_data\_path | Data path to be used by terraform for storing ssh keys. | `string` | `"~/tf_data_path"` | no |
| total\_compute\_instances | Total number of Compute instances. | `string` | `2` | no |
| total\_storage\_instances | Total number of Storage instances. | `string` | `2` | no |
| volume\_capacity | Capacity of the volume in gigabytes. | `number` | `100` | no |
| volume\_iops | Total input/output operations per second. | `number` | `null` | no |
| volume\_profile | Profile to use for this volume. | `string` | `"10iops-tier"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_instance\_id | IBM Cloud bastion instance ID. |
| bastion\_instance\_public\_ip | IBM Cloud bastion instance public IP addresses. |
| cloud\_platform | Flag to represent IBM cloud. |
| operating\_env | Operating environement (valid: local). |
| private\_subnets | IBM Cloud private subnet IDs. |
| stack\_name | IBM Cloud Stack name. |
| volume\_1A\_ids | n/a |
| volume\_2A\_ids | n/a |
| vpc\_id | IBM Cloud VPC ID. |