# IBM Cloud VPC Template

This Terraform sub-module provisions a complete Virtual Private Cloud (VPC) infrastructure on IBM Cloud for IBM Spectrum Scale deployments.

## Overview

The VPC template creates:
- **VPC**: Virtual Private Cloud with custom address space
- **Subnets**: Public and private subnets across availability zones
- **Public Gateway**: NAT gateway for outbound internet access
- **DNS Zones**: Private DNS zones for cluster communication
- **Custom Resolver**: DNS resolver for VPC
- **Security Infrastructure**: Foundation for security groups

## Purpose

This module provides the network foundation for Spectrum Scale:
- Isolated network environment for cluster deployment
- Multi-zone architecture for high availability
- Separate subnets for storage and compute clusters
- Private DNS for internal hostname resolution
- Secure internet access through public gateway

## Prerequisites

- IBM Cloud account with VPC permissions
- IBM Cloud API key
- Resource group created
- Understanding of VPC networking concepts

## Quick Start

### 1. Change Directory

```bash
cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/vpc_template/
```

### 2. Create Configuration File

Create `terraform.tfvars.json`:

**Option A: Create a new resource group**
```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "scale-vpc",
    "create_resource_group": true,
    "resource_group_name": "scale-vpc-rg",
    "cluster_type": "Storage-only",
    "vpc_cidr_block": "10.241.0.0/18",
    "vpc_public_subnets_cidr_blocks": ["10.241.2.0/24"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "vpc_protocol_private_subnets_cidr_blocks": []
}
```

**Option B: Use an existing resource group**
```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "scale-vpc",
    "create_resource_group": false,
    "resource_group_name": "existing-resource-group-name",
    "cluster_type": "Storage-only",
    "vpc_cidr_block": "10.241.0.0/18",
    "vpc_public_subnets_cidr_blocks": ["10.241.2.0/24"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "vpc_protocol_private_subnets_cidr_blocks": []
}
```

### 3. Deploy VPC

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Single-Zone Storage-Only VPC

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "scale-dev",
    "create_resource_group": true,
    "resource_group_name": "scale-dev-rg",
    "cluster_type": "Storage-only",
    "vpc_cidr_block": "10.241.0.0/18",
    "vpc_public_subnets_cidr_blocks": ["10.241.2.0/24"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "vpc_protocol_private_subnets_cidr_blocks": []
}
```

### Example 2: Multi-Zone Combined Compute-Storage VPC

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": [
        "us-south-1",
        "us-south-2",
        "us-south-3"
    ],
    "resource_prefix": "scale-prod",
    "create_resource_group": false,
    "resource_group_name": "existing-prod-rg",
    "cluster_type": "Combined-compute-storage",
    "vpc_cidr_block": "10.241.0.0/16",
    "vpc_public_subnets_cidr_blocks": [
        "10.241.2.0/24",
        "10.241.66.0/24",
        "10.241.130.0/24"
    ],
    "vpc_storage_cluster_private_subnets_cidr_blocks": [
        "10.241.1.0/24",
        "10.241.65.0/24",
        "10.241.129.0/24"
    ],
    "vpc_compute_cluster_private_subnets_cidr_blocks": [
        "10.241.0.0/24",
        "10.241.64.0/24",
        "10.241.128.0/24"
    ],
    "vpc_protocol_private_subnets_cidr_blocks": []
}
```

### Example 3: VPC with Protocol Nodes (NFS/CES)

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "scale-protocol",
    "create_resource_group": true,
    "resource_group_name": "scale-protocol-rg",
    "cluster_type": "Storage-only",
    "vpc_cidr_block": "10.241.0.0/18",
    "vpc_public_subnets_cidr_blocks": ["10.241.4.0/24"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "vpc_protocol_private_subnets_cidr_blocks": ["10.241.3.0/24"]
}
```

### Example 4: Minimal Storage-Only Configuration

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-east",
    "vpc_availability_zones": ["us-east-1"],
    "resource_prefix": "storage-only",
    "create_resource_group": true,
    "resource_group_name": "storage-only-rg",
    "cluster_type": "Storage-only",
    "vpc_cidr_block": "10.0.0.0/16",
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.0.1.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": [],
    "vpc_protocol_private_subnets_cidr_blocks": []
}
```

## Network Architecture

### Single-Zone Architecture

```
┌─────────────────────────────────────────────────────────┐
│              VPC (10.241.0.0/18)                        │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Zone: us-south-1                              │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────┐     │    │
│  │  │  Storage Subnet (10.241.1.0/24)      │     │    │
│  │  │  - Storage nodes                     │     │    │
│  │  │  - Bastion host                      │     │    │
│  │  └──────────────────────────────────────┘     │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────┐     │    │
│  │  │  Compute Subnet (10.241.0.0/24)      │     │    │
│  │  │  - Compute nodes                     │     │    │
│  │  └──────────────────────────────────────┘     │    │
│  │                                                 │    │
│  │  Public Gateway ──────────────> Internet      │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  DNS Zones:                                             │
│  - storage.scale.local                                  │
│  - compute.scale.local                                  │
└─────────────────────────────────────────────────────────┘
```

### Multi-Zone Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    VPC (10.241.0.0/16)                            │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  us-south-1     │  │  us-south-2     │  │  us-south-3     │ │
│  │  10.241.0.0/18  │  │  10.241.64.0/18 │  │  10.241.128.0/18│ │
│  │                 │  │                 │  │                 │ │
│  │  Storage Subnet │  │  Storage Subnet │  │  Storage Subnet │ │
│  │  10.241.1.0/24  │  │  10.241.64.1/24 │  │  10.241.128.1/24│ │
│  │                 │  │                 │  │                 │ │
│  │  Compute Subnet │  │  Compute Subnet │  │  Compute Subnet │ │
│  │  10.241.0.0/24  │  │  10.241.64.0/24 │  │  10.241.128.0/24│ │
│  │                 │  │                 │  │                 │ │
│  │  Public Gateway │  │  Public Gateway │  │  Public Gateway │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │
│           └──────────────┬──────────────────────────┘           │
│                          │                                       │
│                     Internet                                     │
└──────────────────────────────────────────────────────────────────┘
```

## Subnet Planning

### CIDR Block Guidelines

**Single Zone**:
- VPC: `/18` (16,384 IPs)
- Storage Subnet: `/24` (256 IPs)
- Compute Subnet: `/24` (256 IPs)

**Multi-Zone (3 zones)**:
- VPC: `/16` (65,536 IPs)
- Per Zone: `/18` (16,384 IPs)
- Storage Subnet per zone: `/24` (256 IPs)
- Compute Subnet per zone: `/24` (256 IPs)

### IP Address Allocation

IBM Cloud reserves 5 IPs per subnet:
- Network address (x.x.x.0)
- Gateway (x.x.x.1)
- DNS (x.x.x.2)
- Reserved (x.x.x.3)
- Broadcast (x.x.x.255)

**Available IPs per /24 subnet**: 251 IPs

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output vpc_ref
terraform output vpc_name
terraform output vpc_crn
terraform output vpc_storage_cluster_private_subnets
terraform output vpc_compute_cluster_private_subnets
terraform output vpc_protocol_private_subnets
terraform output vpc_public_subnets
terraform output vpc_public_gateway_ids
```

## Cleanup

```bash
# Destroy VPC and all resources
terraform destroy -auto-approve

# Note: This will delete:
# - VPC
# - All subnets
# - Public gateways
# - DNS zones
# - Custom resolver
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
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Options: 'Storage-only', 'Compute-only', 'Combined-compute-storage'. | `string` |
| <a name="input_create_resource_group"></a> [create_resource_group](#input_create_resource_group) | Flag to create a new resource group. Set to false to use an existing resource group. | `bool` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | IBM Cloud API key for authentication and resource provisioning. | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the IBM Cloud resource group where VPC resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix added to all resource names for identification and organization (e.g., 'ibm-storage-scale'). | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | List of availability zone names or IDs within the selected region for multi-zone deployment. | `list(string)` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | CIDR block for the VPC that will be automatically subdivided into address prefixes for each availability zone (e.g., '10.241.0.0/18'). | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of CIDR blocks for compute cluster private subnets, one per availability zone. | `list(string)` |
| <a name="input_vpc_protocol_private_subnets_cidr_blocks"></a> [vpc_protocol_private_subnets_cidr_blocks](#input_vpc_protocol_private_subnets_cidr_blocks) | List of CIDR blocks for protocol node private subnets, one per availability zone. | `list(string)` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of CIDR blocks for public subnets, one per availability zone. Set to null if no public subnets are needed. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where VPC and all resources will be deployed (e.g., 'us-east', 'us-south', 'eu-de'). | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of CIDR blocks for storage cluster private subnets, one per availability zone. | `list(string)` |
| <a name="input_tags"></a> [tags](#input_tags) | List of tags to be attached to all VPC resources. | `list(string)` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_resource_group_id"></a> [resource_group_id](#output_resource_group_id) | The ID of the resource group used for VPC resources. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets, if compute subnets are enabled for the selected cluster type. |
| <a name="output_vpc_compute_cluster_private_subnets_crn"></a> [vpc_compute_cluster_private_subnets_crn](#output_vpc_compute_cluster_private_subnets_crn) | List of CRNs of compute cluster private subnets, if compute subnets are enabled for the selected cluster type. |
| <a name="output_vpc_compute_cluster_private_subnets_name"></a> [vpc_compute_cluster_private_subnets_name](#output_vpc_compute_cluster_private_subnets_name) | List of names of compute cluster private subnets, if compute subnets are enabled for the selected cluster type. |
| <a name="output_vpc_crn"></a> [vpc_crn](#output_vpc_crn) | The CRN of the VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output_vpc_name) | The name of the VPC. |
| <a name="output_vpc_protocol_private_subnets"></a> [vpc_protocol_private_subnets](#output_vpc_protocol_private_subnets) | List of IDs of protocol cluster private subnets, if protocol subnets are enabled for the selected cluster type. |
| <a name="output_vpc_protocol_private_subnets_crn"></a> [vpc_protocol_private_subnets_crn](#output_vpc_protocol_private_subnets_crn) | List of CRNs of protocol cluster private subnets, if protocol subnets are enabled for the selected cluster type. |
| <a name="output_vpc_protocol_private_subnets_name"></a> [vpc_protocol_private_subnets_name](#output_vpc_protocol_private_subnets_name) | List of names of protocol cluster private subnets, if protocol subnets are enabled for the selected cluster type. |
| <a name="output_vpc_public_gateway_ids"></a> [vpc_public_gateway_ids](#output_vpc_public_gateway_ids) | List of IDs of public gateways created for the enabled subnets across the configured availability zones. |
| <a name="output_vpc_public_subnets"></a> [vpc_public_subnets](#output_vpc_public_subnets) | List of IDs of public subnets, if public subnets are enabled. |
| <a name="output_vpc_public_subnets_crn"></a> [vpc_public_subnets_crn](#output_vpc_public_subnets_crn) | List of CRNs of public subnets, if public subnets are enabled. |
| <a name="output_vpc_public_subnets_name"></a> [vpc_public_subnets_name](#output_vpc_public_subnets_name) | List of names of public subnets, if public subnets are enabled. |
| <a name="output_vpc_ref"></a> [vpc_ref](#output_vpc_ref) | The ID of the VPC. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets, if storage subnets are enabled for the selected cluster type. |
| <a name="output_vpc_storage_cluster_private_subnets_crn"></a> [vpc_storage_cluster_private_subnets_crn](#output_vpc_storage_cluster_private_subnets_crn) | List of CRNs of storage cluster private subnets, if storage subnets are enabled for the selected cluster type. |
| <a name="output_vpc_storage_cluster_private_subnets_name"></a> [vpc_storage_cluster_private_subnets_name](#output_vpc_storage_cluster_private_subnets_name) | List of names of storage cluster private subnets, if storage subnets are enabled for the selected cluster type. |
<!-- END_TF_DOCS -->
