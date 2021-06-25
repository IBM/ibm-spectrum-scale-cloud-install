<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_description"></a> [ami\_description](#input\_ami\_description) | The description to set for the resulting AMI. | `string` | `"IBM Spectrum Scale AMI"` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the resulting AMI. To make this unique, timestamp will be appended. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The EC2 instance type to use while building the AMI. | `string` | n/a | yes |
| <a name="input_s3_spectrumscale_bucket"></a> [s3\_spectrumscale\_bucket](#input\_s3\_spectrumscale\_bucket) | S3 bucket which contains IBM Spectrum Scale rpm(s). | `string` | n/a | yes |
| <a name="input_source_ami_id"></a> [source\_ami\_id](#input\_source\_ami\_id) | The source AMI id whose root volume will be copied and provisioned on the currently running instance. | `string` | n/a | yes |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of the volume, in GiB. | `string` | `"200"` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | The volume type. gp2 & gp3 for General Purpose (SSD) volumes. | `string` | `"gp2"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id you want to use for building AMI. | `string` | n/a | yes |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` | n/a | yes |
| <a name="input_vpc_security_group_id"></a> [vpc\_security\_group\_id](#input\_vpc\_security\_group\_id) | The security group id to assign to the instance, you must be sure the security group allows access to the ssh port. | `string` | n/a | yes |
| <a name="input_vpc_subnet_id"></a> [vpc\_subnet\_id](#input\_vpc\_subnet\_id) | The subnet ID to use for the instance. | `string` | n/a | yes |

<!-- END_TF_DOCS -->
