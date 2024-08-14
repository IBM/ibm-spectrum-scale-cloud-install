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
| <a name="input_create_dns_zone"></a> [create_dns_zone](#input_create_dns_zone) | Flag to represent if a new private DNS zone needs to be created or reused. | `bool` |
| <a name="input_vpc_compute_cluster_dns_zone"></a> [vpc_compute_cluster_dns_zone](#input_vpc_compute_cluster_dns_zone) | Route53 DNS zone name/id (incase of new creation use name, incase of association use id). | `string` |
| <a name="input_vpc_compute_cluster_dns_zone_description"></a> [vpc_compute_cluster_dns_zone_description](#input_vpc_compute_cluster_dns_zone_description) | DNS zone description | `string` |
| <a name="input_vpc_dns_tags"></a> [vpc_dns_tags](#input_vpc_dns_tags) | Additional tags for the DNS zone | `map(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id to be associated with the DNS zone. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |
| <a name="input_vpc_reverse_dns_zone"></a> [vpc_reverse_dns_zone](#input_vpc_reverse_dns_zone) | Route53 DNS zone/id (incase of new creation use name, incase of association use id). | `string` |
| <a name="input_vpc_reverse_dns_zone_description"></a> [vpc_reverse_dns_zone_description](#input_vpc_reverse_dns_zone_description) | Route53 DNS zone description. | `string` |
| <a name="input_vpc_storage_cluster_dns_zone"></a> [vpc_storage_cluster_dns_zone](#input_vpc_storage_cluster_dns_zone) | Route53 DNS zone name/id (incase of new creation use name, incase of association use id). | `string` |
| <a name="input_vpc_storage_cluster_dns_zone_description"></a> [vpc_storage_cluster_dns_zone_description](#input_vpc_storage_cluster_dns_zone_description) | DNS zone description | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_dns_zone"></a> [vpc_compute_cluster_dns_zone](#output_vpc_compute_cluster_dns_zone) | Route53 DNS zone name/id. |
| <a name="output_vpc_compute_dns_zone_id"></a> [vpc_compute_dns_zone_id](#output_vpc_compute_dns_zone_id) | Route53 zone id. |
| <a name="output_vpc_reverse_dns_zone"></a> [vpc_reverse_dns_zone](#output_vpc_reverse_dns_zone) | Route53 DNS zone name/id. |
| <a name="output_vpc_reverse_dns_zone_id"></a> [vpc_reverse_dns_zone_id](#output_vpc_reverse_dns_zone_id) | Route53 zone id. |
| <a name="output_vpc_storage_cluster_dns_zone"></a> [vpc_storage_cluster_dns_zone](#output_vpc_storage_cluster_dns_zone) | Route53 DNS zone name/id. |
| <a name="output_vpc_storage_dns_zone_id"></a> [vpc_storage_dns_zone_id](#output_vpc_storage_dns_zone_id) | Route53 zone id. |
<!-- END_TF_DOCS -->
