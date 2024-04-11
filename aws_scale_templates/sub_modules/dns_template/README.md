# Configure AWS Route53 and associate with a VPC

The below steps will provision the AWS route53 zones required for the IBM Spectrum Scale cloud solution.

1. Change the working directory to `aws_scale_templates/sub_modules/dns_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/aws_scale_templates/sub_modules/dns_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example-1:

    ```cli
    cat <<EOF > combined_1az.auto.tfvars.json
    {
	    "cluster_type": "Combined-compute-storage",
	    "create_dns_zone": true,
    	"vpc_compute_cluster_dns_zone": "ibm-storage-scale.compscale.com",
	    "vpc_compute_cluster_dns_zone_description": "This zone is created by (cloudkit) for IBM Storage Scale (ibm-storage-scale) operations.",
	    "vpc_ref": "vpc-00ff479c2deb21662",
    	"vpc_region": "us-east-2",
    	"vpc_reverse_dns_zone": "10.in-addr.arpa",
	    "vpc_reverse_dns_zone_description": "This zone is created by (cloudkit) for IBM Storage Scale (ibm-storage-scale) operations.",
	    "vpc_storage_cluster_dns_zone": "ibm-storage-scale.strgscale.com",
	    "vpc_storage_cluster_dns_zone_description": "This zone is created by (cloudkit) for IBM Storage Scale (ibm-storage-scale) operations.",
    }
    EOF
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | The CIDR block for the VPC. Example: 10.0.0.0/16 | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of cidr_blocks of public subnets. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of storage cluster private subnets. | `list(string)` |
| <a name="input_vpc_tags"></a> [vpc_tags](#input_vpc_tags) | Additional tags for the VPC | `map(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_compute_nat_gateways"></a> [vpc_compute_nat_gateways](#output_vpc_compute_nat_gateways) | List of allocation ID of Elastic IPs created for AWS NAT Gateway. |
| <a name="output_vpc_internet_gateway"></a> [vpc_internet_gateway](#output_vpc_internet_gateway) | The ID of the Internet Gateway. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_ref"></a> [vpc_ref](#output_vpc_ref) | The ID of the VPC. |
| <a name="output_vpc_s3_private_endpoint"></a> [vpc_s3_private_endpoint](#output_vpc_s3_private_endpoint) | The ID of the vpc s3 endpoint associated with private subnets. |
| <a name="output_vpc_s3_public_endpoint"></a> [vpc_s3_public_endpoint](#output_vpc_s3_public_endpoint) | The ID of the vpc s3 endpoint associated with public subnets. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
| <a name="output_vpc_storage_nat_gateways"></a> [vpc_storage_nat_gateways](#output_vpc_storage_nat_gateways) | List of allocation ID of Elastic IPs created for AWS NAT Gateway. |
<!-- END_TF_DOCS -->
