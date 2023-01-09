# Configure GCP resources (compute and storage instances in existing VPC)

The following steps will provision GCP resources (compute and storage instances in existing VPC) and configure the IBM Spectrum Scale cloud solution.

1. Change the working directory to `gcp_scale_templates/sub_modules/instance_template/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/sub_modules/instance_template/
    ```
2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    | Note: In case of multi availability zone, provide 3 AZ values for the `vpc_availability_zones` keyword. Ex: `"vpc_availability_zones"=[ "us-central1-a" , "us-central1-b" , "us-central1-c"]` |
    | --- |

    Minimal Example-1 (create three compute cluster only):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 0,
        "total_compute_cluster_instances": 3,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : [],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0"]
    }
    EOF
    ```

    Minimal Example-2 (create three storage cluster only):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",   // Use an existing public ssh path
        "total_storage_cluster_instances": 3,
        "total_compute_cluster_instances": 0,
        "data_disks_per_instance" : "2",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0"],
        "vpc_compute_cluster_private_subnets" : []
    }
    EOF
    ```

    Minimal Example-3 (create three compute cluster with multi zone):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a" , "us-central1-b"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 0,
        "total_compute_cluster_instances": 3,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : [],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0" , "spectrum-scale-comp-pvt-subnet-1"]
    }
    EOF
    ```

    Minimal Example-4 (create three storage cluster only):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : ["us-central1-a" , "us-central1-b"],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 3,
        "total_compute_cluster_instances": 0,
        "data_disks_per_instance" : "2",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0" ,"spectrum-scale-strg-pvt-subnet-1"],
        "vpc_compute_cluster_private_subnets" : []
    }
    EOF
    ```

    Minimal Example-5 (create compute and storage cluster in multi zone ):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : [ "us-central1-a" , "us-central1-b" ],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 2,
        "total_compute_cluster_instances": 2,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0" ,"spectrum-scale-strg-pvt-subnet-1" ],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0" , "spectrum-scale-comp-pvt-subnet-1" ]
    }
    EOF
    ```

    Minimal Example-6 (create compute and storage cluster with one tie breaker for 3 AZ ):

    ```cli
    cat <<EOF > terraform.tfvars.json
    {
        "vpc_region": "us-central1",
        "vpc_availability_zones" : [ "us-central1-a" , "us-central1-b" , "us-central1-c" ],
        "gcp_project_id": "spectrum-scale-XXXX",                          // Use an existing gcp project id
        "credentials_file_path": "/home/gcp_data/spectrum-scale.json",    // Use service account credential file path
        "operator_email": "example@xyz.com",                              // Use an existing service account email id
        "instances_ssh_public_key_path" : "/home/.ssh/id_ed25519.pub",    // Use an existing public ssh path
        "total_storage_cluster_instances": 2,
        "total_compute_cluster_instances": 2,
        "data_disks_per_instance" : "1",
        "data_disk_size" : "200",
        "vpc_storage_cluster_private_subnets" : ["spectrum-scale-strg-pvt-subnet-0" ,"spectrum-scale-strg-pvt-subnet-1" , "spectrum-scale-strg-pvt-subnet-2"],
        "vpc_compute_cluster_private_subnets" : ["spectrum-scale-comp-pvt-subnet-0" , "spectrum-scale-comp-pvt-subnet-1", "spectrum-scale-strg-pvt-subnet-2"]
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
| <a name="module_bastion_compute_instances_firewall"></a> [bastion\_compute\_instances\_firewall](#module\_bastion\_compute\_instances\_firewall) | ../../../resources/gcp/network/firewall/allow_bastion_internal | n/a |
| <a name="module_compute_cluster_instances"></a> [compute\_cluster\_instances](#module\_compute\_cluster\_instances) | ../../../resources/gcp/compute/vm_instance_multiple | n/a |
| <a name="module_compute_instances_firewall"></a> [compute\_instances\_firewall](#module\_compute\_instances\_firewall) | ../../../resources/gcp/network/firewall/allow_internal | n/a |
| <a name="module_generate_compute_cluster_keys"></a> [generate\_compute\_cluster\_keys](#module\_generate\_compute\_cluster\_keys) | ../../../resources/common/generate_keys | n/a |
| <a name="module_generate_storage_cluster_keys"></a> [generate\_storage\_cluster\_keys](#module\_generate\_storage\_cluster\_keys) | ../../../resources/common/generate_keys | n/a |
| <a name="module_storage_cluster_instances"></a> [storage\_cluster\_instances](#module\_storage\_cluster\_instances) | ../../../resources/gcp/compute/vm_instance_multiple | n/a |
| <a name="module_storage_cluster_tie_breaker_instance"></a> [storage\_cluster\_tie\_breaker\_instance](#module\_storage\_cluster\_tie\_breaker\_instance) | ../../../resources/gcp/compute/vm_instance_multiple | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_subnet_cidr"></a> [bastion\_subnet\_cidr](#input\_bastion\_subnet\_cidr) | Range of internal addresses. | `string` | `"35.235.240.0/20"` | no |
| <a name="input_compute_boot_disk_size"></a> [compute\_boot\_disk\_size](#input\_compute\_boot\_disk\_size) | Compute instances boot disk size in gigabytes. | `number` | `100` | no |
| <a name="input_compute_boot_disk_type"></a> [compute\_boot\_disk\_type](#input\_compute\_boot\_disk\_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| <a name="input_compute_boot_image"></a> [compute\_boot\_image](#input\_compute\_boot\_image) | Image from which to initialize Spectrum Scale compute instances. | `string` | `"ubuntu-os-cloud/ubuntu-1804-lts"` | no |
| <a name="input_compute_instance_name_prefix"></a> [compute\_instance\_name\_prefix](#input\_compute\_instance\_name\_prefix) | Compute instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])? | `string` | `"compute-scale"` | no |
| <a name="input_compute_instance_tags"></a> [compute\_instance\_tags](#input\_compute\_instance\_tags) | List of tags to attach to the compute instance. | `list(string)` | `[]` | no |
| <a name="input_compute_machine_type"></a> [compute\_machine\_type](#input\_compute\_machine\_type) | GCP instance machine type to create Spectrum Scale compute instances. | `string` | `"n1-standard-1"` | no |
| <a name="input_credentials_file_path"></a> [credentials\_file\_path](#input\_credentials\_file\_path) | The path of a GCP service account key file in JSON format. | `string` | n/a | yes |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Data disk size in gigabytes. | `string` | `500` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| <a name="input_data_disks_per_instance"></a> [data\_disks\_per\_instance](#input\_data\_disks\_per\_instance) | Number of data disks to be attached to each storage instance. | `number` | `1` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | GCP project ID to manage resources. | `string` | n/a | yes |
| <a name="input_instances_ssh_public_key_path"></a> [instances\_ssh\_public\_key\_path](#input\_instances\_ssh\_public\_key\_path) | SSH public key local path. | `string` | n/a | yes |
| <a name="input_instances_ssh_user_name"></a> [instances\_ssh\_user\_name](#input\_instances\_ssh\_user\_name) | Name of the administrator to access the bastion instance. | `string` | `"gcpadmin"` | no |
| <a name="input_operator_email"></a> [operator\_email](#input\_operator\_email) | GCP service account e-mail address. | `string` | n/a | yes |
| <a name="input_private_subnet_cidr"></a> [private\_subnet\_cidr](#input\_private\_subnet\_cidr) | Range of internal addresses. | `string` | `"10.0.1.0/24"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | GCP stack name, will be used for tagging resources. | `string` | `"spectrum-scale"` | no |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | List of service scopes. | `list(string)` | <pre>[<br>  "cloud-platform"<br>]</pre> | no |
| <a name="input_storage_boot_disk_size"></a> [storage\_boot\_disk\_size](#input\_storage\_boot\_disk\_size) | Storage instances boot disk size in gigabytes. | `number` | `100` | no |
| <a name="input_storage_boot_disk_type"></a> [storage\_boot\_disk\_type](#input\_storage\_boot\_disk\_type) | GCE disk type (valid: pd-standard, pd-ssd). | `string` | `"pd-standard"` | no |
| <a name="input_storage_boot_image"></a> [storage\_boot\_image](#input\_storage\_boot\_image) | Image from which to initialize Spectrum Scale storage instances. | `string` | `"ubuntu-os-cloud/ubuntu-1804-lts"` | no |
| <a name="input_storage_instance_name_prefix"></a> [storage\_instance\_name\_prefix](#input\_storage\_instance\_name\_prefix) | Storage instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])? | `string` | `"storage-scale"` | no |
| <a name="input_storage_instance_tags"></a> [storage\_instance\_tags](#input\_storage\_instance\_tags) | List of tags to attach to the compute instance. | `list(string)` | <pre>[<br>  "spectrum-scale-allow-bastion-internal",<br>  "spectrum-scale-allow-internal"<br>]</pre> | no |
| <a name="input_storage_machine_type"></a> [storage\_machine\_type](#input\_storage\_machine\_type) | GCP instance machine type to create Spectrum Scale storage instances. | `string` | `"n1-standard-1"` | no |
| <a name="input_total_compute_cluster_instances"></a> [total\_compute\_cluster\_instances](#input\_total\_compute\_cluster\_instances) | Number of instances to be launched for compute instances. | `number` | `2` | no |
| <a name="input_total_storage_cluster_instances"></a> [total\_storage\_cluster\_instances](#input\_total\_storage\_cluster\_instances) | Number of instances to be launched for storage instances. | `number` | `2` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | A list of availability zones names or ids in the region. | `list(string)` | `null` | no |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc\_compute\_cluster\_private\_subnets](#input\_vpc\_compute\_cluster\_private\_subnets) | List of IDs of compute cluster private subnets. | `list(string)` | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | GCP VPC name. | `string` | `"spectrum-scale-vpc"` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | GCP region where the resources will be created. | `string` | `null` | no |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc\_storage\_cluster\_private\_subnets](#input\_vpc\_storage\_cluster\_private\_subnets) | List of IDs of storage cluster private subnets. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_cluster_instance_details"></a> [compute\_cluster\_instance\_details](#output\_compute\_cluster\_instance\_details) | GCP compute instance details. |
| <a name="output_storage_cluster_tie_breaker_instance_details"></a> [storage\_cluster\_tie\_breaker\_instance\_details](#output\_storage\_cluster\_tie\_breaker\_instance\_details) | GCP compute desc instance details. |
| <a name="output_stroage_cluster_instance_details"></a> [stroage\_cluster\_instance\_details](#output\_stroage\_cluster\_instance\_details) | GCP compute instance details. |
<!-- END_TF_DOCS -->
