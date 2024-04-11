# Configure GCP cloud dns zones and associate with network

The below steps will provision the GCP cloud dns required for the IBM Spectrum Scale cloud solution.

1. Change the working directory to `gcp_scale_templates/sub_modules/dns_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/sub_modules/dns_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example-1:

    ```cli
    cat <<EOF > combined_1az.auto.tfvars.json
    {
	    "cluster_type": "Combined-compute-storage",
        "project_id": "spectrum-scale-XXXXXX",
        "credential_json_path": "/home/gcp_data/spectrum-scale.json",
        "create_dns_zone": true,
        "vpc_compute_cluster_dns_zone": "ibm-storage-scale-comp-zone",
        "vpc_compute_cluster_dns_zone_description": "This zone is created by (cloudkit) for IBM Storage Scale (ibm-storage-scale) operations.",
	    "vpc_compute_cluster_forward_dns_zone": "ibm-storage-scale.compscale.com",
	    "vpc_ref": "ibm-storage-scale",
    	"vpc_region": "us-central1",
	    "vpc_reverse_dns_name": "10.in-addr.arpa",
	    "vpc_reverse_dns_zone": "ibm-storage-scale-reverse",
	    "vpc_reverse_dns_zone_description": "This zone is created by (cloudkit) for IBM Storage Scale (ibm-storage-scale) operations.",
	    "vpc_storage_cluster_dns_zone": "ibm-storage-scale-strg-zone",
	    "vpc_storage_cluster_dns_zone_description": "This zone is created by (cloudkit) for IBM Storage Scale (ibm-storage-scale) operations.",
	    "vpc_storage_cluster_forward_dns_zone": "ibm-storage-scale.strgscale.com",
    }
    EOF
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | ~> 5.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_credential_json_path"></a> [credential_json_path](#input_credential_json_path) | The path of a GCP service account key file in JSON format. | `string` |
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID to manage resources. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
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
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_compute_nat_gateways"></a> [vpc_compute_nat_gateways](#output_vpc_compute_nat_gateways) | List of IDs of compute cluster nat gateway. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets. |
| <a name="output_vpc_ref"></a> [vpc_ref](#output_vpc_ref) | VPC name. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
| <a name="output_vpc_storage_nat_gateways"></a> [vpc_storage_nat_gateways](#output_vpc_storage_nat_gateways) | List of IDs of storage cluster nat gateway. |
<!-- END_TF_DOCS -->
