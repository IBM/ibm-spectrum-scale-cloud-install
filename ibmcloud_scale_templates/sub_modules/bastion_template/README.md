# Configure IBM Cloud Bastion VSI

Below steps will provision IBM Cloud Bastion instance required for IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/sub_modules/bastion_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/bastion_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```jsonc
    {
        "ibmcloud_api_key": "xxx",
        "vpc_region": "us-south",
        "resource_prefix": "test-rg",
        "vpc_ref": "xxxx",
        "bastion_instance_type": "bx2-2x8",
        "bastion_image_ref": "xxxx",
        "bastion_key_pair": "test-ssh",
        "resource_group_name" :"test-vpc",
        "vpc_auto_scaling_group_subnets": ["xxxx"],
        "vpc_availability_zones": ["us-south-1"],
        "bastion_public_ssh_port": 22,
        "desired_instance_count": 1
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 1.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_bastion_image_ref"></a> [bastion_image_ref](#input_bastion_image_ref) | Bastion AMI Image id. | `string` |
| <a name="input_bastion_instance_type"></a> [bastion_instance_type](#input_bastion_instance_type) | Instance type to use for the bastion instance. | `string` |
| <a name="input_bastion_key_pair"></a> [bastion_key_pair](#input_bastion_key_pair) | The key pair to use to launch the bastion host. | `string` |
| <a name="input_bastion_public_ssh_port"></a> [bastion_public_ssh_port](#input_bastion_public_ssh_port) | Set the SSH port to use from desktop to the bastion. | `number` |
| <a name="input_desired_instance_count"></a> [desired_instance_count](#input_desired_instance_count) | Bastion instance desired count. | `number` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a resource group in which the resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
| <a name="input_vpc_auto_scaling_group_subnets"></a> [vpc_auto_scaling_group_subnets](#input_vpc_auto_scaling_group_subnets) | List of subnet were the Auto Scaling Group will deploy the instances. | `list(string)` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc. | `string` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDRs that can access to the bastion. Default : 0.0.0.0/0 | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_autoscaling_group_ref"></a> [bastion_instance_autoscaling_group_ref](#output_bastion_instance_autoscaling_group_ref) | Bastion instances autoscaling group (id/self-link). |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group id. |
<!-- END_TF_DOCS -->
