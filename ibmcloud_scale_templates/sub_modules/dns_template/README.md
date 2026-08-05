# IBM Cloud DNS Template

This Terraform sub-module provisions IBM Cloud DNS services for IBM Spectrum Scale cluster deployments, enabling private DNS resolution within VPC networks.

## Overview

The DNS template creates:
- **Private DNS Zones**: Custom DNS zones for cluster communication
- **DNS Service Instance**: IBM Cloud DNS service for managing zones
- **VPC Integration**: Links DNS zones to VPC for private resolution
- **Custom Resolver**: Enables DNS resolution within VPC

## Purpose

Private DNS zones provide:
- **Hostname Resolution**: Resolve cluster node hostnames to private IPs
- **Service Discovery**: Enable applications to discover cluster services
- **Simplified Management**: Use hostnames instead of IP addresses
- **Multi-Cluster Support**: Separate DNS zones for compute and storage clusters

## Prerequisites

- IBM Cloud VPC already created
- IBM Cloud API key with DNS Services permissions
- Resource group configured
- Understanding of DNS concepts

## Quick Start

### 1. Change Directory

```bash
cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/dns_template/
```

### 2. Create Configuration File

Create `terraform.tfvars.json`:

**Note**: The `dns_service_instance_id` parameter is optional:
- **Omit it** (or set to `null`) to create a new DNS service instance
- **Provide a GUID** (e.g., `"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"`) to reuse an existing DNS service instance by ID

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "resource_prefix": "scale-dns",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "cluster_type": "Combined-compute-storage",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "create_dns_zone": true
}
```

### 3. Deploy DNS Resources

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Storage-Only Cluster DNS (Create New DNS Service Instance)

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "resource_prefix": "storage-dns",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "cluster_type": "Storage-only",
    "vpc_storage_cluster_dns_domain": "strgscale.com",
    "create_dns_zone": true
}
```

**Note**: Since `dns_service_instance_id` is not provided, a new DNS service instance will be created.

### Example 2: Combined Compute + Storage Cluster DNS

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-east",
    "resource_prefix": "scale-dns",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "cluster_type": "Combined-compute-storage",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "create_dns_zone": true
}
```

### Example 3: Reuse Existing DNS Service Instance (by GUID)

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "resource_prefix": "scale-dns",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "cluster_type": "Combined-compute-storage",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "create_dns_zone": true,
    "dns_service_instance_id": "bbbbbbbb-cccc-dddd-eeee-ffffffffffff"
}
```

**Note**: You must provide the DNS service instance **GUID** (not the name). When provided, the existing DNS service instance will be reused instead of creating a new one. You can find the GUID using `ibmcloud resource service-instances --service dns-svcs`.

### Example 4: DNS with Protocol Nodes

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "resource_prefix": "scale-protocol-dns",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "vpc_ref": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "cluster_type": "Storage-only",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_protocol_cluster_dns_domain": "protocol.scale.local",
    "create_dns_zone": true
}
```

## DNS Zone Structure

### Storage Cluster DNS Zone

**Domain**: `storage.scale.local` (or custom)

**Records**:
```
storage-node-1.storage.scale.local  -> 10.241.1.4
storage-node-2.storage.scale.local  -> 10.241.1.5
storage-node-3.storage.scale.local  -> 10.241.1.6
storage-node-4.storage.scale.local  -> 10.241.1.7
```

### Compute Cluster DNS Zone

**Domain**: `compute.scale.local` (or custom)

**Records**:
```
compute-node-1.compute.scale.local  -> 10.241.0.4
compute-node-2.compute.scale.local  -> 10.241.0.5
compute-node-3.compute.scale.local  -> 10.241.0.6
```

## Usage

### Verify DNS Resolution

```bash
# From any instance in the VPC
nslookup storage-node-1.storage.scale.local
nslookup compute-node-1.compute.scale.local

# Using dig
dig storage-node-1.storage.scale.local
dig compute-node-1.compute.scale.local

# Test connectivity
ping storage-node-1.storage.scale.local
ssh vpcuser@compute-node-1.compute.scale.local
```

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output dns_service_instance_id
terraform output vpc_compute_dns_zone_id
terraform output vpc_storage_dns_zone_id
terraform output vpc_protocol_dns_zone_id
```

## Cleanup

```bash
# Destroy DNS resources
terraform destroy -auto-approve

# Note: This will delete all DNS zones and records
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
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_create_dns_zone"></a> [create_dns_zone](#input_create_dns_zone) | Flag to represent if a new private DNS zone needs to be created or reused. | `bool` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key needed for authentication. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | ID of the resource group where DNS service instance will be created (only used if dns_service_instance_id is not provided). | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. Example: ibm-storage-scale | `string` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VPC name to be associated with the DNS zone. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The IBM Cloud region where resources will be created. Examples: us-south, us-east, eu-gb, eu-de. | `string` |
| <a name="input_dns_service_instance_id"></a> [dns_service_instance_id](#input_dns_service_instance_id) | IBM Cloud DNS Service Instance Id. If not provided, a new DNS service instance will be created. | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | List of tags to be attached to DNS resources. | `list(string)` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | IBM Cloud DNS zone name for compute cluster. Required only when deploying compute nodes. | `string` |
| <a name="input_vpc_protocol_cluster_dns_domain"></a> [vpc_protocol_cluster_dns_domain](#input_vpc_protocol_cluster_dns_domain) | IBM Cloud DNS zone name for protocol cluster. If not provided, protocol nodes will use storage cluster DNS zone. | `string` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | IBM Cloud DNS zone name for storage cluster. Required only when deploying storage nodes. | `string` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_service_instance_crn"></a> [dns_service_instance_crn](#output_dns_service_instance_crn) | IBM Cloud DNS Service Instance CRN (only available if newly created). |
| <a name="output_dns_service_instance_id"></a> [dns_service_instance_id](#output_dns_service_instance_id) | IBM Cloud DNS Service Instance ID (either provided or newly created). |
| <a name="output_vpc_compute_dns_domain"></a> [vpc_compute_dns_domain](#output_vpc_compute_dns_domain) | IBM Cloud DNS compute cluster domain name. |
| <a name="output_vpc_compute_dns_zone_id"></a> [vpc_compute_dns_zone_id](#output_vpc_compute_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_protocol_dns_zone_id"></a> [vpc_protocol_dns_zone_id](#output_vpc_protocol_dns_zone_id) | IBM Cloud DNS protocol cluster zone ID. |
| <a name="output_vpc_storage_dns_domain"></a> [vpc_storage_dns_domain](#output_vpc_storage_dns_domain) | IBM Cloud DNS storage cluster domain name. |
| <a name="output_vpc_storage_dns_zone_id"></a> [vpc_storage_dns_zone_id](#output_vpc_storage_dns_zone_id) | IBM Cloud DNS storage cluster zone ID. |
<!-- END_TF_DOCS -->
