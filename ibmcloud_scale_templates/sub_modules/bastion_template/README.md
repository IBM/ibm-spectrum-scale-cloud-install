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
    "vpc_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "bastion_instance_type": "cx2-2x4",
    "bastion_image_ref": "r006-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bastion_public_key_path": "/path/to/your/ssh/key.pub",
    "vpc_auto_scaling_group_subnet_ids": ["0717-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
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
    "vpc_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "bastion_instance_type": "cx2-2x4",
    "bastion_image_ref": "r006-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bastion_public_key_path": "/path/to/bastion-ssh-key.pub",
    "vpc_auto_scaling_group_subnet_ids": ["0717-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
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
    "vpc_id": "r006-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "bastion_instance_type": "cx2-4x8",
    "bastion_image_ref": "r006-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "bastion_public_key_path": "/path/to/prod-bastion-key.pub",
    "vpc_auto_scaling_group_subnet_ids": ["0717-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"],
    "remote_cidr_blocks": [
        "x.x.x.x/x",    // Office network
        "x.x.x.x/x"   // Admin workstation
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
  source                              = "../sub_modules/bastion_template"
  ibmcloud_api_key                    = var.ibmcloud_api_key
  vpc_region                          = var.vpc_region
  vpc_availability_zones              = var.vpc_availability_zones
  vpc_id                              = module.vpc.vpc_id
  resource_prefix                     = var.resource_prefix
  resource_group_id                   = module.vpc.resource_group_id
  bastion_image_ref                   = var.bastion_image_ref
  bastion_instance_type               = var.bastion_instance_type
  bastion_public_key_path             = var.bastion_public_key_path
  vpc_auto_scaling_group_subnet_ids   = [module.vpc.vpc_storage_cluster_private_subnets[0]]
  remote_cidr_blocks                  = var.remote_cidr_blocks
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
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | ~> 2 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | The IBM Cloud platform API key. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | ID of the IBM Cloud resource group for bastion resources. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix added to all resource names for identification and organization (e.g., 'ibm-storage-scale'). | `string` |
| <a name="input_vpc_auto_scaling_group_subnet_ids"></a> [vpc_auto_scaling_group_subnet_ids](#input_vpc_auto_scaling_group_subnet_ids) | List of subnet IDs where the Auto Scaling Group will deploy the instances. | `list(string)` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | A list of availability zones names or ids in the region. | `list(string)` |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | ID of the VPC where to deploy the bastion. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where bastion and all resources will be deployed (e.g., 'us-east', 'us-south', 'eu-de'). | `string` |
| <a name="input_bastion_image_ref"></a> [bastion_image_ref](#input_bastion_image_ref) | IBM Cloud image ID for the bastion instance. Required when enable_bastion is true. | `string` |
| <a name="input_bastion_instance_type"></a> [bastion_instance_type](#input_bastion_instance_type) | Instance type to use for the bastion instance. Required when enable_bastion is true. | `string` |
| <a name="input_bastion_public_key_path"></a> [bastion_public_key_path](#input_bastion_public_key_path) | Path to the SSH public key file for bastion host access. Required when enable_bastion is true. | `string` |
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
| <a name="output_bastion_security_group_name"></a> [bastion_security_group_name](#output_bastion_security_group_name) | Bastion security group name. |
<!-- END_TF_DOCS -->
