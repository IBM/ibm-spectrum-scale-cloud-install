## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| availability\_zones | List of AWS Availability Zones. | `list(string)` | n/a | yes |
| bastion\_image\_name | Bastion AMI image name | `string` | n/a | yes |
| compute\_ami\_id | AMI ID of provisioning compute instances. | `string` | n/a | yes |
| ebs\_volume\_iops | Provisioned IOPS (input/output operations per second) per volume. | `string` | n/a | yes |
| key\_name | Name for the AWS key pair | `string` | n/a | yes |
| operator\_email | SNS notifications will be sent to provided email id. | `string` | n/a | yes |
| region | AWS region where the resources will be created. | `string` | n/a | yes |
| storage\_ami\_id | AMI ID of provisioning storage instances | `string` | n/a | yes |
| ansible\_scale\_repo\_clone\_path | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` | `"/opt/IBM/ibm-spectrumscale-cloud-deploy"` | no |
| bastion\_instance\_type | Instance type to use for the bastion instance. | `string` | `"t2.micro"` | no |
| cidr\_block | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| compute\_instance\_type | Instance type to use for the compute instances. | `string` | `"t2.medium"` | no |
| create\_scale\_cluster | Flag to represent whether to create scale cluster or not. | `bool` | `false` | no |
| ebs\_enable\_delete\_on\_termination | Whether EBS volume to be deleted on instance termination. | `bool` | `false` | no |
| ebs\_volume\_size | EBS/Disk size in GiB | `string` | `500` | no |
| ebs\_volume\_type | EBS volume types: io1, gp2, st1 and sc1. | `string` | `"gp2"` | no |
| ebs\_volumes\_per\_instance | Number of disks to be attached to each storage instance. | `string` | `1` | no |
| filesystem\_block\_size | Filesystem block size. | `string` | `"4M"` | no |
| filesystem\_mountpoint | Filesystem mount point. | `string` | `"/gpfs/fs1"` | no |
| stack\_name | AWS stack name, will be used for tagging resources. | `string` | `"Spectrum-Scale"` | no |
| storage\_instance\_type | Instance type to use for the storage instances. | `string` | `"t2.medium"` | no |
| total\_compute\_instances | Number of EC2 instances to be launched for compute instances. | `string` | `2` | no |
| total\_storage\_instances | Number of EC2 instances to be launched for storage instances. | `string` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_env | Flag to represent cloud platform. |
| cloud\_platform | Flag to represent AWS cloud. |
| vpc\_id | VPC ID. |
| compute\_instance\_desc\_map | Dictionary of compute instance ip vs. descriptor EBS device path. |
| compute\_instances\_by\_id | AWS compute instance ids. |
| compute\_instances\_by\_ip | Private IP address of AWS compute instances. |
| private\_subnets | AWS private subnet IDs. |
| public\_subnets | AWS public subnet IDs. |
| stack\_name | AWS Stack name. |
| storage\_instance\_ids\_with\_0\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_1\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_2\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_3\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_4\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_5\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_6\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_7\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_8\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_9\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_10\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_11\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_12\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_13\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_14\_datadisks | AWS storage instance ids. |
| storage\_instance\_ids\_with\_15\_datadisks | AWS storage instance ids. |
| storage\_instance\_ips\_with\_0\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_1\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_2\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_3\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_4\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_5\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_6\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_7\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_8\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_9\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_10\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_11\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_12\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_13\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_14\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_15\_datadisks | Private IP address of AWS storage instances. |
| storage\_instance\_ips\_with\_0\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_1\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_2\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_3\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_4\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_5\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_6\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_7\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_8\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_9\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_10\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_11\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_12\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_13\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_14\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
| storage\_instance\_ips\_with\_15\_datadisks\_device\_names\_map | Dictionary of storage instance ip vs. EBS device path. |
