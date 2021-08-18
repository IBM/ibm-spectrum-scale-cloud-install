### Configure IBM Cloud Bastion VSI

Below steps will provision IBM Cloud Bastion instance required for IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/sub_modules/bastion_template`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/bastion_template/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:
    ```jsonc
    {
        "vpc_region": "us-south",
        "vpc_id": "r006-06cbae39-4cab-44c7-b6ad-29fc5bb3ddbc",            // Use an existing vpc id
        "resource_group_id": "5c5d77eb1c3f4cd4b158dbbf62b5841c",          // Use an existing resource group id
        "bastion_subnet_id": "0717-11819167-7a9b-4563-8d0e-210bb513f2e8", // Use an existing subnet id
        "bastion_key_pair": null,                                         // Use an existing IBM Cloud SSH key pair
        "vpc_availability_zones": ["us-south-1"]
    }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_bastion_key_pair"></a> [bastion_key_pair](#input_bastion_key_pair) | The key pair to use to launch the bastion host. | `string` |
| <a name="input_bastion_subnet_id"></a> [bastion_subnet_id](#input_bastion_subnet_id) | Subnet id to be used for Bastion virtual server instance. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | IBM Cloud resource group id. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc. | `string` |
| <a name="input_bastion_osimage_name"></a> [bastion_osimage_name](#input_bastion_osimage_name) | Bastion OS image name. | `string` |
| <a name="input_bastion_vsi_profile"></a> [bastion_vsi_profile](#input_bastion_vsi_profile) | Profile to be used for Bastion virtual server instance. | `string` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDRs that can access to the bastion. Default : 0.0.0.0/0 | `list(string)` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_private_ip"></a> [bastion_instance_private_ip](#output_bastion_instance_private_ip) | Bastion instance private ip addresses. |
| <a name="output_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#output_bastion_instance_public_ip) | Bastion instance public ip addresses. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group id. |
| <a name="output_bastion_vsi_id"></a> [bastion_vsi_id](#output_bastion_vsi_id) | Bastion instance id. |
<!-- END_TF_DOCS -->
