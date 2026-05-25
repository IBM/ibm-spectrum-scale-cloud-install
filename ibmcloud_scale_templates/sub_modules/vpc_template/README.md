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

## DNS Configuration

### Private DNS Zones

**Storage Cluster Zone**: `storage.scale.local`
- Resolves storage node hostnames
- Used for storage cluster communication
- Accessible only within VPC

**Compute Cluster Zone**: `compute.scale.local`
- Resolves compute node hostnames
- Used for compute cluster communication
- Accessible only within VPC

### Custom Resolver

VPC includes a custom DNS resolver (typically `161.26.0.7`) that:
- Resolves private DNS zones
- Forwards external queries to public DNS
- Provides DNS caching

## Usage

### Verify VPC Resources

```bash
# List VPCs
ibmcloud is vpcs

# Get VPC details
ibmcloud is vpc <vpc-id>

# List subnets
ibmcloud is subnets

# Get subnet details
ibmcloud is subnet <subnet-id>

# Check public gateways
ibmcloud is public-gateways

# View DNS zones
ibmcloud dns zones
```

### Test Connectivity

```bash
# From an instance in the VPC

# Test internet connectivity (via public gateway)
ping 8.8.8.8
curl https://www.ibm.com

# Test DNS resolution
nslookup storage-node-1.storage.scale.local
dig compute-node-1.compute.scale.local

# Test inter-subnet connectivity
ping <instance-in-other-subnet>
```

### Modify VPC

```bash
# Add address prefix
ibmcloud is vpc-address-prefix-create <vpc-id> \
  --zone us-south-3 \
  --cidr 10.241.192.0/18 \
  --name scale-zone3

# Create additional subnet
ibmcloud is subnet-create scale-subnet-4 <vpc-id> \
  --zone us-south-3 \
  --ipv4-cidr-block 10.241.192.0/24
```

## Best Practices

### Network Design

1. **Plan CIDR Blocks**: Avoid overlapping with existing networks
2. **Multi-Zone**: Use 3 zones for production high availability
3. **Subnet Sizing**: Size subnets based on expected instance count
4. **Reserve Space**: Leave room for future expansion
5. **Consistent Naming**: Use clear, descriptive names

### Security

1. **Private Subnets**: Keep cluster instances in private subnets
2. **Public Gateway**: Use for outbound internet access only
3. **Network ACLs**: Implement additional network-level security
4. **Flow Logs**: Enable for network traffic monitoring
5. **DNS Security**: Use private DNS zones only

### High Availability

1. **Multi-Zone**: Distribute resources across 3 zones
2. **Subnet Redundancy**: Create subnets in each zone
3. **Gateway Redundancy**: Public gateway per zone
4. **Load Distribution**: Balance instances across zones

## Troubleshooting

### VPC Creation Fails

**Problem**: Terraform fails to create VPC

**Solutions**:
```bash
# 1. Check resource quotas
ibmcloud resource quotas

# 2. Verify region availability
ibmcloud is regions
ibmcloud is zones us-south

# 3. Check CIDR conflicts
ibmcloud is vpcs
# Ensure CIDR doesn't overlap with existing VPCs

# 4. Verify permissions
ibmcloud iam user-policies <user-email>
```

### Subnet Creation Fails

**Problem**: Cannot create subnets

**Solutions**:
```bash
# 1. Verify VPC exists
ibmcloud is vpc <vpc-id>

# 2. Check zone availability
ibmcloud is zones us-south

# 3. Verify CIDR is within VPC address prefix
ibmcloud is vpc-address-prefixes <vpc-id>

# 4. Check subnet quota
ibmcloud is subnets
# Max 15 subnets per VPC per zone
```

### DNS Resolution Fails

**Problem**: Cannot resolve private DNS names

**Solutions**:
```bash
# 1. Check DNS zones exist
ibmcloud dns zones

# 2. Verify VPC is linked to DNS zone
ibmcloud dns permitted-networks <zone-id>

# 3. Check custom resolver
ibmcloud is vpc <vpc-id>
# Look for dns.resolver section

# 4. Verify /etc/resolv.conf on instance
cat /etc/resolv.conf
# Should contain 161.26.0.7
```

### No Internet Access

**Problem**: Instances cannot reach internet

**Solutions**:
```bash
# 1. Check public gateway exists
ibmcloud is public-gateways

# 2. Verify subnet is attached to gateway
ibmcloud is subnet <subnet-id>
# Look for public_gateway section

# 3. Attach gateway to subnet
ibmcloud is subnet-update <subnet-id> \
  --public-gateway-id <gateway-id>

# 4. Check security group rules
ibmcloud is security-group-rules <sg-id>
# Ensure outbound rules allow traffic
```

### CIDR Overlap Issues

**Problem**: CIDR conflicts with existing networks

**Solutions**:
```bash
# 1. List all VPCs and their CIDRs
ibmcloud is vpcs --output json | jq '.[] | {name, id, cidr}'

# 2. Choose non-overlapping CIDR
# Common private ranges:
# - 10.0.0.0/8
# - 172.16.0.0/12
# - 192.168.0.0/16

# 3. Update terraform configuration
# Use unique CIDR blocks
```

## Cost Considerations

### VPC Pricing

| Component | Cost |
|-----------|------|
| VPC | Free |
| Subnets | Free |
| Public Gateway | ~$0.045/hour (~$33/month) |
| DNS Zone | $0.50/zone/month |
| Data Transfer (outbound) | $0.09/GB |

### Cost Optimization

1. **Single Public Gateway**: Use one gateway per zone (not per subnet)
2. **Minimize Data Transfer**: Keep traffic within VPC when possible
3. **Consolidate DNS Zones**: Use fewer zones if possible
4. **Right-size Subnets**: Don't over-provision IP space
5. **Monitor Usage**: Track data transfer costs

### Example Costs

**Single-Zone VPC**:
- 1 Public Gateway: $33/month
- 2 DNS Zones: $1/month
- Data Transfer (100GB): $9/month
- **Total: ~$43/month**

**Multi-Zone VPC (3 zones)**:
- 3 Public Gateways: $99/month
- 2 DNS Zones: $1/month
- Data Transfer (300GB): $27/month
- **Total: ~$127/month**

## Integration with Main Template

This module is used by the main template:

```hcl
module "vpc" {
  source                                          = "../sub_modules/vpc_template"
  vpc_region                                      = var.vpc_region
  vpc_availability_zones                          = var.vpc_availability_zones
  resource_prefix                                 = var.resource_prefix
  resource_group_id                               = data.ibm_resource_group.itself.id
  vpc_cidr_block                                  = var.vpc_cidr_block
  vpc_storage_cluster_private_subnets_cidr_blocks = var.vpc_storage_cluster_private_subnets_cidr_blocks
  vpc_create_separate_subnets                     = var.vpc_create_separate_subnets
  vpc_compute_cluster_private_subnets_cidr_blocks = var.vpc_compute_cluster_private_subnets_cidr_blocks
  vpc_compute_cluster_dns_domain                  = var.vpc_compute_cluster_dns_domain
  vpc_storage_cluster_dns_domain                  = var.vpc_storage_cluster_dns_domain
}
```

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output vpc_id
terraform output vpc_storage_cluster_private_subnets
terraform output vpc_compute_cluster_private_subnets
terraform output vpc_storage_cluster_dns_zone_id
terraform output vpc_compute_cluster_dns_zone_id
terraform output vpc_custom_resolver_id
```

## Advanced Configuration

### Network ACLs

```bash
# Create network ACL
ibmcloud is network-acl-create scale-acl <vpc-id>

# Add inbound rule
ibmcloud is network-acl-rule-add <acl-id> \
  --direction inbound \
  --action allow \
  --protocol tcp \
  --source 10.241.0.0/16 \
  --destination 10.241.0.0/16

# Apply to subnet
ibmcloud is subnet-update <subnet-id> \
  --network-acl-id <acl-id>
```

### VPC Flow Logs

```bash
# Create flow log collector
ibmcloud is flow-log-create scale-flow-logs \
  --target <vpc-id> \
  --bucket <cos-bucket-name> \
  --active true

# View flow logs
ibmcloud is flow-logs
```

### VPC Peering

```bash
# Create VPC peering connection (when available)
# Connect multiple VPCs for inter-VPC communication
```

### Custom Routes

```bash
# Create custom route
ibmcloud is vpc-routing-table-route-create <vpc-id> <routing-table-id> \
  --zone us-south-1 \
  --destination 192.168.0.0/16 \
  --next-hop 10.241.1.10
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

⚠️ **Warning**: Ensure all instances and other resources are deleted before destroying the VPC.

## Additional Resources

- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [VPC Networking](https://cloud.ibm.com/docs/vpc?topic=vpc-about-networking-for-vpc)
- [VPC Address Prefixes](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-addressing-plan-design)
- [VPC Security](https://cloud.ibm.com/docs/vpc?topic=vpc-security-in-your-vpc)
- [VPC Best Practices](https://cloud.ibm.com/docs/vpc?topic=vpc-best-practices-for-vpc)

---

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 2 |

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
