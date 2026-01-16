# New VPC Template

The following steps will provision GCP resources (*new vpc, bastion, compute and storage instances*) and configures IBM Spectrum Scale cloud solution.

1. Change working directory to `gcp_scale_templates/gcp_new_vpc_scale/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/gcp_new_vpc_scale/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones"=["us-east-1a", "us-east-1b", "us-east-1c"]` |
    | --- |

    Minimal Example-1 (create compute, storage cluster with remote mount configuration):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones": ["us-central1-a"],
        "gcp_project_id": "spectrum-scale-XXXX",                            // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",      // Use service account credential file path
        "operator_email": "example@xyz.com",                                // Use an existing service account email id
        "bastion_ssh_key_path": "/home/.ssh/id_ed25519.pub"                 // Use an existing public key pair
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519_i.pub",    // Use an existing public key pair
        "bucket_name"     : "scale-default-bucket",                         // Use an existing gcp bucket for saving terraform config
        "resource_prefix" : "scale-test",
        "vpc_cidr_block": "10.0.0.0/16",
        "vpc_public_subnets_cidr_blocks": ["10.0.1.0/24"],
        "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.0.5.0/24"],
        "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.0.7.0/24"],
        "total_storage_cluster_instances": 3,
        "total_compute_cluster_instances": 0,
        "data_disks_per_instance" : "3",
        "data_disk_size" : "500",
        "data_disk_type" : "pd-standard",
        "create_remote_mount_cluster" : "false",
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
| <a name="module_bastion_module"></a> [bastion\_module](#module\_bastion\_module) | ../sub_modules/bastion_template | n/a |
| <a name="module_instance_modules"></a> [instance\_modules](#module\_instance\_modules) | ../sub_modules/instance_template | n/a |
| <a name="module_vpc_module"></a> [vpc\_module](#module\_vpc\_module) | ../sub_modules/vpc_template | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ssh_key_path"></a> [bastion\_ssh\_key\_path](#input\_bastion\_ssh\_key\_path) | SSH public key local path, will be used to login bastion instance. | `string` | n/a | yes |
| <a name="input_create_remote_mount_cluster"></a> [create\_remote\_mount\_cluster](#input\_create\_remote\_mount\_cluster) | Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup. | `bool` | `null` | no |
| <a name="input_credentials_file_path"></a> [credentials\_file\_path](#input\_credentials\_file\_path) | The path of a GCP service account key file in JSON format. | `string` | n/a | yes |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Data disk size in gigabytes. | `string` | `500` | no |
| <a name="input_data_disks_per_instance"></a> [data\_disks\_per\_instance](#input\_data\_disks\_per\_instance) | Number of data disks to be attached to each storage instance. | `number` | `1` | no |
| <a name="input_filesystem_block_size"></a> [filesystem\_block\_size](#input\_filesystem\_block\_size) | Filesystem block size. | `string` | `null` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | GCP project ID to manage resources. | `string` | `null` | no |
| <a name="input_instances_ssh_public_key_path"></a> [instances\_ssh\_public\_key\_path](#input\_instances\_ssh\_public\_key\_path) | SSH public key local path. | `string` | n/a | yes |
| <a name="input_operator_email"></a> [operator\_email](#input\_operator\_email) | GCP service account e-mail address. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix is added to all resources that are created. | `string` | `"spectrum-scale"` | no |
| <a name="input_total_compute_cluster_instances"></a> [total\_compute\_cluster\_instances](#input\_total\_compute\_cluster\_instances) | Number of instances to be launched for compute instances. | `number` | `2` | no |
| <a name="input_total_storage_cluster_instances"></a> [total\_storage\_cluster\_instances](#input\_total\_storage\_cluster\_instances) | Number of instances to be launched for storage instances. | `number` | `2` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | A list of availability zones names or ids in the region. | `list(string)` | `null` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC. | `string` | `null` | no |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc\_compute\_cluster\_private\_subnets\_cidr\_blocks](#input\_vpc\_compute\_cluster\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of compute private subnets. | `list(string)` | `null` | no |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc\_public\_subnets\_cidr\_blocks](#input\_vpc\_public\_subnets\_cidr\_blocks) | Range of internal addresses. | `list(string)` | `null` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | GCP region where the resources will be created. | `string` | `null` | no |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc\_storage\_cluster\_private\_subnets\_cidr\_blocks](#input\_vpc\_storage\_cluster\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of storage cluster private subnets. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instances_details"></a> [bastion\_instances\_details](#output\_bastion\_instances\_details) | Bastion instances details. |
| <a name="output_scale_instances_details"></a> [scale\_instances\_details](#output\_scale\_instances\_details) | Scale instances details. |
| <a name="output_vpc_details"></a> [vpc\_details](#output\_vpc\_details) | VPC details. |
<!-- END_TF_DOCS -->
