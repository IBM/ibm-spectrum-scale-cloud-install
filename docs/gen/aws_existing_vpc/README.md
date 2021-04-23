## Inputs

|------|-------------|------|---------|:-----:|
| availability\_zones | List of availability zones. | `list(string)` | n/a | yes |
| bastion\_sec\_group\_id | AWS Bastion security group id. | `string` | n/a | yes |
| bucket\_name | s3 bucket name to be used for backing up ansible inventory file. | `string` | n/a | yes |
| compute\_ami\_id | AMI ID of provisioning compute instances. | `string` | n/a | yes |
| deploy\_container\_sec\_group\_id | Deployment container (ECS-FARGATE) security group id. Default: null | `string` | n/a | yes |
| ebs\_volume\_iops | Provisioned IOPS (input/output operations per second) per volume. | `string` | n/a | yes |
| key\_name | Name for the AWS key pair. | `string` | n/a | yes |
| operator\_email | SNS notifications will be sent to provided email id. | `string` | n/a | yes |
| private\_instance\_subnet\_ids | List of instances private security subnet ids. | `list(string)` | n/a | yes |
| region | AWS region where the resources will be created. | `string` | n/a | yes |
| storage\_ami\_id | AMI ID of provisioning storage instances. | `string` | n/a | yes |
| tf\_input\_json\_file\_name | Terraform module input variable defintion/json file name. | `string` | n/a | yes |
| tf\_input\_json\_root\_path | Terraform module absolute path. | `string` | n/a | yes |
| vpc\_id | AWS VPC id. | `string` | n/a | yes |
| compute\_instance\_type | Instance type to use for the compute instance. | `string` | `"t2.medium"` | no |
| compute\_root\_volume\_size | Size of root volume in gibibytes (GiB). | `string` | `100` | no |
| compute\_root\_volume\_type | EBS volume types: io1, gp2, st1 and sc1. | `string` | `"gp2"` | no |
| create\_scale\_cluster | Flag to represent whether to create scale cluster or not. | `bool` | `false` | no |
| ebs\_enable\_delete\_on\_termination | Whether EBS volume to be deleted on instance termination. | `bool` | `false` | no |
| ebs\_volume\_device\_names | Name of the block device to mount on the instance | `list(string)` | <pre>[<br>  "/dev/xvdf",<br>  "/dev/xvdg",<br>  "/dev/xvdh",<br>  "/dev/xvdi",<br>  "/dev/xvdj",<br>  "/dev/xvdk",<br>  "/dev/xvdl",<br>  "/dev/xvdm",<br>  "/dev/xvdn",<br>  "/dev/xvdo",<br>  "/dev/xvdp"<br>]</pre> | no |
| ebs\_volume\_size | EBS/Disk size in GiB | `string` | `500` | no |
| ebs\_volume\_type | EBS volume types: io1, gp2, st1 and sc1. | `string` | `"gp2"` | no |
| ebs\_volumes\_per\_instance | Number of disks to be attached to each storage instance. | `string` | `1` | no |
| egress\_access\_cidr | List of egress CIDRs. Default : 0.0.0.0/0 | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| enable\_instance\_termination\_protection | If true, enables EC2 Instance Termination Protection. | `bool` | `false` | no |
| filesystem\_block\_size | Filesystem block size. | `string` | `"4M"` | no |
| filesystem\_mountpoint | Filesystem mount point. | `string` | `"/gpfs/fs1"` | no |
| operating\_env | Operating environement (valid: local). | `string` | `"local"` | no |
| root\_volume\_enable\_delete\_on\_termination | Whether the root volume should be destroyed on instance termination. | `bool` | `true` | no |
| scale\_infra\_repo\_clone\_path | Path to clone github.com/IBM/ibm-spectrum-scale-install-infra. | `string` | `"/opt/IBM/ibm-spectrumscale-cloud-deploy"` | no |
| stack\_name | AWS Stack name. | `string` | `"Spectrum-Scale"` | no |
| storage\_instance\_type | Instance type to use for the storage instance. | `string` | `"t2.medium"` | no |
| storage\_root\_volume\_size | Size of root volume in gibibytes (GiB). | `string` | `100` | no |
| storage\_root\_volume\_type | EBS volume types: io1, gp2, st1 and sc1. | `string` | `"gp2"` | no |
| tf\_data\_path | Data path to be used by terraform for storing ssh keys. | `string` | `"~/tf_data_path"` | no |
| total\_compute\_instances | Number of EC2 instances to be launched for compute instances. | `string` | `"2"` | no |
| total\_storage\_instances | Number of EC2 instances to be launched for storage instances. | `string` | `"2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| compute\_instance\_desc\_map | Dictionary of compute instance ip vs. descriptor EBS device path. |
| compute\_instance\_ids | AWS compute instance ids. |
| compute\_instance\_desc\_by\_id | AWS compute desc instance id. |
| compute\_instance\_ip\_by\_id | Dictionary of compute instance ip vs. id. |
| compute\_instance\_ips | Private IP address of AWS compute instances. |
| instance\_ips\_with\_0\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_1\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_2\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_3\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_4\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_5\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_6\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_7\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_8\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_9\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_10\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_11\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_12\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_13\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_14\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
| instance\_ips\_with\_15\_datadisks\_ebs\_device\_names | Dictionary of instance ip vs. EBS device path. |
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
| storage\_instance\_ip\_by\_id\_with\_0\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_1\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_2\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_3\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_4\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_5\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_6\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_7\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_8\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_9\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_10\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_11\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_12\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_13\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_14\_datadisks | Dictionary of storage instance ip vs. id. |
| storage\_instance\_ip\_by\_id\_with\_15\_datadisks | Dictionary of storage instance ip vs. id. |
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
