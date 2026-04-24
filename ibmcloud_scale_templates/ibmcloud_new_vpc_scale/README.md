# IBM Spectrum Scale on IBM Cloud - New VPC Template

The IBM Spectrum Scale on IBM Cloud template provisions a complete infrastructure for deploying IBM Spectrum Scale clusters on IBM Cloud VPC. This Terraform template creates a new VPC, bastion host, and compute/storage instances configured for IBM Spectrum Scale deployment.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration Examples](#configuration-examples)
- [Deployment Steps](#deployment-steps)
- [Post-Deployment](#post-deployment)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Cost Estimation](#cost-estimation)
- [Security Considerations](#security-considerations)
- [Additional Resources](#additional-resources)

## Overview

This template automates the provisioning of:

- **VPC Infrastructure**: New VPC with configurable CIDR blocks and subnets
- **Bastion Host**: Jump server for secure access to private instances
- **DNS Configuration**: Optional private DNS zones for cluster communication
- **Compute Cluster**: Optional compute nodes for workload processing
- **Storage Cluster**: Storage nodes with attached block volumes
- **Security Groups**: Network security rules for cluster communication
- **Activity Tracker**: Optional IBM Cloud Activity Tracker for audit logging

### What This Template Does

✅ Creates complete VPC infrastructure
✅ Provisions bastion host with public IP
✅ Deploys compute and storage instances
✅ Configures private DNS zones
✅ Sets up security groups and network rules
✅ Attaches block storage volumes to storage nodes

### What This Template Does NOT Do

❌ Install IBM Spectrum Scale software
❌ Configure passwordless SSH between nodes
❌ Create Spectrum Scale cluster
❌ Configure filesystems

> **Note**: This template provisions infrastructure only. IBM Spectrum Scale installation and configuration must be performed manually after deployment.

## Architecture

### Single-Zone Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    IBM Cloud VPC (us-south)                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Public Subnet (10.241.0.0/24)           │  │
│  │                                                       │  │
│  │  ┌─────────────┐                                     │  │
│  │  │   Bastion   │ (Public IP: x.x.x.x)                │  │
│  │  │   Host      │ (Private IP: 10.241.0.4)            │  │
│  │  └──────┬──────┘                                     │  │
│  └─────────┼────────────────────────────────────────────┘  │
│            │                                                │
│  ┌─────────┴────────────────────────────────────────────┐  │
│  │         Private Subnet (10.241.1.0/24)               │  │
│  │                                                       │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │  │
│  │  │Storage-1 │  │Storage-2 │  │Storage-N │          │  │
│  │  │+ Volumes │  │+ Volumes │  │+ Volumes │          │  │
│  │  └──────────┘  └──────────┘  └──────────┘          │  │
│  │                                                       │  │
│  │  ┌──────────┐  ┌──────────┐                         │  │
│  │  │Compute-1 │  │Compute-2 │                         │  │
│  │  └──────────┘  └──────────┘                         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  DNS Zones:                                                  │
│  • strgscale.com (Storage Cluster)                          │
│  • compscale.com (Compute Cluster)                          │
└─────────────────────────────────────────────────────────────┘
```

### Multi-Zone Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    IBM Cloud VPC (us-south)                       │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Zone 1        │  │   Zone 2        │  │   Zone 3        │ │
│  │  (us-south-1)   │  │  (us-south-2)   │  │  (us-south-3)   │ │
│  │                 │  │                 │  │                 │ │
│  │  ┌──────────┐   │  │  ┌──────────┐   │  │  ┌──────────┐   │ │
│  │  │Storage-1 │   │  │  │Storage-2 │   │  │  │Storage-3 │   │ │
│  │  │+ Volumes │   │  │  │+ Volumes │   │  │  │+ Volumes │   │ │
│  │  └──────────┘   │  │  └──────────┘   │  │  └──────────┘   │ │
│  │                 │  │                 │  │                 │ │
│  │  ┌──────────┐   │  │  ┌──────────┐   │  │                 │ │
│  │  │Compute-1 │   │  │  │Compute-2 │   │  │                 │ │
│  │  └──────────┘   │  │  └──────────┘   │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                   │
│  Bastion Host: Zone 1 with Public IP                             │
└──────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required

1. **IBM Cloud Account** with appropriate permissions
2. **IBM Cloud API Key** ([How to create](https://cloud.ibm.com/docs/account?topic=account-userapikey))
3. **SSH Key Pair** already created in IBM Cloud ([How to create](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys))
4. **Terraform** v1.0 or later ([Download](https://www.terraform.io/downloads))
5. **IBM Cloud Provider** v1.84.3

### Recommended

- **IBM Cloud CLI** for resource management ([Install](https://cloud.ibm.com/docs/cli))
- **jq** for JSON processing
- Basic understanding of IBM Spectrum Scale architecture

### Permissions Required

Your IBM Cloud API key must have:
- VPC Infrastructure Services permissions
- Resource Group access
- DNS Services permissions (if using private DNS)
- Activity Tracker permissions (if enabled)

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/IBM/ibm-spectrum-scale-cloud-install.git
cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/ibmcloud_new_vpc_scale/
```

### 2. Create SSH Keys in IBM Cloud

```bash
# Login to IBM Cloud
ibmcloud login

# Create SSH key for bastion
ibmcloud is key-create bastion-key @~/.ssh/id_rsa.pub

# Create SSH key for compute cluster
ibmcloud is key-create compute-key @~/.ssh/id_rsa.pub

# Create SSH key for storage cluster
ibmcloud is key-create storage-key @~/.ssh/id_rsa.pub

# List keys to verify
ibmcloud is keys
```

### 3. Create API Key

```bash
# Create API key
ibmcloud iam api-key-create spectrum-scale-key -d "API key for Spectrum Scale deployment"

# Export API key
export IC_API_KEY="your-api-key-here"
```

### 4. Create Configuration File

Create `terraform.tfvars.json`:

```jsonc
{
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_group": "default",
    "bastion_key_pair": "bastion-key",
    "compute_cluster_key_pair": "compute-key",
    "storage_cluster_key_pair": "storage-key",
    "bastion_ssh_private_key": "/home/user/.ssh/id_rsa",
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "YourSecurePassword123!",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "YourSecurePassword123!",
    "vpc_create_separate_subnets": false,
    "total_storage_cluster_instances": 2,
    "total_compute_cluster_instances": 0,

    // Optional: DNS Service Configuration
    // Leave empty or omit to skip DNS record creation
    "dns_service_instance_id": ""
}
```

> **Note**: The `dns_service_instance_id` parameter is optional. If not provided or left empty, DNS records will not be created. This is useful when you don't have an IBM Cloud DNS Services instance or prefer to manage DNS separately.

### 5. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan -var-file=terraform.tfvars.json

# Deploy infrastructure
terraform apply -var-file=terraform.tfvars.json
```

### 6. Access Bastion Host

```bash
# Get bastion public IP
terraform output bastion_instance_public_ip

# SSH to bastion
ssh -i ~/.ssh/id_rsa root@<bastion-public-ip>
```

## Configuration Examples

> **Note**: All examples below include ALL required variables. Optional variables with defaults are commented out but shown for reference.

### Example 1: Minimal Storage-Only Cluster (Single Zone)

**Required Variables Only:**

```json
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_group": "default",
    "bastion_key_pair": "bastion-key",
    "bastion_ssh_private_key": "/root/.ssh/id_rsa",
    "compute_cluster_key_pair": "/root/.ssh/compute_id_rsa.pub",
    "storage_cluster_key_pair": "/root/.ssh/storage_id_rsa.pub",
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "SecurePass123!",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "SecurePass123!"
}
```

**With Common Optional Variables:**

```jsonc
{
    // ============ REQUIRED VARIABLES ============
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_group": "default",

    // SSH Keys (bastion_key_pair must exist in IBM Cloud, others are file paths)
    "bastion_key_pair": "bastion-key",
    "bastion_ssh_private_key": "/root/.ssh/id_rsa",
    "compute_cluster_key_pair": "/root/.ssh/compute_id_rsa.pub",
    "storage_cluster_key_pair": "/root/.ssh/storage_id_rsa.pub",

    // GUI Credentials (required for Spectrum Scale management)
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "SecurePass123!",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "SecurePass123!",

    // ============ OPTIONAL VARIABLES (with defaults) ============
    "resource_prefix": "spectrum-scale",
    "vpc_cidr_block": ["10.241.0.0/18"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "vpc_create_separate_subnets": false,
    "total_storage_cluster_instances": 2,
    "total_compute_cluster_instances": 0,
    "storage_vsi_profile": "bx2d-8x32",
    "compute_vsi_profile": "cx2-2x4",
    "bastion_vsi_profile": "cx2-2x4",
    "storage_vsi_osimage_name": "ibm-redhat-8-3-minimal-amd64-3",
    "compute_vsi_osimage_name": "ibm-redhat-8-3-minimal-amd64-3",
    "bastion_osimage_name": "ibm-ubuntu-20-04-2-minimal-amd64-1",
    "vpc_storage_cluster_dns_domain": "strgscale.com",
    "vpc_compute_cluster_dns_domain": "compscale.com",
    "dns_service_instance_id": "",
    "storage_cluster_filesystem_mountpoint": "/gpfs/fs1",
    "compute_cluster_filesystem_mountpoint": "/gpfs/fs1",
    "filesystem_block_size": "4M",
    "remote_cidr_blocks": ["0.0.0.0/0"],
    "create_separate_namespaces": true,
    "enable_placement_group": true
}
```

### Example 2: Compute + Storage Cluster (Single Zone)

```jsonc
{
    // ============ REQUIRED VARIABLES ============
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_group": "default",
    "resource_prefix": "scale-prod",

    // SSH Keys
    "bastion_key_pair": "bastion-key",
    "bastion_ssh_private_key": "/home/user/.ssh/id_rsa",
    "compute_cluster_key_pair": "/home/user/.ssh/compute_id_rsa.pub",
    "storage_cluster_key_pair": "/home/user/.ssh/storage_id_rsa.pub",

    // GUI Credentials
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "StoragePass123!",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "ComputePass123!",

    // ============ CUSTOMIZED OPTIONAL VARIABLES ============
    // Network Configuration
    "vpc_create_separate_subnets": true,
    "vpc_cidr_block": ["10.241.0.0/18"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24"],

    // DNS Configuration (leave empty to skip DNS record creation)
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "dns_service_instance_id": "",

    // Cluster Sizing
    "total_storage_cluster_instances": 4,
    "total_compute_cluster_instances": 2,

    // Instance Profiles
    "storage_vsi_profile": "bx2d-8x32",
    "compute_vsi_profile": "cx2-4x8",
    "bastion_vsi_profile": "cx2-2x4",

    // OS Images (use image IDs or names)
    "storage_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "compute_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "bastion_osimage_name": "ibm-ubuntu-22-04-minimal-amd64-2",

    // Filesystem Configuration
    "filesystem_block_size": "4M",
    "storage_cluster_filesystem_mountpoint": "/gpfs/fs1",
    "compute_cluster_filesystem_mountpoint": "/gpfs/fs1",

    // Security (restrict bastion access to your IP)
    "remote_cidr_blocks": ["203.0.113.0/24"],

    // Optional Features
    "create_separate_namespaces": true,
    "enable_placement_group": true
}
```

### Example 3: Multi-Zone High Availability Cluster

```jsonc
{
    // ============ REQUIRED VARIABLES ============
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1", "us-south-2", "us-south-3"],
    "resource_group": "production",
    "resource_prefix": "scale-ha",

    // SSH Keys
    "bastion_key_pair": "bastion-key",
    "bastion_ssh_private_key": "/home/user/.ssh/id_rsa",
    "compute_cluster_key_pair": "/home/user/.ssh/compute_id_rsa.pub",
    "storage_cluster_key_pair": "/home/user/.ssh/storage_id_rsa.pub",

    // GUI Credentials
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "StoragePass123!",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "ComputePass123!",

    // ============ CUSTOMIZED OPTIONAL VARIABLES ============
    // Network Configuration (Multi-Zone requires CIDR per zone)
    "vpc_create_separate_subnets": true,
    "vpc_cidr_block": ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": [
        "10.241.1.0/24",
        "10.241.64.1/24",
        "10.241.128.1/24"
    ],
    "vpc_compute_cluster_private_subnets_cidr_blocks": [
        "10.241.0.0/24",
        "10.241.64.0/24",
        "10.241.128.0/24"
    ],

    // DNS Configuration (Optional: provide DNS Service GUID for automatic DNS records)
    "vpc_storage_cluster_dns_domain": "storage.scale.local",
    "vpc_compute_cluster_dns_domain": "compute.scale.local",
    "dns_service_instance_id": "12345678-1234-1234-1234-123456789abc",

    // Cluster Sizing (instances distributed across zones)
    "total_storage_cluster_instances": 6,
    "total_compute_cluster_instances": 3,

    // Instance Profiles
    "storage_vsi_profile": "bx2d-16x64",
    "compute_vsi_profile": "cx2-8x16",
    "bastion_vsi_profile": "cx2-2x4",

    // OS Images
    "storage_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "compute_vsi_osimage_name": "ibm-redhat-8-6-minimal-amd64-4",
    "bastion_osimage_name": "ibm-ubuntu-22-04-minimal-amd64-2",

    // Filesystem Configuration
    "filesystem_block_size": "4M",
    "storage_cluster_filesystem_mountpoint": "/gpfs/fs1",
    "compute_cluster_filesystem_mountpoint": "/gpfs/fs1",

    // Security
    "remote_cidr_blocks": ["203.0.113.0/24"],

    // Advanced Options
    "create_separate_namespaces": true,
    "enable_placement_group": false  // Disable for multi-zone (placement groups are single-zone only)
}
```

### Example 4: Complete Configuration with All Variables

```jsonc
{
    // ============ REQUIRED VARIABLES ============
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_group": "default",

    // SSH Keys
    "bastion_key_pair": "bastion-key",
    "bastion_ssh_private_key": "/root/.ssh/id_rsa",
    "compute_cluster_key_pair": "/root/.ssh/compute_id_rsa.pub",
    "storage_cluster_key_pair": "/root/.ssh/storage_id_rsa.pub",

    // GUI Credentials
    "storage_cluster_gui_username": "admin",
    "storage_cluster_gui_password": "SecurePass123!",
    "compute_cluster_gui_username": "admin",
    "compute_cluster_gui_password": "SecurePass123!",

    // ============ ALL OPTIONAL VARIABLES ============
    "resource_prefix": "spectrum-scale",
    "vpc_cidr_block": ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"],
    "vpc_storage_cluster_private_subnets_cidr_blocks": ["10.241.1.0/24", "10.241.64.1/24", "10.241.128.1/24"],
    "vpc_create_separate_subnets": true,
    "vpc_compute_cluster_private_subnets_cidr_blocks": ["10.241.0.0/24"],
    "remote_cidr_blocks": ["0.0.0.0/0"],
    "bastion_osimage_name": "ibm-ubuntu-20-04-2-minimal-amd64-1",
    "bastion_vsi_profile": "cx2-2x4",
    "total_compute_cluster_instances": 3,
    "compute_vsi_osimage_name": "ibm-redhat-8-3-minimal-amd64-3",
    "compute_vsi_profile": "cx2-2x4",
    "total_storage_cluster_instances": 4,
    "storage_vsi_osimage_name": "ibm-redhat-8-3-minimal-amd64-3",
    "storage_vsi_profile": "bx2d-8x32",
    "vpc_compute_cluster_dns_domain": "compscale.com",
    "vpc_storage_cluster_dns_domain": "strgscale.com",
    "dns_service_instance_id": "",
    "storage_cluster_filesystem_mountpoint": "/gpfs/fs1",
    "compute_cluster_filesystem_mountpoint": "/gpfs/fs1",
    "filesystem_block_size": "4M",
    "create_separate_namespaces": true,
    "enable_placement_group": true
}
```

### Variable Categories

**Required Variables (Must be provided):**
- `ibmcloud_api_key` - IBM Cloud API key for authentication
- `vpc_region` - IBM Cloud region (e.g., us-south, us-east)
- `vpc_availability_zones` - List of availability zones
- `resource_group` - IBM Cloud resource group name
- `bastion_key_pair` - SSH key name (must exist in IBM Cloud)
- `bastion_ssh_private_key` - Path to bastion private key file
- `compute_cluster_key_pair` - Path to compute cluster public key file
- `storage_cluster_key_pair` - Path to storage cluster public key file
- `storage_cluster_gui_username` - Spectrum Scale GUI username
- `storage_cluster_gui_password` - Spectrum Scale GUI password
- `compute_cluster_gui_username` - Spectrum Scale GUI username
- `compute_cluster_gui_password` - Spectrum Scale GUI password

**Optional Variables (Have defaults):**
- All other variables have sensible defaults and can be omitted
- See the "Inputs" section below for complete list with defaults

## Deployment Steps

### Step 1: Initialize Terraform

```bash
terraform init
```

This downloads the required IBM Cloud provider plugin.

### Step 2: Validate Configuration

```bash
terraform validate
```

Checks for syntax errors in your configuration.

### Step 3: Plan Deployment

```bash
terraform plan -var-file=terraform.tfvars.json
```

Review the resources that will be created. Look for:
- VPC and subnets
- Security groups
- Instances (bastion, compute, storage)
- DNS zones
- Block storage volumes

### Step 4: Apply Configuration

```bash
terraform apply -var-file=terraform.tfvars.json
```

Type `yes` when prompted. Deployment typically takes 10-15 minutes.

### Step 5: Save Outputs

```bash
# Save all outputs to file
terraform output -json > outputs.json

# View specific outputs
terraform output bastion_instance_public_ip
terraform output storage_cluster_instance_private_ips
terraform output compute_cluster_instance_private_ips
```

## Post-Deployment

### Access Your Infrastructure

#### 1. SSH to Bastion Host

```bash
# Get bastion IP
BASTION_IP=$(terraform output -raw bastion_instance_public_ip)

# SSH to bastion
ssh -i ~/.ssh/id_rsa root@${BASTION_IP}
```

#### 2. Access Cluster Nodes from Bastion

```bash
# From bastion, SSH to storage nodes
ssh root@storage-node-1.strgscale.com
ssh root@10.241.1.4

# SSH to compute nodes
ssh root@compute-node-1.compscale.com
ssh root@10.241.0.4
```

### Verify Infrastructure

```bash
# Check VPC
ibmcloud is vpcs

# List instances
ibmcloud is instances

# Check subnets
ibmcloud is subnets

# View security groups
ibmcloud is security-groups

# Check DNS zones
ibmcloud dns zones
```

### Install IBM Spectrum Scale

> **Important**: This template does NOT install Spectrum Scale. You must install it manually.

#### Prerequisites for Installation

1. **Download Spectrum Scale RPMs** from IBM Fix Central
2. **Transfer RPMs to bastion host**
3. **Distribute RPMs to all cluster nodes**

#### Installation Steps

```bash
# 1. On each node, install prerequisites
yum install -y kernel-devel kernel-headers gcc-c++ make

# 2. Copy Spectrum Scale RPMs to each node
for node in storage-node-{1..4}; do
    scp /path/to/rpms/* root@${node}:/tmp/
done

# 3. Install Spectrum Scale packages on each node
cd /tmp
rpm -ivh Spectrum_Scale*.rpm

# 4. Create cluster (on one node)
mmcrcluster -N node1:manager-quorum,node2:manager-quorum,node3:manager,node4

# 5. Accept license
mmchlicense server --accept -N all

# 6. Start GPFS
mmstartup -a

# 7. Verify cluster
mmgetstate -a
```

For detailed installation instructions, refer to:
- [IBM Spectrum Scale Installation Guide](https://www.ibm.com/docs/en/spectrum-scale)
- [IBM Spectrum Scale on Cloud Documentation](https://www.ibm.com/docs/en/spectrum-scale-cloud)

## Verification

### Infrastructure Verification

```bash
# Check all instances are running
ibmcloud is instances | grep running

# Verify DNS resolution
nslookup storage-node-1.strgscale.com
nslookup compute-node-1.compscale.com

# Test connectivity from bastion
ping storage-node-1.strgscale.com
ping compute-node-1.compscale.com

# Check security groups
ibmcloud is security-groups
```

### Network Connectivity Tests

```bash
# From bastion host
# Test SSH to storage nodes
for i in {1..4}; do
    echo "Testing storage-node-$i..."
    ssh -o ConnectTimeout=5 root@storage-node-$i.strgscale.com "hostname"
done

# Test SSH to compute nodes
for i in {1..2}; do
    echo "Testing compute-node-$i..."
    ssh -o ConnectTimeout=5 root@compute-node-$i.compscale.com "hostname"
done
```

### Spectrum Scale Verification (After Installation)

```bash
# Check cluster state
mmgetstate -a

# Verify filesystem
mmlsfs all

# Check node configuration
mmlsnode -a

# Verify disk configuration
mmlsnsd

# Check cluster health
mmhealth cluster show
```

## Troubleshooting

### Common Issues

#### Issue: Cannot SSH to Bastion Host

**Symptoms**: Connection timeout or refused

**Solutions**:
```bash
# 1. Check bastion is running
ibmcloud is instance <bastion-instance-id>

# 2. Verify security group allows SSH from your IP
ibmcloud is security-group-rules <bastion-sg-id>

# 3. Check remote_cidr_blocks includes your IP
# Update terraform.tfvars.json:
"remote_cidr_blocks": ["YOUR_IP/32"]

# 4. Verify SSH key is correct
ssh-keygen -l -f ~/.ssh/id_rsa.pub
```

#### Issue: Cannot Access Cluster Nodes from Bastion

**Symptoms**: Connection refused or timeout

**Solutions**:
```bash
# 1. Verify instances are running
ibmcloud is instances

# 2. Check security groups allow traffic from bastion
ibmcloud is security-group-rules <cluster-sg-id>

# 3. Verify DNS resolution
nslookup storage-node-1.strgscale.com

# 4. Test with private IP directly
ssh root@10.241.1.4
```

#### Issue: DNS Resolution Fails

**Symptoms**: Cannot resolve hostnames

**Solutions**:
```bash
# 1. Check if DNS service instance ID is configured
# In terraform.tfvars.json, verify dns_service_instance_id is set

# 2. Check DNS zones exist (if using DNS service)
ibmcloud dns zones

# 3. Verify DNS records (if using DNS service)
ibmcloud dns resource-records <zone-id>

# 4. Check VPC custom resolver
ibmcloud is vpc <vpc-id>

# 5. Verify /etc/resolv.conf on instances
cat /etc/resolv.conf

# 6. If not using DNS service, use IP addresses directly
ssh root@10.241.1.4
```

#### Issue: DNS Service Errors During Deployment

**Symptoms**: Error creating DNS resource records, "InstanceID failed validation"

**Solutions**:
```bash
# Option 1: Deploy without DNS (recommended if you don't need DNS)
# Remove or leave empty dns_service_instance_id in terraform.tfvars.json
"dns_service_instance_id": ""

# Option 2: Create DNS service instance
ibmcloud resource service-instance-create my-dns-service dns-svcs standard global

# Get the DNS service GUID
ibmcloud resource service-instance my-dns-service --output json | jq -r '.guid'

# Add to terraform.tfvars.json
"dns_service_instance_id": "your-dns-service-guid-here"

# Option 3: Use existing DNS service
# List existing DNS services
ibmcloud resource service-instances --service-name dns-svcs

# Get GUID of existing service
ibmcloud resource service-instance <service-name> --output json | jq -r '.guid'
```

#### Issue: Terraform Apply Fails

**Symptoms**: Error during terraform apply

**Solutions**:
```bash
# 1. Check IBM Cloud credentials
echo $IC_API_KEY

# 2. Verify resource quotas
ibmcloud resource quotas

# 3. Check region/zone availability
ibmcloud is regions
ibmcloud is zones us-south

# 4. Enable detailed logging
export TF_LOG=DEBUG
terraform apply -var-file=terraform.tfvars.json 2>&1 | tee terraform.log
```

#### Issue: Insufficient Permissions

**Symptoms**: Authorization errors

**Solutions**:
```bash
# 1. Check API key permissions
ibmcloud iam api-key <key-name>

# 2. Verify resource group access
ibmcloud resource groups

# 3. Check VPC Infrastructure permissions
ibmcloud iam user-policies <user-email>
```

### Getting Help

```bash
# View Terraform logs
terraform apply -var-file=terraform.tfvars.json 2>&1 | tee terraform.log

# Validate configuration
terraform validate

# Format configuration
terraform fmt

# Show current state
terraform show

# List resources
terraform state list
```

### Debug Mode

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

# Run terraform with debug output
terraform apply -var-file=terraform.tfvars.json
```

## Cost Estimation

### Monthly Cost Breakdown (US South Region)

| Resource | Configuration | Estimated Cost |
|----------|--------------|----------------|
| Bastion Host | cx2-2x4 | $30-50/month |
| Storage Node | bx2d-8x32 | $150-200/month per node |
| Compute Node | cx2-4x8 | $50-80/month per node |
| Block Storage | 100GB per volume | $10/month per volume |
| Public Gateway | Data transfer | Variable |
| DNS Service | Private zones | $0.50/zone/month |
| Activity Tracker | 7-day plan | $30/month |

### Example Configurations

**Small Cluster (2 storage + 2 compute)**:
- 2 × Storage nodes (bx2d-8x32): $300-400
- 2 × Compute nodes (cx2-4x8): $100-160
- 1 × Bastion (cx2-2x4): $30-50
- Block storage (8 × 100GB): $80
- **Total: ~$510-690/month**

**Medium Cluster (4 storage + 2 compute)**:
- 4 × Storage nodes (bx2d-8x32): $600-800
- 2 × Compute nodes (cx2-4x8): $100-160
- 1 × Bastion (cx2-2x4): $30-50
- Block storage (16 × 100GB): $160
- **Total: ~$890-1170/month**

**Large Cluster (6 storage + 3 compute, multi-zone)**:
- 6 × Storage nodes (bx2d-16x64): $1800-2400
- 3 × Compute nodes (cx2-8x16): $300-450
- 1 × Bastion (cx2-2x4): $30-50
- Block storage (24 × 200GB): $480
- **Total: ~$2610-3380/month**

### Cost Optimization Tips

1. **Use Reserved Instances**: Save up to 30% with 1-year or 3-year commitments
2. **Right-size Instances**: Start small and scale up based on actual usage
3. **Use Instance Storage**: bx2d profiles include local NVMe storage
4. **Optimize Block Storage**: Use appropriate IOPS tiers
5. **Clean Up Unused Resources**: Regularly review and remove unused instances
6. **Use Spot Instances**: For non-critical workloads (not recommended for storage nodes)

### Cost Estimation Tools

```bash
# Use IBM Cloud Cost Estimator
# https://cloud.ibm.com/estimator

# Check current usage
ibmcloud billing account-usage

# View resource costs
ibmcloud billing resource-instances-usage
```

## Security Considerations

### Network Security

✅ **Implemented**:
- All cluster instances in private subnets
- Access only through bastion host
- Security groups restrict traffic to necessary ports
- Separate security groups for bastion, compute, and storage

⚠️ **Recommendations**:
- Restrict `remote_cidr_blocks` to your IP range only
- Use VPN or Direct Link for production environments
- Enable VPC flow logs for network monitoring
- Implement network ACLs for additional security

### Access Control

✅ **Implemented**:
- SSH key-based authentication
- Separate SSH keys for different instance types
- No public IPs on cluster instances

⚠️ **Recommendations**:
- Rotate SSH keys regularly (every 90 days)
- Use different keys for bastion and cluster instances
- Implement jump host access logging
- Use IBM Cloud IAM for API access control

### Data Security

⚠️ **Recommendations**:
- Enable encryption for block storage volumes
- Use IBM Key Protect or HPCS for key management
- Enable encryption in transit for Spectrum Scale
- Implement data classification and access policies

### Compliance and Auditing

✅ **Optional Features**:
- IBM Cloud Activity Tracker for audit logging
- VPC flow logs for network traffic analysis

⚠️ **Recommendations**:
- Enable Activity Tracker in production
- Configure log retention policies
- Implement security monitoring and alerting
- Regular security assessments and penetration testing

### Best Practices

1. **Principle of Least Privilege**: Grant minimum necessary permissions
2. **Defense in Depth**: Multiple layers of security controls
3. **Regular Updates**: Keep OS and software up to date
4. **Monitoring**: Implement comprehensive logging and monitoring
5. **Incident Response**: Have a plan for security incidents
6. **Backup and Recovery**: Regular backups and tested recovery procedures

### Security Checklist

- [ ] Restrict bastion access to known IP addresses
- [ ] Use strong passwords for GUI credentials
- [ ] Enable encryption for sensitive data
- [ ] Implement regular security patching
- [ ] Enable Activity Tracker for audit logging
- [ ] Configure VPC flow logs
- [ ] Review security group rules regularly
- [ ] Implement SSH key rotation policy
- [ ] Enable MFA for IBM Cloud account
- [ ] Document security procedures

## Cleanup

### Destroy All Resources

```bash
# Review what will be destroyed
terraform plan -destroy -var-file=terraform.tfvars.json

# Destroy infrastructure
terraform destroy -var-file=terraform.tfvars.json

# Confirm when prompted by typing: yes
```

⚠️ **Warning**: This will permanently delete:
- All instances (bastion, compute, storage)
- Block storage volumes and data
- VPC and subnets
- Security groups
- DNS zones and records
- Activity Tracker instance (if created)

### Selective Resource Removal

```bash
# Remove specific resource
terraform destroy -target=module.scale_instances -var-file=terraform.tfvars.json

# Remove only compute instances
terraform destroy -target=module.scale_instances.ibm_is_instance.compute -var-file=terraform.tfvars.json
```

### Backup Before Destroy

```bash
# Export Terraform state
terraform state pull > terraform.tfstate.backup

# Save outputs
terraform output -json > outputs.backup.json

# Backup any data from instances before destroying
```

## Additional Resources

### Documentation

- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [IBM Spectrum Scale Documentation](https://www.ibm.com/docs/en/spectrum-scale)
- [IBM Spectrum Scale on Cloud](https://www.ibm.com/docs/en/spectrum-scale-cloud)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [IBM Cloud CLI Reference](https://cloud.ibm.com/docs/cli)

### Tutorials and Guides

- [Getting Started with IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-getting-started)
- [IBM Spectrum Scale Installation Guide](https://www.ibm.com/docs/en/spectrum-scale/5.1.x?topic=installing-spectrum-scale)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### Support

- **Infrastructure Issues**: Open an issue in this repository
- **IBM Cloud Platform**: [IBM Cloud Support](https://cloud.ibm.com/unifiedsupport)
- **IBM Spectrum Scale**: [IBM Spectrum Scale Support](https://www.ibm.com/mysupport)
- **Community**: [IBM Spectrum Scale Community](https://community.ibm.com/community/user/storage/communities/community-home?CommunityKey=6e4e8c9e-6e4e-4c9e-8c9e-6e4e8c9e6e4e)

### Related Templates

- [AWS Spectrum Scale Template](../../aws_scale_templates/)
- [Azure Spectrum Scale Template](../../azure_scale_templates/)
- [GCP Spectrum Scale Template](../../gcp_scale_templates/)

## DNS Configuration

### Overview

This template supports optional DNS record creation for cluster instances. DNS records are created only when you provide an IBM Cloud DNS Services instance GUID.

### DNS Service Options

#### Option 1: Without DNS Service (Default)

If you don't provide a `dns_service_instance_id`, DNS records will not be created. This is the simplest option and works well for:
- Development and testing environments
- Small clusters where you can use IP addresses
- Environments with external DNS management

**Configuration**:
```json
{
  "dns_service_instance_id": "",
  // or simply omit the parameter
}
```

**Access instances using IP addresses**:
```bash
ssh root@10.241.1.4
ssh root@10.241.1.5
```

#### Option 2: With DNS Service

If you have an IBM Cloud DNS Services instance, you can enable automatic DNS record creation for all cluster instances.

**Prerequisites**:
1. IBM Cloud DNS Services instance created
2. DNS zones created for your domains
3. DNS service GUID available

**Get DNS Service GUID**:
```bash
# List DNS service instances
ibmcloud resource service-instances --service-name dns-svcs

# Get GUID of specific instance
ibmcloud resource service-instance <service-name> --output json | jq -r '.guid'

# Example output: 12345678-1234-1234-1234-123456789abc
```

**Configuration**:
```json
{
  "dns_service_instance_id": "12345678-1234-1234-1234-123456789abc",
  "vpc_storage_cluster_dns_domain": "strgscale.com",
  "vpc_compute_cluster_dns_domain": "compscale.com"
}
```

**Access instances using hostnames**:
```bash
ssh root@spectrum-scale-storage-1.strgscale.com
ssh root@spectrum-scale-compute-1.compscale.com
```

### Creating DNS Service Instance

If you don't have a DNS service instance, create one:

```bash
# Create DNS service instance
ibmcloud resource service-instance-create my-dns-service dns-svcs standard global

# Get the GUID
DNS_GUID=$(ibmcloud resource service-instance my-dns-service --output json | jq -r '.guid')
echo "DNS Service GUID: $DNS_GUID"

# Create DNS zones
ibmcloud dns zone-create strgscale.com --instance my-dns-service --description "Storage cluster DNS zone"
ibmcloud dns zone-create compscale.com --instance my-dns-service --description "Compute cluster DNS zone"
```

### DNS Record Format

When DNS is enabled, the following records are automatically created:

**Storage Cluster**:
- `spectrum-scale-storage-1.strgscale.com` → `10.241.1.4`
- `spectrum-scale-storage-2.strgscale.com` → `10.241.1.5`
- etc.

**Compute Cluster**:
- `spectrum-scale-compute-1.compscale.com` → `10.241.0.4`
- `spectrum-scale-compute-2.compscale.com` → `10.241.0.5`
- etc.

### Important Notes

⚠️ **DNS Service GUID vs CRN**:
- Use the **GUID** (format: `12345678-1234-1234-1234-123456789abc`)
- Do NOT use the CRN (format: `crn:v1:bluemix:public:dns-svcs:...`)

⚠️ **DNS Zones Must Exist**:
- DNS zones for your domains must be created before deployment
- Zones must be associated with your VPC

⚠️ **One DNS Service Per Region**:
- IBM Cloud allows only one DNS Services instance per region
- Reuse existing DNS service if available

## Variables Reference

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 2 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password for IBM Spectrum Scale GUI access on compute cluster. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | Username for IBM Spectrum Scale GUI access on compute cluster. | `string` |
| <a name="input_compute_cluster_key_pair"></a> [compute_cluster_key_pair](#input_compute_cluster_key_pair) | Name of the SSH key pair for compute cluster instance access. | `string` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | IBM Cloud API key for authentication. | `string` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password for IBM Spectrum Scale GUI access on storage cluster. | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | Username for IBM Spectrum Scale GUI access on storage cluster. | `string` |
| <a name="input_storage_cluster_key_pair"></a> [storage_cluster_key_pair](#input_storage_cluster_key_pair) | Name of the SSH key pair for storage cluster instance access. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | List of availability zone names or IDs within the selected region for multi-zone deployment. | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where VPC and all resources will be deployed (e.g., us-east, us-south, eu-de). | `string` |
| <a name="input_bastion_key_pair"></a> [bastion_key_pair](#input_bastion_key_pair) | Name of the SSH key pair for bastion host access. Required only if enable_bastion is true. | `string` |
| <a name="input_bastion_osimage_name"></a> [bastion_osimage_name](#input_bastion_osimage_name) | IBM Cloud OS image name for bastion virtual server instance. | `string` |
| <a name="input_bastion_ssh_private_key"></a> [bastion_ssh_private_key](#input_bastion_ssh_private_key) | Local file path to SSH private key for bastion host authentication. Required only if enable_bastion is true. | `string` |
| <a name="input_bastion_vsi_profile"></a> [bastion_vsi_profile](#input_bastion_vsi_profile) | IBM Cloud VSI profile (instance type) for bastion host. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Options: 'Storage-only', 'Compute-only', 'Combined-compute-storage'. | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Mount point path for the IBM Spectrum Scale filesystem on compute cluster (accessing cluster). | `string` |
| <a name="input_compute_vsi_osimage_name"></a> [compute_vsi_osimage_name](#input_compute_vsi_osimage_name) | IBM Cloud OS image name for compute cluster virtual server instances. | `string` |
| <a name="input_compute_vsi_profile"></a> [compute_vsi_profile](#input_compute_vsi_profile) | IBM Cloud VSI profile (instance type) for compute cluster nodes. | `string` |
| <a name="input_create_dns_zone"></a> [create_dns_zone](#input_create_dns_zone) | Flag to create new private DNS zones. Set to false to reuse existing DNS zones. | `bool` |
| <a name="input_create_separate_namespaces"></a> [create_separate_namespaces](#input_create_separate_namespaces) | Create separate IBM Spectrum Scale namespaces for compute cluster instances. If false, compute nodes share storage cluster namespace. | `bool` |
| <a name="input_dns_service_instance_id"></a> [dns_service_instance_id](#input_dns_service_instance_id) | GUID of the IBM Cloud DNS Services instance for DNS record management. If not provided, a new DNS service instance will be created. | `string` |
| <a name="input_enable_bastion"></a> [enable_bastion](#input_enable_bastion) | Flag to enable or disable bastion host deployment. Set to false to skip bastion creation. | `bool` |
| <a name="input_enable_placement_group"></a> [enable_placement_group](#input_enable_placement_group) | Enable IBM Cloud placement group with host_spread strategy to distribute instances across different physical hosts in single-AZ deployments. | `bool` |
| <a name="input_enable_transit_gateway"></a> [enable_transit_gateway](#input_enable_transit_gateway) | Flag to enable Transit Gateway connection between the newly created VPC and an existing user-provided VPC. Transit Gateway enables connectivity across VPCs in the same or different regions. | `bool` |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | Block size for the IBM Spectrum Scale filesystem (e.g., 256K, 1M, 4M, 8M, 16M). | `string` |
| <a name="input_peer_vpc_crn"></a> [peer_vpc_crn](#input_peer_vpc_crn) | CRN of the existing VPC to connect via Transit Gateway. Required only if enable_transit_gateway is true and creating a new Transit Gateway. | `string` |
| <a name="input_peer_vpc_id"></a> [peer_vpc_id](#input_peer_vpc_id) | ID of the existing VPC to connect via Transit Gateway. Required only if enable_transit_gateway is true. | `string` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDR blocks allowed to access the bastion host via SSH. | `list(string)` |
| <a name="input_resource_group"></a> [resource_group](#input_resource_group) | Name of an existing IBM Cloud resource group. If not provided, a new resource group will be created using the resource_prefix. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix added to all resource names for identification and organization. | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Mount point path for the IBM Spectrum Scale filesystem on storage cluster (owning cluster). | `string` |
| <a name="input_storage_vsi_osimage_name"></a> [storage_vsi_osimage_name](#input_storage_vsi_osimage_name) | IBM Cloud OS image name for storage cluster virtual server instances. | `string` |
| <a name="input_storage_vsi_profile"></a> [storage_vsi_profile](#input_storage_vsi_profile) | IBM Cloud VSI profile (instance type) for storage cluster nodes. | `string` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Total number of virtual server instances to deploy for the compute cluster. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Total number of virtual server instances to deploy for the storage cluster. | `number` |
| <a name="input_transit_gateway_global_routing"></a> [transit_gateway_global_routing](#input_transit_gateway_global_routing) | Enable global routing for Transit Gateway to allow connections across different regions. Set to true if peer VPC is in a different region. | `bool` |
| <a name="input_transit_gateway_id"></a> [transit_gateway_id](#input_transit_gateway_id) | ID of an existing Transit Gateway to attach the new VPC to. If not provided and enable_transit_gateway is true, a new Transit Gateway will be created. | `string` |
| <a name="input_transit_gateway_name"></a> [transit_gateway_name](#input_transit_gateway_name) | Name for the new Transit Gateway. Used only if enable_transit_gateway is true and transit_gateway_id is not provided. Defaults to '<resource_prefix>-tgw'. | `string` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | CIDR block for VPC that will be automatically subdivided into address prefixes for each availability zone. | `string` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | DNS domain name for compute cluster nodes. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | List of CIDR blocks for compute cluster private subnets. Set to empty array [] to use storage cluster subnets instead. | `list(string)` |
| <a name="input_vpc_protocol_cluster_dns_domain"></a> [vpc_protocol_cluster_dns_domain](#input_vpc_protocol_cluster_dns_domain) | DNS domain name for protocol cluster nodes. | `string` |
| <a name="input_vpc_protocol_private_subnets_cidr_blocks"></a> [vpc_protocol_private_subnets_cidr_blocks](#input_vpc_protocol_private_subnets_cidr_blocks) | List of CIDR blocks for protocol node private subnets, one per availability zone. Required only if deploying protocol nodes. | `list(string)` |
| <a name="input_vpc_public_subnets_cidr_blocks"></a> [vpc_public_subnets_cidr_blocks](#input_vpc_public_subnets_cidr_blocks) | List of CIDR blocks for public subnets, one per availability zone. Set to empty array [] if no public subnets are needed. | `list(string)` |
| <a name="input_vpc_reverse_dns_zone"></a> [vpc_reverse_dns_zone](#input_vpc_reverse_dns_zone) | Reverse DNS zone name for reverse DNS lookups (PTR records). | `string` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | DNS domain name for storage cluster nodes. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | List of CIDR blocks for storage cluster private subnets, one per availability zone. | `list(string)` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_instance_ref"></a> [bastion_instance_ref](#output_bastion_instance_ref) | Bastion instance autoscaling group reference. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group id. |
| <a name="output_new_vpc_connection_id"></a> [new_vpc_connection_id](#output_new_vpc_connection_id) | ID of the Transit Gateway connection for the newly created VPC. |
| <a name="output_peer_vpc_connection_id"></a> [peer_vpc_connection_id](#output_peer_vpc_connection_id) | ID of the Transit Gateway connection for the peer VPC. |
| <a name="output_transit_gateway_crn"></a> [transit_gateway_crn](#output_transit_gateway_crn) | CRN of the Transit Gateway used for VPC connectivity. |
| <a name="output_transit_gateway_id"></a> [transit_gateway_id](#output_transit_gateway_id) | ID of the Transit Gateway used for VPC connectivity. |
| <a name="output_transit_gateway_name"></a> [transit_gateway_name](#output_transit_gateway_name) | Name of the Transit Gateway. |
| <a name="output_transit_gateway_status"></a> [transit_gateway_status](#output_transit_gateway_status) | Status of the Transit Gateway. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
