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
    
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | ../../../resources/gcp/network/cloud_nat | n/a |
| <a name="module_private_subnet"></a> [private\_subnet](#module\_private\_subnet) | ../../../resources/gcp/network/subnet | n/a |
| <a name="module_public_subnet"></a> [public\_subnet](#module\_public\_subnet) | ../../../resources/gcp/network/subnet | n/a |
| <a name="module_router"></a> [router](#module\_router) | ../../../resources/gcp/network/router | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../../resources/gcp/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_credentials_file_path"></a> [credentials\_file\_path](#input\_credentials\_file\_path) | The path of a GCP service account key file in JSON format. | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | GCP project ID to manage resources. | `string` | n/a | yes |
| <a name="input_private_subnet_cidr"></a> [private\_subnet\_cidr](#input\_private\_subnet\_cidr) | Range of internal addresses. | `string` | `"192.168.1.0/24"` | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | Range of internal addresses. | `string` | `"192.168.0.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region where the resources will be created. | `string` | n/a | yes |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | GCP stack name, will be used for tagging resources. | `string` | `"spectrum-scale"` | no |
| <a name="input_vpc_description"></a> [vpc\_description](#input\_vpc\_description) | Description of VPC. | `string` | `"This VPC is used by IBM Spectrum Scale"` | no |
| <a name="input_vpc_routing_mode"></a> [vpc\_routing\_mode](#input\_vpc\_routing\_mode) | Network-wide routing mode to use (valid: REGIONAL, GLOBAL). | `string` | `"GLOBAL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | The ID of Private subnet. |
| <a name="output_private_subnet_name"></a> [private\_subnet\_name](#output\_private\_subnet\_name) | The name of Private subnet. |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | The ID of public subnet. |
| <a name="output_public_subnet_name"></a> [public\_subnet\_name](#output\_public\_subnet\_name) | The name of Public subnet. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC name. |

<!-- END_TF_DOCS -->


4. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

