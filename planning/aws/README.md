# IAM Planning Template

The following steps will create IAM policies required for IBM Storage Scale cloud solution on AWS and attach it to provided user.

1. Change the working directory to `planning/aws/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/planning/aws/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Example:

    ```jsonc
    {
        "vpc_region": "us-east-1",
        "user_name": "cloud-user"
    }
    ```

    > **⚠️ Note:** The IAM user or role executing this Terraform template must have the following policy attached to ensure the necessary permissions can be associated with the provided user.

    ```jsonc
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "iam:CreatePolicy",
                    "iam:AttachUserPolicy",
                    "iam:GetPolicy",
                    "iam:GetPolicyVersion",
                    "iam:ListPolicyVersions",
                    "iam:DeletePolicy",
                    "iam:ListAttachedUserPolicies",
                    "iam:DetachUserPolicy"
                ],
                "Resource": "*"
            }
        ]
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 6.0 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_user_name"></a> [user_name](#input_user_name) | An existing IAM username to which policy needs to be applied. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
<!-- END_TF_DOCS -->
