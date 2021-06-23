# Usage - Google Cloud Platform (GCP)

## Template Parameters

  * [New VPC](gen/gcp_new_vpc/README.md)
  * [Existing VPC](gen/gcp_existing_vpc/README.md)

## Before Starting

Ensure that you have configured your GCP public cloud credentials:

1. [Install gcloud CLI](https://cloud.google.com/sdk/gcloud)
2. [Configure gsutil](https://cloud.google.com/storage/docs/gsutil_install#authenticate)
3. [Create service account](https://cloud.google.com/docs/authentication/getting-started)
   > GCP Console -> IAM & Admin -> Service Accounts -> Create Service Account (Ensure the created service account has sufficient permissions to create resources).

   > Select the created service account -> Actions -> Create key (Download key in JSON format. Make note of key path.)
4. [Create or use a GCP project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
   > GCP Console -> IAM & Admin -> Manage Resources -> Create Project (Make note of project-id)

### Configure terraform GCS backend

The following steps will provision GCP resources (**new GCS bucket**) required for enabling GCS
backend for terraform. For more details, refer to [Terraform GCS backend](https://www.terraform.io/docs/backends/types/gcs.html).

1. Change working directory to `gcp_scale_templates/prepare_tf_gcs_backend`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/prepare_tf_gcs_backend
    ```
2. Create terraform variable definitions file (`prepare_tf_gcs_backend.auto.tfvars.json`) and provide infrastructure inputs.

    (Below is a sample.)
    ```
        $ cat prepare_tf_gcs_backend.auto.tfvars.json
        {
            "region": "us-east1",
            "location": "US",
            "gcp_project_id": "spectrum-scale",
            "credentials_file_path": "/root/gcp_data/spectrum-scale.json",
            "bucket_name": "gcsbucket"
        }
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

## New VPC Template

The following steps will provision GCP resources (**new VPC, Bastion, compute and storage instances**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `gcp_new_vpc_scale/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/gcp_new_vpc_scale/
    ```
2. Create terraform GCS backend config file (`gcs_backend_config`) and provide inputs.

    (Below is a sample.)

    ```
        $ echo "bucket = \"gcsbucket\"" > gcs_backend_config
        $ echo "prefix = \"terraform/state\"" >> gcs_backend_config
        $ echo "credentials = \"/root/gcp_data/spectrum-scale.json\"" >> gcs_backend_config
    ```

3. Create terraform variable definitions file (`gcp_new_vpc_scale_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [GCP New VPC Template Input Parameters](docs/gcp_new_vpc/README.md#inputs).)

    ```
    $ cat gcp_new_vpc_scale_inputs.auto.tfvars.json
    {
        "region": "us-east1",
        "zones": ["us-east1-b", "us-east1-c"],
        "stack_name": "spectrum-scale",
        "gcp_project_id": "spectrum-scale",
        "credentials_file_path": "/root/gcp_data/spectrum-scale.json",
        "total_storage_instances": 2,
        "total_compute_instances": 2,
        "data_disks_per_instance": 2,
        "instances_ssh_key_path": "/root/.ssh/id_rsa.pub",
        "bastion_machine_type": "n1-standard-1",
        "compute_machine_type": "n1-standard-1",
        "storage_machine_type": "n1-standard-1",
        "bastion_boot_image": "gce-uefi-images/ubuntu-1804-lts",
        "compute_boot_image": "gce-uefi-images/ubuntu-1804-lts",
        "storage_boot_image": "gce-uefi-images/ubuntu-1804-lts",
        "operator_email": "serviceuser@spectrum-scale.iam.gserviceaccount.com"
    }
    ```
    | Note: In case of single availability zone, provide a single value for the `zones` keyword. Ex: `"zones"=["us-east1-b"]` |
    | --- |

4. Run `terraform init -backend-config=gcs_backend_config` and `terraform apply -auto-approve` to provision resources.

## Existing VPC Template

The following steps will provision GCP resources (**compute and storage instances in existing VPC**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `instance_template/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/gcp_scale_templates/sub_modules/instance_template/
    ```
2. Create terraform GCS backend config file (`gcs_backend_config`) and provide inputs.

   (Below is a sample.)

    ```
        $ echo "bucket = \"gcsbucket\"" > gcs_backend_config
        $ echo "prefix = \"terraform/state\"" >> gcs_backend_config
        $ echo "credentials = \"/root/gcp_data/spectrum-scale.json\"" >> gcs_backend_config
    ```

3. Create terraform variable definitions file (`gcp_scale_instances_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [GCP Existing VPC Template Input Parameters](docs/gcp_existing_vpc/README.md#inputs).)

    ```
    $ cat gcp_scale_instances_inputs.auto.tfvars.json
    {
        "region": "us-east1",
        "zones": ["us-east1-b", "us-east1-c"],
        "stack_name": "spectrum-scale",
        "gcp_project_id": "spectrum-scale",
        "credentials_file_path": "/root/gcp_data/spectrum-scale.json",
        "total_storage_instances": 2,
        "total_compute_instances": 2,
        "data_disks_per_instance": 2,
        "private_subnet_name": "spectrum-scale-private-subnet",
        "instances_ssh_key_path": "/root/.ssh/id_rsa.pub",
        "bastion_machine_type": "n1-standard-1",
        "compute_machine_type": "n1-standard-1",
        "storage_machine_type": "n1-standard-1",
        "compute_boot_image": "gce-uefi-images/ubuntu-1804-lts",
        "storage_boot_image": "gce-uefi-images/ubuntu-1804-lts",
        "operator_email": "serviceuser@spectrum-scale.iam.gserviceaccount.com"
    }
    ```

    | Note: In case of single availability zone, provide a single value for the `zone` keyword. Ex: `"zones"=["us-east1-b"]` |
    | --- |

4. Run `terraform init -backend-config=gcs_backend_config` and `terraform apply -auto-approve` to provision resources.
