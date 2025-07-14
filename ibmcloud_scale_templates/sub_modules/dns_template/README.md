# Configure IBM Cloud DNS

Below steps will provision IBM Cloud DNS required for IBM Spectrum Scale cloud solution.

1. Change working directory to `ibmcloud_scale_templates/sub_modules/dns_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/dns_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example :

    ```json
    {
        "cluster_type": "Combined-compute-storage",
        "create_dns_zone": true,
        "ibmcloud_api_key": "xxx",
        "resource_group_name": "test-rg",
        "resource_prefix": "test-vpc",
        "vpc_compute_cluster_dns_zone": "compscale.com",
        "vpc_create_separate_subnets": true,
        "vpc_dns_tags": [],
        "vpc_ref": "r013-b423-a1342-c232",
        "vpc_region": "us-south",
        "vpc_storage_cluster_dns_zone": "strgscale.com"
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
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_create_dns_zone"></a> [create_dns_zone](#input_create_dns_zone) | Flag to represent if a new private DNS zone needs to be created or reused. | `bool` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a resource group in which the resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
| <a name="input_vpc_compute_cluster_dns_zone"></a> [vpc_compute_cluster_dns_zone](#input_vpc_compute_cluster_dns_zone) | IBM Cloud DNS zone name. | `string` |
| <a name="input_vpc_create_separate_subnets"></a> [vpc_create_separate_subnets](#input_vpc_create_separate_subnets) | Flag to select if separate private subnet to be created for compute cluster. | `bool` |
| <a name="input_vpc_dns_tags"></a> [vpc_dns_tags](#input_vpc_dns_tags) | Additional tags for the DNS zone. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id to be associated with the DNS zone. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc. | `string` |
| <a name="input_vpc_storage_cluster_dns_zone"></a> [vpc_storage_cluster_dns_zone](#input_vpc_storage_cluster_dns_zone) | IBM Cloud DNS zone name. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_dns_service_id"></a> [vpc_compute_cluster_dns_service_id](#output_vpc_compute_cluster_dns_service_id) | IBM Cloud DNS compute cluster resource instance server ID. |
| <a name="output_vpc_compute_dns_zone_id"></a> [vpc_compute_dns_zone_id](#output_vpc_compute_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_storage_cluster_dns_service_id"></a> [vpc_storage_cluster_dns_service_id](#output_vpc_storage_cluster_dns_service_id) | IBM Cloud DNS storage cluster resource instance server ID. |
| <a name="output_vpc_storage_dns_zone_id"></a> [vpc_storage_dns_zone_id](#output_vpc_storage_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
<!-- END_TF_DOCS -->
