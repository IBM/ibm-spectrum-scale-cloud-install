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

```jsonc
{
    "vpc_region": "us-south",
    "resource_prefix": "scale-dns",
    "vpc_id": "r013-xxxx-xxxx-xxxx",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "vpc_create_separate_subnets": true,
    "create_dns_zone": true
}
```

### 3. Set IBM Cloud Credentials

```bash
export IC_API_KEY="your-ibm-cloud-api-key"
```

### 4. Deploy DNS Resources

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Storage-Only Cluster DNS

```jsonc
{
    "vpc_region": "us-south",
    "resource_prefix": "storage-dns",
    "vpc_id": "r013-vpc-id-here",
    "vpc_storage_cluster_dns_domain": "strgscale.com",
    "vpc_compute_cluster_dns_domain": "",
    "vpc_create_separate_subnets": false,
    "create_dns_zone": true
}
```

### Example 2: Compute + Storage Cluster DNS

```jsonc
{
    "vpc_region": "us-east",
    "resource_prefix": "scale-dns",
    "vpc_id": "r013-vpc-id-here",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "vpc_create_separate_subnets": true,
    "create_dns_zone": true
}
```

### Example 3: Reuse Existing DNS Service

```jsonc
{
    "vpc_region": "us-south",
    "resource_prefix": "scale-dns",
    "vpc_id": "r013-vpc-id-here",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "vpc_create_separate_subnets": true,
    "create_dns_zone": false,
    "vpc_dns_service_id": "existing-dns-service-id"
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
ssh root@compute-node-1.compute.scale.local
```

### Add Custom DNS Records

```bash
# Using IBM Cloud CLI
ibmcloud dns resource-record-create <zone-id> \
  --type A \
  --name custom-service \
  --rdata 10.241.1.10

# Verify
nslookup custom-service.storage.scale.local
```

### List DNS Zones and Records

```bash
# List all DNS zones
ibmcloud dns zones

# List records in a zone
ibmcloud dns resource-records <zone-id>

# Get zone details
ibmcloud dns zone <zone-id>
```

## DNS Best Practices

### Naming Conventions

1. **Use Descriptive Names**: `storage-node-1`, `compute-node-1`
2. **Consistent Patterns**: Follow a naming scheme across all nodes
3. **Environment Prefixes**: `prod-storage-node-1`, `dev-compute-node-1`
4. **Service Names**: `nfs-server`, `gui-server`, `admin-node`

### Domain Selection

1. **Private Domains**: Use `.local`, `.internal`, or `.private` TLDs
2. **Avoid Public Domains**: Don't use domains you don't own
3. **Unique Names**: Ensure domains don't conflict with existing zones
4. **Meaningful Names**: `storage.scale.local` vs `cluster1.local`

### Performance Optimization

1. **TTL Settings**: Use appropriate TTL values (300-3600 seconds)
2. **Caching**: Leverage DNS caching on instances
3. **Multiple Resolvers**: Configure backup DNS servers
4. **Zone Separation**: Separate zones for different cluster types

## Troubleshooting

### DNS Resolution Fails

**Problem**: Cannot resolve hostnames

**Solutions**:
```bash
# 1. Check DNS zones exist
ibmcloud dns zones

# 2. Verify DNS service is active
ibmcloud dns instance <service-id>

# 3. Check VPC custom resolver
ibmcloud is vpc <vpc-id>

# 4. Verify /etc/resolv.conf on instance
cat /etc/resolv.conf
# Should contain VPC DNS resolver IP (typically 161.26.0.7)

# 5. Test DNS resolution
nslookup storage-node-1.storage.scale.local
dig @161.26.0.7 storage-node-1.storage.scale.local

# 6. Check DNS records exist
ibmcloud dns resource-records <zone-id>
```

### Slow DNS Resolution

**Problem**: DNS queries take too long

**Solutions**:
```bash
# 1. Check DNS query time
time nslookup storage-node-1.storage.scale.local

# 2. Verify DNS caching
systemctl status systemd-resolved

# 3. Configure local DNS cache
sudo apt install dnsmasq
# or
sudo yum install dnsmasq

# 4. Adjust DNS timeout settings
# Edit /etc/resolv.conf
options timeout:2 attempts:3
```

### DNS Records Not Created

**Problem**: Terraform creates zones but no records

**Solutions**:
```bash
# 1. Check if instance module creates records
# DNS records are typically created by instance_template module

# 2. Verify zone IDs are passed correctly
terraform output vpc_storage_dns_zone_id
terraform output vpc_compute_dns_zone_id

# 3. Check instance module configuration
# Ensure dns_zone_id variables are set

# 4. Manually create test record
ibmcloud dns resource-record-create <zone-id> \
  --type A --name test --rdata 10.241.1.100
```

### VPC Not Linked to DNS Zone

**Problem**: DNS resolution doesn't work in VPC

**Solutions**:
```bash
# 1. Check VPC permitted networks
ibmcloud dns permitted-networks <zone-id>

# 2. Add VPC to permitted networks
ibmcloud dns permitted-network-add <zone-id> \
  --vpc-crn <vpc-crn> \
  --type vpc

# 3. Verify custom resolver
ibmcloud is vpc <vpc-id>
# Look for dns.resolver section
```

## Cost Considerations

### DNS Service Pricing

| Component | Cost |
|-----------|------|
| DNS Service Instance | Free |
| DNS Zone | $0.50/zone/month |
| DNS Queries | First 1 billion queries/month free |
| Additional Queries | $0.40 per million queries |

### Cost Optimization

1. **Consolidate Zones**: Use fewer zones when possible
2. **Query Optimization**: Implement DNS caching to reduce queries
3. **TTL Management**: Use appropriate TTL values to reduce query frequency
4. **Monitor Usage**: Track DNS query volume

### Example Costs

**Small Deployment** (2 zones):
- 2 DNS zones: $1.00/month
- Queries: Free (< 1B/month)
- **Total: ~$1/month**

**Large Deployment** (5 zones):
- 5 DNS zones: $2.50/month
- Queries: Free (< 1B/month)
- **Total: ~$2.50/month**

## Integration with Main Template

This sub-module is used by the VPC template:

```hcl
module "dns" {
  source                          = "../sub_modules/dns_template"
  vpc_region                      = var.vpc_region
  vpc_id                          = ibm_is_vpc.vpc.id
  resource_prefix                 = var.resource_prefix
  vpc_storage_cluster_dns_domain  = var.vpc_storage_cluster_dns_domain
  vpc_compute_cluster_dns_domain  = var.vpc_compute_cluster_dns_domain
  vpc_create_separate_subnets     = var.vpc_create_separate_subnets
  create_dns_zone                 = true
}
```

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output vpc_storage_dns_zone_id
terraform output vpc_compute_dns_zone_id
terraform output vpc_dns_service_id
```

## Advanced Configuration

### Custom DNS Records

```bash
# Add A record
ibmcloud dns resource-record-create <zone-id> \
  --type A \
  --name web-server \
  --rdata 10.241.1.50 \
  --ttl 300

# Add CNAME record
ibmcloud dns resource-record-create <zone-id> \
  --type CNAME \
  --name www \
  --rdata web-server.storage.scale.local \
  --ttl 300

# Add PTR record (reverse DNS)
ibmcloud dns resource-record-create <reverse-zone-id> \
  --type PTR \
  --name 50.1.241.10.in-addr.arpa \
  --rdata web-server.storage.scale.local \
  --ttl 300
```

### DNS Forwarding

```bash
# Configure conditional forwarding on instances
# Edit /etc/systemd/resolved.conf
[Resolve]
DNS=161.26.0.7
Domains=~storage.scale.local ~compute.scale.local

# Restart resolver
sudo systemctl restart systemd-resolved
```

### Health Checks

```bash
# Monitor DNS resolution
while true; do
  echo "$(date): $(dig +short storage-node-1.storage.scale.local)"
  sleep 60
done

# Check DNS service health
ibmcloud dns instance <service-id>
```

## Cleanup

```bash
# Destroy DNS resources
terraform destroy -auto-approve

# Note: This will delete all DNS zones and records
```

## Additional Resources

- [IBM Cloud DNS Services Documentation](https://cloud.ibm.com/docs/dns-svcs)
- [VPC Custom Resolver](https://cloud.ibm.com/docs/vpc?topic=vpc-about-dns-svcs)
- [DNS Best Practices](https://cloud.ibm.com/docs/dns-svcs?topic=dns-svcs-best-practices)
- [DNS CLI Reference](https://cloud.ibm.com/docs/dns-svcs?topic=dns-svcs-cli-plugin-dns-svcs-cli)

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
| <a name="output_vpc_compute_dns_zone_id"></a> [vpc_compute_dns_zone_id](#output_vpc_compute_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_protocol_dns_zone_id"></a> [vpc_protocol_dns_zone_id](#output_vpc_protocol_dns_zone_id) | IBM Cloud DNS protocol cluster zone ID. |
| <a name="output_vpc_storage_dns_zone_id"></a> [vpc_storage_dns_zone_id](#output_vpc_storage_dns_zone_id) | IBM Cloud DNS storage cluster zone ID. |
<!-- END_TF_DOCS -->
