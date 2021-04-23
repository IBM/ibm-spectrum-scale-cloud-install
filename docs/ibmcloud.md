# Usage - IBM Cloud

## Template Parameters

  * [New VPC](gen/ibmcloud_new_vpc/README.md)
  * [Existing VPC](gen/ibmcloud_existing_vpc/README.md)

## Before Starting

Ensure that you have configured your IBM Cloud public cloud credentials:

1. [Getting started with IBM Cloud Terraform Provider](https://cloud.ibm.com/docs/terraform?topic=terraform-getting-started)
2. [Install IBM Cloud CLI](https://cloud.ibm.com/docs/cli)
3. [Configure IBM Cloud API Key](https://cloud.ibm.com/docs/account?topic=account-userapikey).

## New VPC Template

The following steps will provision IBM Cloud resources (**new VPC, Bastion, compute and storage instances**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `ibmcloud_new_vpc_scale`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/ibmcloud_new_vpc_scale
    ```

2. Create terraform variable definitions file (`ibmcloud_new_vpc_scale_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [IBM Cloud New VPC Template Input Parameters](docs/ibmcloud_new_vpc/README.md#inputs).)

    ```
    $ cat ibmcloud_new_vpc_scale_inputs.auto.tfvars.json
    {
        "region": "us-east",
        "zones": ["us-east-1", "us-east-2", "us-east-3"],
        "stack_name": "spectrum-scale",
        "bastion_key_name": "userkey-ibmcloud",
        "ibmcloud_api_key": "76Q1qJLkRW7GE1Yv6YOgnkQqoK7A",
        "total_storage_instances": 4,
        "total_compute_instances": 2,
        "data_disks_per_instance": 3,
        "instance_key_name": "userkey-ibmcloud"
    }
    ```
    | Note: In case of single availability zone, provide a single value for the `availability_zone` keyword. Ex: `"availability_zones"=["us-east-1"]` |
    | --- |

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

## Existing VPC Template

The following steps will provision IBM Cloud resources (**compute and storage instances in existing VPC**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `instance_template/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template
    ```

2. Create terraform variable definitions file (`ibmcloud_scale_instances_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [IBM Cloud Existing VPC Template Input Parameters](docs/ibmcloud_existing_vpc/README.md#inputs).)

    ```
    $ cat ibmcloud_scale_instances_inputs.auto.tfvars.json
    {
        "region": "us-east",
        "zones": ["us-east-1", "us-east-2", "us-east-3"],
        "stack_name": "spectrum-scale",
        "instance_key_name": "userkey-ibmcloud",
        "ibmcloud_api_key": "76Q1qJLkRW7GE1Yv6YOgnkQqoK7A",
        "vpc_id": "r014-aeb71795-9f62-461e-b27d-ce8d8d2acb9a",
        "cidr_block": ["10.241.0.0/24", "10.241.64.0/24", "10.241.128.0/24"],
        "private_subnet_ids": ["0757-a6739b33-0387-4adf-a190-81dcc1c118ba", "0767-d7acf979-7586-4517-87ce-1d9051bc0892",
                               "0777-e6b110ed-6e2c-442c-9b9c-2331d4f07aa3"],
        "data_disks_per_instance": 3,
        "total_compute_instances": "2",
        "total_storage_instances": "2"
    }
    ```

    | Note: In case of single availability zone, provide a single value for the `availability_zone` keyword and one subnet to `private_subnet_ids` keyword. Ex: `"availability_zones"=["us-east-1"], "private_subnet_ids"=["0757-a6739b33-0387-4adf-a190-81dcc1c118ba"]` |
    | --- |

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.
