<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../sub_modules/bastion_template | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../sub_modules/vpc_template | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ami_name"></a> [bastion\_ami\_name](#input\_bastion\_ami\_name) | Bastion AMI Image name. | `string` | `"Amazon-Linux2-HVM"` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | Instance type to use for the bastion instance. | `string` | `"t2.micro"` | no |
| <a name="input_bastion_key_pair"></a> [bastion\_key\_pair](#input\_bastion\_key\_pair) | The key pair to use to launch the bastion host. | `string` | n/a | yes |
| <a name="input_bastion_public_ssh_port"></a> [bastion\_public\_ssh\_port](#input\_bastion\_public\_ssh\_port) | Set the SSH port to use from desktop to the bastion. | `string` | `22` | no |
| <a name="input_remote_cidr_blocks"></a> [remote\_cidr\_blocks](#input\_remote\_cidr\_blocks) | List of CIDRs that can access to the bastion. Default : 0.0.0.0/0 | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix is added to all resources that are created. | `string` | `"spectrum-scale"` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | A list of availability zones names or ids in the region. | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc\_compute\_cluster\_private\_subnets\_cidr\_blocks](#input\_vpc\_compute\_cluster\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of compute private subnets. | `list(string)` | <pre>[<br>  "10.0.7.0/24"<br>]</pre> | no |
| <a name="input_vpc_create_separate_subnets"></a> [vpc\_create\_separate\_subnets](#input\_vpc\_create\_separate\_subnets) | Flag to select if separate private subnet to be created for compute cluster. | `bool` | `true` | no |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc\_public\_subnets\_cidr\_blocks](#input\_vpc\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets. | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` | n/a | yes |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc\_storage\_cluster\_private\_subnets\_cidr\_blocks](#input\_vpc\_storage\_cluster\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of storage cluster private subnets. | `list(string)` | <pre>[<br>  "10.0.4.0/24",<br>  "10.0.5.0/24",<br>  "10.0.6.0/24"<br>]</pre> | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Additional tags for the VPC | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_private_ip"></a> [bastion\_instance\_private\_ip](#output\_bastion\_instance\_private\_ip) | Bastion instance private ip addresses. |
| <a name="output_bastion_instance_public_ip"></a> [bastion\_instance\_public\_ip](#output\_bastion\_instance\_public\_ip) | Bastion instance public ip addresses. |
| <a name="output_bastion_security_group_id"></a> [bastion\_security\_group\_id](#output\_bastion\_security\_group\_id) | Bastion security group id. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc\_compute\_cluster\_private\_subnets](#output\_vpc\_compute\_cluster\_private\_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc\_storage\_cluster\_private\_subnets](#output\_vpc\_storage\_cluster\_private\_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
