# Configure Managed AWS AD

The below steps will provision the managed AWS AD service required for the IBM Spectrum Scale cloud solution.

1. Change the working directory to `aws_scale_templates/sub_modules/auth_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/aws_scale_templates/sub_modules/auth_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example-1:

    ```cli
    cat <<EOF > inputs.auto.tfvars.json
    {
	    "create_cloud_managed_auth": true,
	    "managed_ad_dns_name": "corp.example.com",
	    "managed_ad_password": "Passw0rd",
	    "managed_ad_size": "Small",
	    "managed_ad_subnet_refs": ["subnet-0fb8161c215", "subnet-0e7f69a18"],
	    "vpc_region": "us-east-2",
	    "vpc_ref": "vpc-06ba11cf6f0e5a374"
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
| <a name="input_create_cloud_managed_auth"></a> [create_cloud_managed_auth](#input_create_cloud_managed_auth) | Flag to represent if a cloud-managed auth service needs to be created or customer managed auth service needs to be created. | `bool` |
| <a name="input_managed_ad_dns_name"></a> [managed_ad_dns_name](#input_managed_ad_dns_name) | Managed directory DNS name | `string` |
| <a name="input_managed_ad_password"></a> [managed_ad_password](#input_managed_ad_password) | Managed directory (AD) password | `string` |
| <a name="input_managed_ad_size"></a> [managed_ad_size](#input_managed_ad_size) | Managed directory (AD) size | `string` |
| <a name="input_managed_ad_subnet_refs"></a> [managed_ad_subnet_refs](#input_managed_ad_subnet_refs) | Managed directory (AD) subnets (). | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id to be associated with the DNS zone. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_ad_access_url"></a> [managed_ad_access_url](#output_managed_ad_access_url) | Managed AD access url. |
| <a name="output_managed_ad_dns_ip_addresses"></a> [managed_ad_dns_ip_addresses](#output_managed_ad_dns_ip_addresses) | Managed AD DNS ip addresses. |
| <a name="output_managed_ad_security_group_ref"></a> [managed_ad_security_group_ref](#output_managed_ad_security_group_ref) | Managed AD security group reference. |
<!-- END_TF_DOCS -->
