# IBM Cloud Bastion Host Template

This Terraform sub-module provisions a bastion host (jump server) in IBM Cloud VPC for secure access to private cluster instances.

## Overview

The bastion template creates:
- **Bastion Instance**: Virtual server with public IP for external access
- **Security Group**: Network rules allowing SSH access from specified CIDR blocks
- **Floating IP**: Public IP address for bastion access

## Purpose

The bastion host serves as a secure entry point to access private instances in your VPC:
- Acts as a jump server for SSH access to cluster nodes
- Provides a single point of entry for security management
- Enables secure file transfer to/from cluster instances
- Facilitates cluster administration and monitoring

## Prerequisites

- IBM Cloud VPC already created
- IBM Cloud API key with VPC permissions
- SSH key pair created in IBM Cloud
- Resource group configured

## Quick Start

### 1. Change Directory

```bash
cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/bastion_template/
```

### 2. Create Configuration File

Create `terraform.tfvars.json`:

```jsonc
{
    "ibmcloud_api_key": "your-ibm-cloud-api-key",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "scale-bastion",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "bastion_instance_type": "cx2-2x4",
    "bastion_image_ref": "r006-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bastion_public_key": "ssh-rsa AAAA...your-public-key-content...",
    "vpc_auto_scaling_group_subnets": ["0717-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
    "remote_cidr_blocks": ["x.x.x.x/x"]
}
```

### 3. Deploy Bastion

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Basic Bastion Host

```jsonc
{
    "ibmcloud_api_key": "your-ibm-cloud-api-key",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "bastion",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "bastion_instance_type": "cx2-2x4",
    "bastion_image_ref": "r006-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bastion_public_key": "ssh-rsa AAAA...your-public-key-content...",
    "vpc_auto_scaling_group_subnets": ["0717-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
    "remote_cidr_blocks": ["0.0.0.0/0"]
}
```

### Example 2: Restricted Access Bastion

```jsonc
{
    "ibmcloud_api_key": "your-ibm-cloud-api-key",
    "vpc_region": "us-east",
    "vpc_availability_zones": ["us-east-1"],
    "resource_prefix": "prod-bastion",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "bastion_instance_type": "cx2-4x8",
    "bastion_image_ref": "r006-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bastion_public_key": "ssh-rsa AAAA...your-public-key-content...",
    "vpc_auto_scaling_group_subnets": ["0717-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
    "remote_cidr_blocks": [
        "x.x.x.x/x",    // Office network
        "x.x.x.x/x"   // Admin workstation
    ]
}
```

## Usage

### Access Bastion Host

```bash
# Get bastion public IP addresses from Terraform output
terraform output bastion_public_ip_addresses

# SSH to bastion
ssh -i ~/.ssh/bastion-key vpcuser@<bastion-public-ip>
```

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output bastion_instance_autoscaling_group_id
terraform output bastion_instance_autoscaling_group_crn
terraform output bastion_public_ip_addresses
terraform output bastion_security_group_id
```

## Cleanup

```bash
# Destroy bastion resources
terraform destroy -auto-approve
```

---

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | 2.3.0 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | The ID of the resource group for bastion resources. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix added to all resource names for identification and organization (e.g., 'ibm-storage-scale'). | `string` |
| <a name="input_vpc_auto_scaling_group_subnets"></a> [vpc_auto_scaling_group_subnets](#input_vpc_auto_scaling_group_subnets) | List of subnets where the Auto Scaling Group will deploy the instances. | `list(string)` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where bastion and all resources will be deployed (e.g., 'us-east', 'us-south', 'eu-de'). | `string` |
| <a name="input_bastion_image_ref"></a> [bastion_image_ref](#input_bastion_image_ref) | IBM Cloud image ID for the bastion instance. Required when enable_bastion is true. | `string` |
| <a name="input_bastion_instance_type"></a> [bastion_instance_type](#input_bastion_instance_type) | Instance type to use for the bastion instance. Required when enable_bastion is true. | `string` |
| <a name="input_bastion_public_key"></a> [bastion_public_key](#input_bastion_public_key) | SSH public key content for the bastion host. Required when enable_bastion is true. | `string` |
| <a name="input_bastion_public_ssh_port"></a> [bastion_public_ssh_port](#input_bastion_public_ssh_port) | Set the SSH port to use from desktop to the bastion. | `number` |
| <a name="input_desired_instance_count"></a> [desired_instance_count](#input_desired_instance_count) | Bastion instance desired count. | `number` |
| <a name="input_enable_bastion"></a> [enable_bastion](#input_enable_bastion) | Enable or disable bastion host creation. When false, no resources will be created. | `bool` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDRs that can access to the bastion. Default : 0.0.0.0/0 | `list(string)` |
| <a name="input_tags"></a> [tags](#input_tags) | List of tags to be attached to bastion resources. | `list(string)` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_instance_autoscaling_group_crn"></a> [bastion_instance_autoscaling_group_crn](#output_bastion_instance_autoscaling_group_crn) | Bastion instances autoscaling group CRN. |
| <a name="output_bastion_instance_autoscaling_group_id"></a> [bastion_instance_autoscaling_group_id](#output_bastion_instance_autoscaling_group_id) | Bastion instances autoscaling group ID. |
| <a name="output_bastion_public_ip_addresses"></a> [bastion_public_ip_addresses](#output_bastion_public_ip_addresses) | List of public IP addresses for bastion instances. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group ID. |
<!-- END_TF_DOCS -->
