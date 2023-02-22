# Configure GCP VPC

The below steps will provision the GCP Bastion instance required for the IBM Spectrum Scale cloud solution.

1. Change the working directory to `gcp_scale_templates/sub_modules/bastion_template/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/sub_modules/bastion_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example:

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
         "bastion_zone": "us-central1-a",
         "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
         "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
         "operator_email": "example@xyz.com",                              // Use an existing service account email id
         "bastion_ssh_key_path": "/home/.ssh/id_ed25519.pub"               // Use an existing public key pair
    }
    EOF
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion_firewall"></a> [bastion\_firewall](#module\_bastion\_firewall) | ../../../resources/gcp/network/firewall/allow_bastion/ | n/a |
| <a name="module_bastion_instance"></a> [bastion\_instance](#module\_bastion\_instance) | ../../../resources/gcp/compute/bastion_instance/ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_boot_disk_size"></a> [bastion\_boot\_disk\_size](#input\_bastion\_boot\_disk\_size) | Bastion instance boot disk size in gigabytes. | `number` | `100` | no |
| <a name="input_bastion_boot_disk_type"></a> [bastion\_boot\_disk\_type](#input\_bastion\_boot\_disk\_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| <a name="input_bastion_boot_image"></a> [bastion\_boot\_image](#input\_bastion\_boot\_image) | Image from which to initialize bastion instance. | `string` | `"ubuntu-os-cloud/ubuntu-1804-lts"` | no |
| <a name="input_bastion_instance_name_prefix"></a> [bastion\_instance\_name\_prefix](#input\_bastion\_instance\_name\_prefix) | Bastion instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])? | `string` | `"bastion"` | no |
| <a name="input_bastion_instance_tags"></a> [bastion\_instance\_tags](#input\_bastion\_instance\_tags) | List of tags to attach to the bastion instance. | `list(string)` | <pre>[<br>  "spectrum-scale-bastion"<br>]</pre> | no |
| <a name="input_bastion_machine_type"></a> [bastion\_machine\_type](#input\_bastion\_machine\_type) | GCP instance machine type to create bastion instance. | `string` | `"n1-standard-1"` | no |
| <a name="input_bastion_network_tier"></a> [bastion\_network\_tier](#input\_bastion\_network\_tier) | The networking tier to be used for bastion instance (valid: PREMIUM or STANDARD) | `string` | `"STANDARD"` | no |
| <a name="input_bastion_source_range"></a> [bastion\_source\_range](#input\_bastion\_source\_range) | Firewall will allow only to traffic that has source IP address in these ranges. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_bastion_ssh_key_path"></a> [bastion\_ssh\_key\_path](#input\_bastion\_ssh\_key\_path) | SSH public key local path, will be used to login bastion instance. | `string` | n/a | yes |
| <a name="input_bastion_ssh_user_name"></a> [bastion\_ssh\_user\_name](#input\_bastion\_ssh\_user\_name) | Name of the administrator to access the bastion instance. | `string` | `"gcpadmin"` | no |
| <a name="input_bastion_zone"></a> [bastion\_zone](#input\_bastion\_zone) | Zone in which bastion machine should be created. | `string` | n/a | yes |
| <a name="input_credentials_file_path"></a> [credentials\_file\_path](#input\_credentials\_file\_path) | The path of a GCP service account key file in JSON format. | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | GCP project ID to manage resources. | `string` | `null` | no |
| <a name="input_public_subnet_name"></a> [public\_subnet\_name](#input\_public\_subnet\_name) | Public subnet name to attach the bastion interface. | `string` | `"spectrum-scale-public-subnet-0"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix is added to all resources that are created. | `string` | `"spectrum-scale"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | GCP VPC name | `string` | `"spectrum-scale-vpc"` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | GCP region where the resources will be created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_private_ip"></a> [bastion\_instance\_private\_ip](#output\_bastion\_instance\_private\_ip) | n/a |
| <a name="output_bastion_instance_public_ip"></a> [bastion\_instance\_public\_ip](#output\_bastion\_instance\_public\_ip) | n/a |
<!-- END_TF_DOCS -->
