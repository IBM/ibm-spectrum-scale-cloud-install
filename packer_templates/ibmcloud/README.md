# Prerequisites

1. Download the IBM Spectrum Scale Data Management Edition install package (from Fix Central) and zip all the gpfs rpms into /opt/IBM/5.1.1/rpms.zip

2. Download a pre-built [Packer binary](https://www.packer.io/downloads) for your operating system. 'packer_1.7.3' is the suggested version.

## Create IBM Cloud (packer) Image

Below steps will provision IBM Cloud VSI, installs IBM Spectrum Scale rpm's and creates a new image.

1. Change working directory to `packer_templates/ibmcloud/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/packer_templates/ibmcloud/
    ```

2. Create packer variable definitions file (`inputs.auto.pkrvars.hcl`) and provide infrastructure inputs.

    Minimal Example:

    ```jsonc
    $ cat inputs.auto.pkrvars.hcl
    ibm_api_key             = "ABC123"
    vpc_region              = "eu-de"
    resource_group_id       = "2f2d905672454325bf273e7818e843b3"
    vpc_subnet_id           = "02b7-4248ee57-cb20-4793-b234-13d2f0974f45"
    image_name              = "spectrumscalepacker"
    source_image_name       = "ibm-centos-8-3-minimal-amd64-3"
    ```

3. Run `packer build .` to create AMI.

<!-- BEGIN_TF_DOCS -->
## Useful Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the resulting AMI. Build will append additional information to keep it unique. | `string` | n/a | yes |
| <a name="input_source_image_name"></a> [source\_image\_name](#input\_source\_image\_name) | The source image name whose root volume will be copied and provisioned on the currently running instance. | `string` | n/a | yes |
| <a name="input_vsi_profile"></a> [vsi\_profile](#input\_vsi\_profile) | The VSI to use while building the AMI. | `string` | `"bx2d-2x8"` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region where operations will take place. Examples are us-east-1, us-west-2, etc. | `string` | n/a | yes |
| <a name="input_vpc_subnet_id"></a> [vpc\_subnet\_id](#input\_vpc\_subnet\_id) | The subnet ID to use for the instance. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The existing resource group id. | `string` | n/a | yes |
| <a name="input_ibm_api_key"></a> [ibm\_api\_key](#input\_ibm\_api\_key) | IBM Cloud API key. | `string` | n/a | yes |

<!-- END_TF_DOCS -->
