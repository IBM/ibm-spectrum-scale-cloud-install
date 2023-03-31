# Configure AWS Bastion Instance

The below steps will provision the AWS Bastion instance required for the IBM Spectrum Scale cloud solution.

1. Change the working directory to `aws_scale_templates/sub_modules/bastion_template`.

    ```cli
    # cd ibm-spectrum-scale-cloud-install/aws_scale_templates/sub_modules/bastion_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```jsonc
    {
        "vpc_region": "us-east-1",
        "vpc_id": null,                          // Use an existing vpc id
        "vpc_auto_scaling_group_subnets": [],    // Use public subnets
        "resource_prefix": "spectrum-scale",
        "bastion_ami_name": "Amazon-Linux2-HVM",
        "bastion_instance_type": "t2.micro",
        "bastion_key_pair": null                 // Use an existing AWS EC2 key pair
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 4.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_bastion_image_ref"></a> [bastion_image_ref](#input_bastion_image_ref) | Bastion AMI Image id. | `string` |
| <a name="input_bastion_key_pair"></a> [bastion_key_pair](#input_bastion_key_pair) | The key pair to use to launch the bastion host. | `string` |
| <a name="input_vpc_auto_scaling_group_subnets"></a> [vpc_auto_scaling_group_subnets](#input_vpc_auto_scaling_group_subnets) | List of subnet were the Auto Scalling Group will deploy the instances. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_bastion_instance_type"></a> [bastion_instance_type](#input_bastion_instance_type) | Instance type to use for the bastion instance. | `string` |
| <a name="input_bastion_public_ssh_port"></a> [bastion_public_ssh_port](#input_bastion_public_ssh_port) | Set the SSH port to use from desktop to the bastion. | `number` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDRs that can access to the bastion. Default : 0.0.0.0/0 | `list(string)` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_id"></a> [bastion_instance_id](#output_bastion_instance_id) | Bastion instance id. |
| <a name="output_bastion_instance_private_ip"></a> [bastion_instance_private_ip](#output_bastion_instance_private_ip) | Bastion instance private ip addresses. |
| <a name="output_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#output_bastion_instance_public_ip) | Bastion instance public ip addresses. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group id. |
<!-- END_TF_DOCS -->
