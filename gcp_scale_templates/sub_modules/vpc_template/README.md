# Configure GCP VPC
This terraform template creates GCP VPC required for IBM Spectrum Scale cloud solution.

## Before Starting

Ensure that you have configured and  get GCP credentials json file via any of the following GCP authentication ways.
1.	[Application default credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc)
2.	[Service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

Make a note of credentials file full path which is required in next section

## VPC Template

The following steps will provision GCP resources (**new VPC) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `vpc_template/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/sub_modules/vpc_template/
    ```

2. Create terraform variable definitions file (terraform.tfvars.json) and provide infrastructure inputs.

    Minimal Example-1 :

    Default vpc network creation with two subnet, one public and one private with "192.168.0.0/24" and "192.168.1.0/24" respectively.

    ```
    $ cat new_vpc_default.tfvars.json
    {
        "region"               : "us-central1",
        "gcp_project_id"       : "spectrum-scale-XXXXXX",
        "credentials_file_path": "/home/james/gcp_data/spectrum-scale.json" .
    }
    ```
    Note : 'credentials_file_path' key needs to update with the credentials file path got from previous section


    4. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | ~> 4.0.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_credentials_file_path"></a> [credentials_file_path](#input_credentials_file_path) | The path of a GCP service account key file in JSON format. | `string` |
| <a name="input_gcp_project_id"></a> [gcp_project_id](#input_gcp_project_id) | GCP project ID to manage resources. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | The CIDR block for the VPC. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of compute private subnets. | `list(string)` |
| <a name="input_vpc_description"></a> [vpc_description](#input_vpc_description) | Description of VPC. | `string` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | Range of internal addresses. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | GCP region where the resources will be created. | `string` |
| <a name="input_vpc_routing_mode"></a> [vpc_routing_mode](#input_vpc_routing_mode) | Network-wide routing mode to use (valid: REGIONAL, GLOBAL). | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of cidr_blocks of storage cluster private subnets. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_type"></a> [cluster_type](#output_cluster_type) | n/a |
| <a name="output_vpc_compute_cluster_nat"></a> [vpc_compute_cluster_nat](#output_vpc_compute_cluster_nat) | List of IDs of compute cluster nat. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output_vpc_name) | VPC name. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_storage_cluster_nat"></a> [vpc_storage_cluster_nat](#output_vpc_storage_cluster_nat) | List of IDs of storage cluster nat. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
