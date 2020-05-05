# Usage - Amazon Web Services (AWS)

## Template Parameters 

  * [New VPC](gen/aws_new_vpc/README.md)
  * [Existing VPC](gen/aws_existing_vpc/README.md)

## Before Starting

Ensure that you have configured your AWS public cloud credentials:

1. [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
2. [Create access keys for IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
3. [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration).

#### Warning: Each run of  `terraform apply` will generate a new SSH key and cause replacement of SSH key dependent resources. 

## New VPC Template

The following steps will provision AWS resources (**new VPC, Bastion, compute and storage instances**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `aws_new_vpc_scale/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/aws_scale_templates/aws_new_vpc_scale/
    ```

2. Create terraform variable definitions file (`aws_new_vpc_scale_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [AWS New VPC Template Input Parameters](docs/aws_new_vpc/README.md#inputs).)

    ```
    $ cat aws_new_vpc_scale_inputs.auto.tfvars.json
    {
        "region": "sa-east-1",
        "availability_zones": [
            "sa-east-1a",
            "sa-east-1c"
        ],
        "bucket_name": "<aws_bucket_name>",
        "bastion_image_name": "Amazon-Linux-HVM",
        "key_name": "<aws_key>",
        "compute_ami_id": "ami-048b2348ac2ccfc53",
        "storage_ami_id": "ami-048b2348ac2ccfc53",
        "compute_instance_type": "t2.micro",
        "storage_instance_type": "t2.micro",
        "total_compute_instances": "2",
        "total_storage_instances": "2",
        "ebs_volume_size": "500",
        "ebs_volume_type": "gp2",
        "ebs_volumes_per_instance": 3,
        "operator_email": "<operator@email.com>"
    }
    ```
    | Note: In case of single availability zone, provide a single value for the `availability_zone` keyword. Ex: `"availability_zones"=["sa-east-1a"]` |
    | --- |

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

## Existing VPC Template

The following steps will provision AWS resources (**compute and storage instances in existing VPC**) required for
IBM Spectrum Scale Cloud deployment.

1. Change working directory to `instance_template/`.

    ```
    $ cd ibm-spectrum-scale-cloud-install/aws_scale_templates/sub_modules/instance_template/
    ```

2. Create terraform variable definitions file (`aws_scale_instances_inputs.auto.tfvars.json`) and provide infrastructure inputs.

   (Below is a sample. For details related to input parameters, refer to [AWS Existing VPC Template Input Parameters](docs/aws_existing_vpc/README.md#inputs).)
    ```
    $ cat aws_scale_instances_inputs.auto.tfvars.json
    {
        "region": "sa-east-1",
        "availability_zones": [
            "sa-east-1a",
            "sa-east-1c"
        ],
        "bucket_name": "<aws_bucket_name>",
        "bastion_sec_group_id": "sg-05546f0e8c6ebd1ce",
        "private_instance_subnet_ids": ["subnet-03773a72bf9499420", "subnet-0bf0320b47f195f19"],
        "vpc_id": "vpc-04eef62f613ba98e0",
        "key_name": "<aws_key>",
        "compute_ami_id": "ami-048b2348ac2ccfc53",
        "storage_ami_id": "ami-048b2348ac2ccfc53",
        "compute_instance_type": "t2.micro",
        "storage_instance_type": "t2.micro",
        "ebs_volume_size": "10",
        "ebs_volume_type": "gp2",
        "ebs_volumes_per_instance": 3,
        "total_compute_instances": "2",
        "total_storage_instances": "2",
        "operator_email": "<operator@email.com>"
    }
    ```

    | Note: In case of single availability zone, provide a single value for the `availability_zone` keyword and one subnet to `private_instance_subnet_ids` keyword. Ex: `"availability_zones"=["sa-east-1a"], "private_instance_subnet_ids"=["subnet-03773a72bf9499420"]` |
    | --- |

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

