<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
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
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc\_compute\_cluster\_private\_subnets](#output\_vpc\_compute\_cluster\_private\_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_vpc_internet_gateway"></a> [vpc\_internet\_gateway](#output\_vpc\_internet\_gateway) | The ID of the Internet Gateway. |
| <a name="output_vpc_nat_gateways"></a> [vpc\_nat\_gateways](#output\_vpc\_nat\_gateways) | List of allocation ID of Elastic IPs created for AWS NAT Gateway. |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc\_storage\_cluster\_private\_subnets](#output\_vpc\_storage\_cluster\_private\_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
