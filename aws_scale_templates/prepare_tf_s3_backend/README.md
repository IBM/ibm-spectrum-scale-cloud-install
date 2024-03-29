### Configure terraform S3 (remote) backend

Below steps will provision AWS resources (**new S3 bucket, new DynamoDB table**) required for enabling S3
backend for terraform. For more details, refer to [Terraform S3 backend](https://www.terraform.io/docs/language/settings/backends/s3.html).

1. Change working directory to `aws_scale_templates/prepare_tf_s3_backend`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/aws_scale_templates/prepare_tf_s3_backend/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Example:
    ```json
    {
        "vpc_region": "us-east-1",
        "bucket_name": "scalebucket",
        "dynamodb_table_name": "scaletf_table",
        "force_destroy": true
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 3.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name) | Name to be used for bucket (make sure it is unique) | `string` |
| <a name="input_dynamodb_table_name"></a> [dynamodb_table_name](#input_dynamodb_table_name) | DynamoDB table name, needs to be unique within a region | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy) | Whether to allow a forceful destruction of this bucket | `bool` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket_arn](#output_bucket_arn) | n/a |
| <a name="output_bucket_id"></a> [bucket_id](#output_bucket_id) | n/a |
| <a name="output_dynamodb_table_name"></a> [dynamodb_table_name](#output_dynamodb_table_name) | n/a |
<!-- END_TF_DOCS -->
