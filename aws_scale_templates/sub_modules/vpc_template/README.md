# Configure AWS VPC

Below steps will provision AWS VPC required for IBM Spectrum Scale cloud solution.

1. Change working directory to `aws_scale_templates/sub_modules/vpc_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/aws_scale_templates/sub_modules/vpc_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zone` keyword. Ex: `"vpc_availability_zones"=["us-east-1a", "us-east-1b", "us-east-1c"]` |
    | --- |

    Minimal Example:

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-east-1",
        "vpc_availability_zones": ["us-east-1a"]
    }
    EOF
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
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | The CIDR block for the VPC. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vpc_create_separate_subnets"></a> [vpc_create_separate_subnets](#input_vpc_create_separate_subnets) | Flag to select if separate private subnet to be created for compute cluster. | `bool` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of cidr_blocks of public subnets. | `list(string)` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of storage cluster private subnets. | `list(string)` |
| <a name="input_vpc_tags"></a> [vpc_tags](#input_vpc_tags) | Additional tags for the VPC | `map(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_internet_gateway"></a> [vpc_internet_gateway](#output_vpc_internet_gateway) | The ID of the Internet Gateway. |
| <a name="output_vpc_nat_gateways"></a> [vpc_nat_gateways](#output_vpc_nat_gateways) | List of allocation ID of Elastic IPs created for AWS NAT Gateway. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
