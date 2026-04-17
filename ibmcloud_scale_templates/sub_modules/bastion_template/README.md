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
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "scale-bastion",
    "resource_group_id": "xxxx-xxxx-xxxx-xxxx",
    "vpc_id": "r013-xxxx-xxxx-xxxx",
    "bastion_vsi_profile": "cx2-2x4",
    "bastion_osimage_name": "ibm-ubuntu-22-04-minimal-amd64-2",
    "bastion_key_pair": "my-ssh-key",
    "bastion_subnet_id": "xxxx-xxxx-xxxx-xxxx",
    "remote_cidr_blocks": ["203.0.113.0/24"]
}
```

### 3. Set IBM Cloud Credentials

```bash
export IC_API_KEY="your-ibm-cloud-api-key"
```

### 4. Deploy Bastion

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Basic Bastion Host

```jsonc
{
    "vpc_region": "us-south",
    "vpc_availability_zones": ["us-south-1"],
    "resource_prefix": "bastion",
    "resource_group_id": "abc123-def456-ghi789",
    "vpc_id": "r013-vpc-id-here",
    "bastion_vsi_profile": "cx2-2x4",
    "bastion_osimage_name": "ibm-ubuntu-22-04-minimal-amd64-2",
    "bastion_key_pair": "bastion-ssh-key",
    "bastion_subnet_id": "subnet-id-here",
    "remote_cidr_blocks": ["0.0.0.0/0"]
}
```

### Example 2: Restricted Access Bastion

```jsonc
{
    "vpc_region": "us-east",
    "vpc_availability_zones": ["us-east-1"],
    "resource_prefix": "prod-bastion",
    "resource_group_id": "abc123-def456-ghi789",
    "vpc_id": "r013-vpc-id-here",
    "bastion_vsi_profile": "cx2-4x8",
    "bastion_osimage_name": "ibm-ubuntu-22-04-minimal-amd64-2",
    "bastion_key_pair": "prod-bastion-key",
    "bastion_subnet_id": "subnet-id-here",
    "remote_cidr_blocks": [
        "203.0.113.0/24",    // Office network
        "198.51.100.50/32"   // Admin workstation
    ]
}
```

## Usage

### Access Bastion Host

```bash
# Get bastion public IP from Terraform output
terraform output bastion_instance_public_ip

# SSH to bastion
ssh -i ~/.ssh/bastion-key root@<bastion-public-ip>
```

### Use Bastion as Jump Host

```bash
# SSH to private instance through bastion
ssh -J root@<bastion-ip> root@<private-instance-ip>

# Or configure SSH config (~/.ssh/config)
Host bastion
    HostName <bastion-public-ip>
    User root
    IdentityFile ~/.ssh/bastion-key

Host private-instance
    HostName <private-ip>
    User root
    ProxyJump bastion
    IdentityFile ~/.ssh/cluster-key

# Then simply:
ssh private-instance
```

### File Transfer Through Bastion

```bash
# Copy file to private instance via bastion
scp -o ProxyJump=root@<bastion-ip> file.txt root@<private-ip>:/tmp/

# Copy from private instance
scp -o ProxyJump=root@<bastion-ip> root@<private-ip>:/tmp/file.txt ./
```

## Security Considerations

### Best Practices

1. **Restrict Access**: Limit `remote_cidr_blocks` to known IP addresses
2. **Use Strong Keys**: Generate dedicated SSH keys for bastion access
3. **Regular Updates**: Keep bastion OS and packages updated
4. **Monitoring**: Enable logging and monitoring for bastion access
5. **Minimal Software**: Install only necessary packages on bastion

### Security Checklist

- [ ] Restrict `remote_cidr_blocks` to specific IPs/ranges
- [ ] Use dedicated SSH key for bastion (not shared with other instances)
- [ ] Enable SSH key-based authentication only (disable password auth)
- [ ] Configure SSH session timeout
- [ ] Enable audit logging
- [ ] Regular security updates
- [ ] Monitor failed login attempts
- [ ] Implement SSH rate limiting

### Hardening Bastion Host

```bash
# After deployment, SSH to bastion and run:

# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Configure SSH (edit /etc/ssh/sshd_config)
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 3. Install fail2ban for brute force protection
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 4. Configure firewall
sudo ufw allow 22/tcp
sudo ufw enable
```

## Troubleshooting

### Cannot Connect to Bastion

**Problem**: SSH connection timeout or refused

**Solutions**:
```bash
# 1. Verify bastion is running
ibmcloud is instance <bastion-instance-id>

# 2. Check security group rules
ibmcloud is security-group-rules <bastion-sg-id>

# 3. Verify your IP is in remote_cidr_blocks
curl ifconfig.me  # Get your public IP

# 4. Test connectivity
ping <bastion-public-ip>
telnet <bastion-public-ip> 22

# 5. Check SSH key
ssh-keygen -l -f ~/.ssh/bastion-key.pub
```

### Permission Denied (publickey)

**Problem**: SSH authentication fails

**Solutions**:
```bash
# 1. Verify correct SSH key
ssh-add -l

# 2. Use correct key explicitly
ssh -i ~/.ssh/correct-key root@<bastion-ip>

# 3. Check key permissions
chmod 600 ~/.ssh/bastion-key
chmod 644 ~/.ssh/bastion-key.pub

# 4. Verify key matches IBM Cloud
ibmcloud is key <key-name>
```

### Bastion Performance Issues

**Problem**: Slow or unresponsive bastion

**Solutions**:
```bash
# 1. Check instance profile (may need upgrade)
# Current: cx2-2x4 (2 vCPU, 4GB RAM)
# Upgrade to: cx2-4x8 (4 vCPU, 8GB RAM)

# 2. Monitor resource usage
ssh root@<bastion-ip>
top
df -h
free -m

# 3. Check network connectivity
ping 8.8.8.8
traceroute <private-instance-ip>
```

## Cost Optimization

### Instance Profile Recommendations

| Use Case | Profile | vCPU | RAM | Cost/Month |
|----------|---------|------|-----|------------|
| Small/Dev | cx2-2x4 | 2 | 4GB | ~$30-40 |
| Medium/Prod | cx2-4x8 | 4 | 8GB | ~$60-80 |
| Large/Enterprise | cx2-8x16 | 8 | 16GB | ~$120-160 |

### Cost Saving Tips

1. **Right-size**: Start with cx2-2x4 and scale up if needed
2. **Reserved Instances**: Save up to 30% with 1-year commitment
3. **Shutdown**: Stop bastion when not in use (dev/test environments)
4. **Shared Bastion**: Use one bastion for multiple VPCs (with VPC peering)

## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output bastion_instance_id
terraform output bastion_instance_public_ip
terraform output bastion_instance_private_ip
terraform output bastion_security_group_id
```

## Integration with Main Template

This sub-module is automatically used by the main `ibmcloud_new_vpc_scale` template:

```hcl
module "bastion" {
  source                 = "../sub_modules/bastion_template"
  vpc_region             = var.vpc_region
  vpc_availability_zones = var.vpc_availability_zones
  vpc_id                 = module.vpc.vpc_id
  resource_prefix        = var.resource_prefix
  resource_group_id      = data.ibm_resource_group.itself.id
  bastion_osimage_name   = var.bastion_osimage_name
  remote_cidr_blocks     = var.remote_cidr_blocks
  bastion_vsi_profile    = var.bastion_vsi_profile
  bastion_key_pair       = var.bastion_key_pair
  bastion_subnet_id      = module.vpc.vpc_storage_cluster_private_subnets[0]
}
```

## Cleanup

```bash
# Destroy bastion resources
terraform destroy -auto-approve
```

## Additional Resources

- [IBM Cloud VPC Bastion Host](https://cloud.ibm.com/docs/solution-tutorials?topic=solution-tutorials-vpc-secure-management-bastion-server)
- [SSH Best Practices](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)
- [VPC Security Groups](https://cloud.ibm.com/docs/vpc?topic=vpc-using-security-groups)

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_key_pair"></a> [bastion_key_pair](#input_bastion_key_pair) | The key pair to use to launch the bastion host. | `string` | n/a | yes |
| <a name="input_bastion_osimage_name"></a> [bastion_osimage_name](#input_bastion_osimage_name) | Bastion OS image name. | `string` | n/a | yes |
| <a name="input_bastion_subnet_id"></a> [bastion_subnet_id](#input_bastion_subnet_id) | Subnet ID where bastion will be deployed. | `string` | n/a | yes |
| <a name="input_bastion_vsi_profile"></a> [bastion_vsi_profile](#input_bastion_vsi_profile) | Profile to be used for Bastion virtual server instance. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | IBM Cloud resource group ID. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix is added to all resources that are created. | `string` | n/a | yes |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC ID where bastion will be deployed. | `string` | n/a | yes |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | The region where IBM Cloud operations will take place. | `string` | n/a | yes |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | List of CIDRs that can access the bastion. Default: 0.0.0.0/0 | `list(string)` | `["0.0.0.0/0"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_id"></a> [bastion_instance_id](#output_bastion_instance_id) | Bastion instance ID. |
| <a name="output_bastion_instance_private_ip"></a> [bastion_instance_private_ip](#output_bastion_instance_private_ip) | Bastion instance private IP address. |
| <a name="output_bastion_instance_public_ip"></a> [bastion_instance_public_ip](#output_bastion_instance_public_ip) | Bastion instance public IP address. |
| <a name="output_bastion_security_group_id"></a> [bastion_security_group_id](#output_bastion_security_group_id) | Bastion security group ID. |
<!-- END_TF_DOCS -->
