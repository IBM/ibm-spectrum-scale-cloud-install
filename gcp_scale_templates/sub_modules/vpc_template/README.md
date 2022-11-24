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
| <a name="input_region"></a> [region](#input_region) | GCP region where the resources will be created. | `string` |
| <a name="input_private_subnet_cidr"></a> [private_subnet_cidr](#input_private_subnet_cidr) | Range of internal addresses. | `string` |
| <a name="input_public_subnet_cidr"></a> [public_subnet_cidr](#input_public_subnet_cidr) | Range of internal addresses. | `string` |
| <a name="input_stack_name"></a> [stack_name](#input_stack_name) | GCP stack name, will be used for tagging resources. | `string` |
| <a name="input_vpc_description"></a> [vpc_description](#input_vpc_description) | Description of VPC. | `string` |
| <a name="input_vpc_routing_mode"></a> [vpc_routing_mode](#input_vpc_routing_mode) | Network-wide routing mode to use (valid: REGIONAL, GLOBAL). | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_id"></a> [private_subnet_id](#output_private_subnet_id) | The ID of Private subnet. |
| <a name="output_private_subnet_name"></a> [private_subnet_name](#output_private_subnet_name) | The name of Private subnet. |
| <a name="output_public_subnet_id"></a> [public_subnet_id](#output_public_subnet_id) | The ID of public subnet. |
| <a name="output_public_subnet_name"></a> [public_subnet_name](#output_public_subnet_name) | The name of Public subnet. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output_vpc_name) | VPC name. |
<!-- END_TF_DOCS -->
