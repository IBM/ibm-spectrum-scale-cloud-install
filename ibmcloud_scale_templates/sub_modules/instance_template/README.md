# IBM Cloud Instance Template

This Terraform sub-module provisions compute and storage instances for IBM Spectrum Scale clusters in an existing IBM Cloud VPC infrastructure.

## Overview

The instance template creates:
- **Storage Cluster Instances**: Virtual servers with attached block storage volumes
- **Compute Cluster Instances**: Virtual servers for workload processing
- **Security Groups**: Network security rules for cluster communication
- **DNS Records**: Hostname entries in private DNS zones
- **Block Storage Volumes**: Data volumes attached to storage instances

## Purpose

This module handles the core infrastructure for Spectrum Scale:
- Provisions instances across availability zones for high availability
- Configures networking and security for cluster communication
- Attaches block storage volumes for Spectrum Scale filesystems
- Registers instances in DNS for hostname resolution
- Sets up security groups for inter-cluster communication

## Prerequisites

- Existing IBM Cloud VPC
- VPC subnets configured
- DNS zones created (via dns_template)
- Bastion host deployed (via bastion_template)
- SSH keys created in IBM Cloud
- IBM Cloud API key with appropriate permissions

## Quick Start

### 1. Change Directory

```bash
cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/instance_template/
```

### 2. Create Configuration File

Create `terraform.tfvars.json`:

```jsonc
{
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "vpc_id": "r013-xxxx-xxxx-xxxx",
    "resource_group_id": "xxxx-xxxx-xxxx-xxxx",
    "resource_prefix": "scale",

    // Bastion Configuration
    "bastion_instance_id": "xxxx-xxxx-xxxx-xxxx",
    "bastion_instance_public_ip": "203.0.113.10",
    "bastion_security_group_id": "r013-xxxx-xxxx-xxxx",
    "bastion_ssh_private_key": "/root/.ssh/id_rsa",

    // Storage Cluster
    "total_storage_cluster_instances": 4,
    "storage_cluster_key_pair": "storage-key",
    "storage_vsi_profile": "bx2d-8x32",
    "storage_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "StoragePass123!",
    "vpc_storage_cluster_private_subnets": ["subnet-id-1"],

    // Compute Cluster
    "total_compute_cluster_instances": 2,
    "compute_cluster_key_pair": "compute-key",
    "compute_vsi_profile": "cx2-4x8",
    "compute_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "ComputePass123!",
    "vpc_compute_cluster_private_subnets": ["subnet-id-2"],

    // DNS Configuration
    "vpc_storage_cluster_dns_service_id": "dns-service-id",
    "vpc_storage_cluster_dns_zone_id": "zone-id-1",
    "vpc_compute_cluster_dns_service_id": "dns-service-id",
    "vpc_compute_cluster_dns_zone_id": "zone-id-2",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "vpc_custom_resolver_id": "resolver-id"
}
```

### 3. Set IBM Cloud Credentials

```bash
export IC_API_KEY="your-ibm-cloud-api-key"
```

### 4. Deploy Instances

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Storage-Only Cluster (4 nodes)

```jsonc
{
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "vpc_id": "r013-vpc-id",
    "resource_group_id": "resource-group-id",
    "resource_prefix": "storage",

    "bastion_instance_id": "bastion-id",
    "bastion_instance_public_ip": "203.0.113.10",
    "bastion_security_group_id": "bastion-sg-id",
    "bastion_ssh_private_key": "/root/.ssh/id_rsa",

    "total_storage_cluster_instances": 4,
    "storage_cluster_key_pair": "storage-key",
    "storage_vsi_profile": "bx2d-8x32",
    "storage_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "SecurePass123!",
    "vpc_storage_cluster_private_subnets": ["subnet-id"],

    "total_compute_cluster_instances": 0,
    "compute_cluster_key_pair": "compute-key",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "SecurePass123!",
    "vpc_compute_cluster_private_subnets": [],

    "vpc_storage_cluster_dns_service_id": "dns-service-id",
    "vpc_storage_cluster_dns_zone_id": "zone-id",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_custom_resolver_id": "resolver-id"
}
```

### Example 2: Compute + Storage Cluster (Multi-Zone)

```jsonc
{
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1", "us-south-2", "us-south-3"],
    "vpc_id": "r013-vpc-id",
    "resource_group_id": "resource-group-id",
    "resource_prefix": "scale-ha",

    "bastion_instance_id": "bastion-id",
    "bastion_instance_public_ip": "203.0.113.10",
    "bastion_security_group_id": "bastion-sg-id",
    "bastion_ssh_private_key": "/root/.ssh/id_rsa",

    "total_storage_cluster_instances": 6,
    "storage_cluster_key_pair": "storage-key",
    "storage_vsi_profile": "bx2d-16x64",
    "storage_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "StoragePass123!",
    "vpc_storage_cluster_private_subnets": [
        "subnet-zone1-id",
        "subnet-zone2-id",
        "subnet-zone3-id"
    ],

    "total_compute_cluster_instances": 3,
    "compute_cluster_key_pair": "compute-key",
    "compute_vsi_profile": "cx2-8x16",
    "compute_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "ComputePass123!",
    "vpc_compute_cluster_private_subnets": [
        "compute-subnet-zone1-id",
        "compute-subnet-zone2-id",
        "compute-subnet-zone3-id"
    ],

    "vpc_storage_cluster_dns_service_id": "dns-service-id",
    "vpc_storage_cluster_dns_zone_id": "storage-zone-id",
    "vpc_compute_cluster_dns_service_id": "dns-service-id",
    "vpc_compute_cluster_dns_zone_id": "compute-zone-id",
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "vpc_custom_resolver_id": "resolver-id",

    "create_separate_namespaces": true
}
```

## Instance Profiles

### Storage Cluster Profiles

| Profile | vCPU | RAM | Local Storage | Use Case |
|---------|------|-----|---------------|----------|
| bx2d-8x32 | 8 | 32GB | 1x300GB NVMe | Small clusters |
| bx2d-16x64 | 16 | 64GB | 1x600GB NVMe | Medium clusters |
| bx2d-32x128 | 32 | 128GB | 2x600GB NVMe | Large clusters |
| bx2d-48x192 | 48 | 192GB | 2x960GB NVMe | Enterprise clusters |

### Compute Cluster Profiles

| Profile | vCPU | RAM | Use Case |
|---------|------|-----|----------|
| cx2-2x4 | 2 | 4GB | Light workloads |
| cx2-4x8 | 4 | 8GB | Standard workloads |
| cx2-8x16 | 8 | 16GB | Compute-intensive |
| cx2-16x32 | 16 | 32GB | High-performance |

## Storage Configuration

### Block Storage Volumes

Storage instances can have additional block storage volumes attached:

## Security Groups

### Storage Cluster Security Group

Allows:
- SSH (22) from bastion
- GPFS daemon (1191) from cluster nodes
- GPFS admin (47080) from cluster nodes
- GUI (443, 47443) from bastion
- All traffic between storage nodes

### Compute Cluster Security Group

Allows:
- SSH (22) from bastion
- GPFS client (1191) from storage cluster
- All traffic between compute nodes

## Usage

### Access Instances

```bash
# SSH to storage node via bastion
ssh -J root@<bastion-ip> root@storage-node-1.storage.scale.local

# SSH to compute node via bastion
ssh -J root@<bastion-ip> root@compute-node-1.compute.scale.local

# Direct access using private IP
ssh -J root@<bastion-ip> root@10.241.1.4
```

### Verify Instances

```bash
# List all instances
ibmcloud is instances

# Get instance details
ibmcloud is instance <instance-id>

# Check instance status
ibmcloud is instance <instance-id> --output json | jq '.status'

# List attached volumes
ibmcloud is instance-volume-attachments <instance-id>
```

### Check Block Storage

```bash
# SSH to storage node
ssh -J root@<bastion-ip> root@storage-node-1.storage.scale.local

# List block devices
lsblk

# Check disk information
fdisk -l

# Verify volume attachments
ls -l /dev/disk/by-id/
```

## DNS Integration

Instances are automatically registered in DNS:

**Storage Cluster**:
```
storage-node-1.storage.scale.local -> 10.241.1.4
storage-node-2.storage.scale.local -> 10.241.1.5
storage-node-3.storage.scale.local -> 10.241.1.6
storage-node-4.storage.scale.local -> 10.241.1.7
```

**Compute Cluster**:
```
compute-node-1.compute.scale.local -> 10.241.0.4
compute-node-2.compute.scale.local -> 10.241.0.5
compute-node-3.compute.scale.local -> 10.241.0.6
```

## Troubleshooting

### Instance Creation Fails

**Problem**: Terraform fails to create instances

**Solutions**:
```bash
# 1. Check resource quotas
ibmcloud is instance-profiles
ibmcloud resource quotas

# 2. Verify subnet has available IPs
ibmcloud is subnet <subnet-id>

# 3. Check SSH key exists
ibmcloud is keys

# 4. Verify image is available
ibmcloud is images | grep redhat

# 5. Check security group rules
ibmcloud is security-group-rules <sg-id>
```

### Cannot SSH to Instances

**Problem**: SSH connection fails

**Solutions**:
```bash
# 1. Verify bastion is accessible
ssh -i ~/.ssh/bastion-key root@<bastion-ip>

# 2. Check security group allows SSH from bastion
ibmcloud is security-group-rules <cluster-sg-id>

# 3. Verify DNS resolution
nslookup storage-node-1.storage.scale.local

# 4. Test with private IP
ssh -J root@<bastion-ip> root@10.241.1.4

# 5. Check instance is running
ibmcloud is instance <instance-id>
```

### Block Storage Not Attached

**Problem**: Volumes not visible on instance

**Solutions**:
```bash
# 1. Check volume attachments
ibmcloud is instance-volume-attachments <instance-id>

# 2. Verify volumes exist
ibmcloud is volumes

# 3. On instance, rescan SCSI bus
echo "- - -" > /sys/class/scsi_host/host0/scan

# 4. Check dmesg for errors
dmesg | grep -i scsi

# 5. List block devices
lsblk
ls -l /dev/vd*
```

### DNS Resolution Fails

**Problem**: Cannot resolve hostnames

**Solutions**:
```bash
# 1. Check /etc/resolv.conf
cat /etc/resolv.conf

# 2. Verify DNS service
ibmcloud dns zones

# 3. Check DNS records
ibmcloud dns resource-records <zone-id>

# 4. Test DNS resolution
nslookup storage-node-1.storage.scale.local
dig storage-node-1.storage.scale.local

# 5. Verify VPC custom resolver
ibmcloud is vpc <vpc-id>
```

### Performance Issues

**Problem**: Slow instance or storage performance

**Solutions**:
```bash
# 1. Check instance metrics
ibmcloud is instance-monitoring <instance-id>

# 2. Monitor CPU/memory on instance
top
free -m
iostat -x 1

# 3. Check disk I/O
iotop
fio --name=test --rw=randread --bs=4k --size=1G

# 4. Verify network performance
iperf3 -s  # On one node
iperf3 -c <node-ip>  # On another node

# 5. Check for throttling
dmesg | grep -i throttle
```

## Cost Optimization

### Instance Sizing

**Start Small, Scale Up**:
1. Begin with minimum required instances
2. Monitor resource utilization
3. Scale up based on actual needs
4. Use appropriate instance profiles

### Storage Optimization

1. **Use Instance Storage**: bx2d profiles include local NVMe
2. **Right-size Volumes**: Don't over-provision block storage
3. **Choose Appropriate IOPS**: Match IOPS to workload requirements
4. **Delete Unused Volumes**: Clean up detached volumes

### Cost Monitoring

```bash
# Check current usage
ibmcloud billing account-usage

# View instance costs
ibmcloud billing resource-instances-usage

# Estimate costs before deployment
# Use IBM Cloud Cost Estimator: https://cloud.ibm.com/estimator
```

## Integration with Main Template

This module is used by the main template:

```hcl
module "scale_instances" {
  source                                = "../sub_modules/instance_template"
  vpc_region                            = var.vpc_region
  vpc_availability_zones                = var.vpc_availability_zones
  resource_prefix                       = var.resource_prefix
  resource_group_id                     = data.ibm_resource_group.itself.id
  vpc_id                                = module.vpc.vpc_id
  vpc_storage_cluster_private_subnets   = module.vpc.vpc_storage_cluster_private_subnets
  vpc_compute_cluster_private_subnets   = module.vpc.vpc_compute_cluster_private_subnets
  total_compute_cluster_instances       = var.total_compute_cluster_instances
  total_storage_cluster_instances       = var.total_storage_cluster_instances
  # ... additional configuration
}
```

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output storage_cluster_instance_ids
terraform output storage_cluster_instance_private_ips
terraform output compute_cluster_instance_ids
terraform output compute_cluster_instance_private_ips
terraform output storage_cluster_with_data_volume_mapping
```

## Advanced Configuration

### Custom User Data

```bash
# Add custom initialization script
user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y kernel-devel kernel-headers
# Additional setup commands
EOF
```

### Instance Tags

```jsonc
{
    "storage_cluster_tags": {
        "environment": "production",
        "cluster": "storage",
        "managed_by": "terraform"
    },
    "compute_cluster_tags": {
        "environment": "production",
        "cluster": "compute",
        "managed_by": "terraform"
    }
}
```

### Encryption

```jsonc
{
    "root_device_encrypted": true,
    "root_device_kms_key_ref": "kms-key-id",
    "filesystem_encrypted": true,
    "filesystem_kms_key_ref": "kms-key-id"
}
```

## Cleanup

```bash
# Destroy all instances and volumes
terraform destroy -auto-approve

# Note: This will delete all instances and attached volumes
# Ensure you have backups of any important data
```

## Additional Resources

- [IBM Cloud VPC Instances](https://cloud.ibm.com/docs/vpc?topic=vpc-about-advanced-virtual-servers)
- [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)
- [Block Storage](https://cloud.ibm.com/docs/vpc?topic=vpc-block-storage-about)
- [Security Groups](https://cloud.ibm.com/docs/vpc?topic=vpc-using-security-groups)
- [IBM Spectrum Scale on Cloud](https://www.ibm.com/docs/en/spectrum-scale-cloud)

---

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 2 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_airgap"></a> [airgap](#input_airgap) | If true, instance iam profile, git utils which need internet access will be skipped. | `bool` |
| <a name="input_bastion_security_group_id"></a> [bastion_security_group_id](#input_bastion_security_group_id) | Bastion security group ID. | `string` |
| <a name="input_boot_disk_type"></a> [boot_disk_type](#input_boot_disk_type) | Boot disk type for all cluster instances. | `string` |
| <a name="input_ces_ip_addresses"></a> [ces_ip_addresses](#input_ces_ip_addresses) | CES IP addresses (length must be equal to number of protocol nodes). | `list(string)` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_compute_cluster_image_id"></a> [compute_cluster_image_id](#input_compute_cluster_image_id) | Image ID to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_instance_type"></a> [compute_cluster_instance_type](#input_compute_cluster_instance_type) | Instance type to use for provisioning the compute cluster instances. | `string` |
| <a name="input_compute_cluster_public_key_path"></a> [compute_cluster_public_key_path](#input_compute_cluster_public_key_path) | The ssh public key to be created used to launch the compute cluster. | `string` |
| <a name="input_enable_placement_group"></a> [enable_placement_group](#input_enable_placement_group) | If true, an IBM Cloud placement group will be created for single-AZ deployments and attached to storage instances using host_spread strategy. | `bool` |
| <a name="input_gateway_instance_type"></a> [gateway_instance_type](#input_gateway_instance_type) | Instance type to use for provisioning the gateway instances. | `string` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_protocol_instance_type"></a> [protocol_instance_type](#input_protocol_instance_type) | Instance type to use for provisioning the protocol instances. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | IBM Cloud resource group ID. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` |
| <a name="input_root_device_kms_key_id"></a> [root_device_kms_key_id](#input_root_device_kms_key_id) | GUID of the Key Protect/HPCS instance to be used when encrypting the root volume. | `string` |
| <a name="input_root_device_kms_key_name"></a> [root_device_kms_key_name](#input_root_device_kms_key_name) | Name of the root/standard key to be used when encrypting the root volume. | `string` |
| <a name="input_storage_cluster_image_id"></a> [storage_cluster_image_id](#input_storage_cluster_image_id) | Image ID to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_instance_type"></a> [storage_cluster_instance_type](#input_storage_cluster_instance_type) | Instance type to use for provisioning the storage cluster instances. | `string` |
| <a name="input_storage_cluster_public_key_path"></a> [storage_cluster_public_key_path](#input_storage_cluster_public_key_path) | The ssh public key to be created used to launch the storage cluster. | `string` |
| <a name="input_storage_cluster_tiebreaker_instance_type"></a> [storage_cluster_tiebreaker_instance_type](#input_storage_cluster_tiebreaker_instance_type) | Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration). | `string` |
| <a name="input_storage_volume_iops"></a> [storage_volume_iops](#input_storage_volume_iops) | IOPS for unattached storage volumes. | `number` |
| <a name="input_storage_volume_profile"></a> [storage_volume_profile](#input_storage_volume_profile) | IBM Cloud volume profile for unattached storage volumes. | `string` |
| <a name="input_storage_volume_size"></a> [storage_volume_size](#input_storage_volume_size) | Size of each unattached storage volume in GB. | `number` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Number of virtual server instances to be launched for compute cluster. | `number` |
| <a name="input_total_gateway_instances"></a> [total_gateway_instances](#input_total_gateway_instances) | Number of virtual server instances to be launched for gateway nodes. | `number` |
| <a name="input_total_protocol_instances"></a> [total_protocol_instances](#input_total_protocol_instances) | Number of virtual server instances to be launched for protocol nodes. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Number of virtual server instances to be launched for storage cluster. | `number` |
| <a name="input_total_storage_volumes"></a> [total_storage_volumes](#input_total_storage_volumes) | Number of unattached storage volumes to provision. | `number` |
| <a name="input_using_jumphost_connection"></a> [using_jumphost_connection](#input_using_jumphost_connection) | This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_security_group_ref`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups. | `bool` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#input_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. | `list(string)` |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC id were to deploy the bastion. | `string` |
| <a name="input_vpc_protocol_cluster_private_subnets"></a> [vpc_protocol_cluster_private_subnets](#input_vpc_protocol_cluster_private_subnets) | List of IDs of protocol cluster private subnets. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where resources will be provisioned. Example: us-south. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#input_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. | `list(string)` |
| <a name="input_dns_service_instance_id"></a> [dns_service_instance_id](#input_dns_service_instance_id) | IBM Cloud DNS Service Instance Id | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | List of tags to attach to resources in format key:value | `list(string)` |
| <a name="input_vpc_compute_cluster_dns_zone_id"></a> [vpc_compute_cluster_dns_zone_id](#input_vpc_compute_cluster_dns_zone_id) | DNS zone ID for compute cluster. | `string` |
| <a name="input_vpc_reverse_dns_zone_id"></a> [vpc_reverse_dns_zone_id](#input_vpc_reverse_dns_zone_id) | DNS zone ID for reverse DNS lookups. | `string` |
| <a name="input_vpc_storage_cluster_dns_zone_id"></a> [vpc_storage_cluster_dns_zone_id](#input_vpc_storage_cluster_dns_zone_id) | DNS zone ID for storage cluster. | `string` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_airgap"></a> [airgap](#output_airgap) | Air gap environment |
| <a name="output_ces_private_ips"></a> [ces_private_ips](#output_ces_private_ips) | CES/Protocol ENI (secondary private) ips. |
| <a name="output_compute_cluster_instance_details"></a> [compute_cluster_instance_details](#output_compute_cluster_instance_details) | Compute cluster instance details (map of id, private_ip, dns) |
| <a name="output_compute_cluster_security_group_id"></a> [compute_cluster_security_group_id](#output_compute_cluster_security_group_id) | Compute cluster security group id. |
| <a name="output_gateway_instance_details"></a> [gateway_instance_details](#output_gateway_instance_details) | Gateway instance details (map of id, private_ip, dns) |
| <a name="output_placement_group_id"></a> [placement_group_id](#output_placement_group_id) | IBM Cloud placement group id. |
| <a name="output_protocol_cluster_security_group_id"></a> [protocol_cluster_security_group_id](#output_protocol_cluster_security_group_id) | Protocol cluster security group id. |
| <a name="output_protocol_instance_details"></a> [protocol_instance_details](#output_protocol_instance_details) | Protocol instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_dec_instance_details"></a> [storage_cluster_dec_instance_details](#output_storage_cluster_dec_instance_details) | Storage cluster desc instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_desc_data_volume_mapping"></a> [storage_cluster_desc_data_volume_mapping](#output_storage_cluster_desc_data_volume_mapping) | Mapping of storage cluster desc instance ip vs. device path. |
| <a name="output_storage_cluster_instance_details"></a> [storage_cluster_instance_details](#output_storage_cluster_instance_details) | Protocol instance details (map of id, private_ip, dns) |
| <a name="output_storage_cluster_security_group_id"></a> [storage_cluster_security_group_id](#output_storage_cluster_security_group_id) | Storage cluster security group id. |
| <a name="output_storage_cluster_with_data_volume_mapping"></a> [storage_cluster_with_data_volume_mapping](#output_storage_cluster_with_data_volume_mapping) | Mapping of storage cluster instance ip vs. device path. |
| <a name="output_storage_instance_ips_with_disk_mapping"></a> [storage_instance_ips_with_disk_mapping](#output_storage_instance_ips_with_disk_mapping) | n/a |
| <a name="output_storage_vm_zone_map"></a> [storage_vm_zone_map](#output_storage_vm_zone_map) | n/a |
<!-- END_TF_DOCS -->
