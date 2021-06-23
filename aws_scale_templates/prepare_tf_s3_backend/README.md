<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name to be used for bucket (make sure it is unique) | `string` | n/a | yes |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | DynamoDB table name, needs to be unique within a region | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether to allow a forceful destruction of this bucket | `bool` | `true` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | n/a |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | n/a |
<!-- END_TF_DOCS -->
