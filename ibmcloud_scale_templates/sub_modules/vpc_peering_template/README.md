# IBM Cloud VPC Peering Template

This Terraform sub-module provisions IBM Cloud Transit Gateway resources to enable VPC-to-VPC connectivity for IBM Spectrum Scale deployments.

## Overview

The VPC peering template creates:
- **Transit Gateway**: Central hub for connecting multiple VPCs (optional - can use existing)
- **VPC Connections**: Attachments for new and peer VPCs to Transit Gateway
- **Duplicate Connection Prevention**: Automatically detects if peer VPC is already attached to existing Transit Gateway
- **Global Routing**: Optional cross-region connectivity support

## Purpose

This module provides network connectivity between VPCs for Spectrum Scale:
- Connect storage and compute clusters across different VPCs
- Enable multi-region deployments with global routing
- Centralized network management through Transit Gateway
- Secure private network communication between VPCs
- **Smart duplicate detection**: Prevents creating duplicate connections when peer VPC is already attached to the Transit Gateway

## Prerequisites

- IBM Cloud VPC(s) already created
- IBM Cloud API key with Transit Gateway permissions
- Resource group configured
- VPC CRNs for the VPCs to be connected

## Quick Start

### 1. Change Directory

```bash
cd ibm-spectrum-scale-cloud-install/ibmcloud_scale_templates/sub_modules/vpc_peering_template/
```

### 2. Create Configuration File

Create `terraform.tfvars.json`:

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "enable_transit_gateway": true,
    "vpc_region": "us-south",
    "vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:VPC_ID",
    "peer_vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:PEER_VPC_ID",
    "resource_prefix": "scale-peering",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "transit_gateway_name": "scale-transit-gateway",
    "transit_gateway_global_routing": false
}
```

### 3. Deploy Transit Gateway

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Create New Transit Gateway with Two VPCs

Connect a newly created VPC with an existing peer VPC using a new Transit Gateway.

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "enable_transit_gateway": true,
    "vpc_region": "us-south",
    "vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:VPC_ID",
    "peer_vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:PEER_VPC_ID",
    "resource_prefix": "scale-dev",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "transit_gateway_name": "scale-dev-tgw",
    "transit_gateway_global_routing": false,
    "tags": [
        "environment:development",
        "project:spectrum-scale"
    ]
}
```

### Example 2: Use Existing Transit Gateway

Connect VPCs to an existing Transit Gateway instead of creating a new one. The module will automatically check if the peer VPC is already attached to the Transit Gateway and skip creating a duplicate connection.

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "enable_transit_gateway": true,
    "vpc_region": "us-south",
    "vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:VPC_ID",
    "peer_vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:PEER_VPC_ID",
    "resource_prefix": "scale-prod",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "transit_gateway_name": "existing-transit-gateway-name"
}
```

**Note**: When using an existing Transit Gateway, the module automatically checks if the peer VPC is already connected. If it is, the module will:
- Skip creating a duplicate connection
- Set `peer_vpc_already_attached` output to `true`
- Set `peer_vpc_connection_status` output to `"existing"`
- Return the existing connection ID in `peer_vpc_connection_id` output

### Example 3: Global Routing for Cross-Region Connectivity

Enable global routing to connect VPCs across different IBM Cloud regions.

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "enable_transit_gateway": true,
    "vpc_region": "us-south",
    "vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:VPC_ID",
    "peer_vpc_crn": "crn:v1:bluemix:public:is:PEER_REGION:a/ACCOUNT_ID::vpc:PEER_VPC_ID",
    "resource_prefix": "scale-global",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "transit_gateway_name": "scale-global-tgw",
    "transit_gateway_global_routing": true,
    "tags": [
        "environment:production",
        "scope:global"
    ]
}
```

### Example 4: Single VPC Connection

Connect only the new VPC to Transit Gateway without a peer VPC.

```jsonc
{
    "ibmcloud_api_key": "YOUR_IBM_CLOUD_API_KEY",
    "enable_transit_gateway": true,
    "vpc_region": "us-east",
    "vpc_crn": "crn:v1:bluemix:public:is:REGION:a/ACCOUNT_ID::vpc:VPC_ID",
    "resource_prefix": "scale-single",
    "resource_group_id": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "transit_gateway_name": "scale-single-tgw"
}
```

## Transit Gateway Concepts

### Regional vs Global Routing

**Regional Routing (Default)**:
- Connects VPCs within the same IBM Cloud region
- Lower latency for same-region communication
- No additional charges for global routing

**Global Routing**:
- Connects VPCs across different IBM Cloud regions
- Required for multi-region deployments
- Additional charges apply for cross-region data transfer


## Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output transit_gateway_id
terraform output transit_gateway_crn
terraform output transit_gateway_name
terraform output new_vpc_connection_id
terraform output peer_vpc_connection_id
terraform output peer_vpc_already_attached
terraform output peer_vpc_connection_status
terraform output transit_gateway_status
```

## Cleanup

```bash
# Destroy Transit Gateway and connections
terraform destroy -auto-approve

# Note: This will delete:
# - Transit Gateway (if created by this module)
# - VPC connections to Transit Gateway
# - Network connectivity between VPCs
```

---

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | >= 1.49.0 |

#### Inputs

| Name | Description | Type |
| ---- | ----------- | ---- |
| <a name="input_enable_transit_gateway"></a> [enable_transit_gateway](#input_enable_transit_gateway) | Flag to enable Transit Gateway for VPC connectivity. Set to true to create or use Transit Gateway. | `bool` |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key) | IBM Cloud API key for authentication and resource provisioning. | `string` |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id) | ID of the IBM Cloud resource group where Transit Gateway resources will be created. | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix added to all resource names for identification and organization. | `string` |
| <a name="input_vpc_crn"></a> [vpc_crn](#input_vpc_crn) | CRN of the newly created VPC to attach to Transit Gateway. | `string` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | IBM Cloud region where the Transit Gateway will be created. | `string` |
| <a name="input_peer_vpc_crn"></a> [peer_vpc_crn](#input_peer_vpc_crn) | CRN of the peer VPC to connect via Transit Gateway. Required if enable_transit_gateway is true. | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to be applied to Transit Gateway resources. | `list(string)` |
| <a name="input_transit_gateway_global_routing"></a> [transit_gateway_global_routing](#input_transit_gateway_global_routing) | Enable global routing for Transit Gateway to allow connections across different regions. | `bool` |
| <a name="input_existing_transit_gateway_name"></a> [existing_transit_gateway_name](#input_existing_transit_gateway_name) | Name of an existing Transit Gateway to use. If not provided, a new Transit Gateway will be created. | `string` |
| <a name="input_transit_gateway_name"></a> [transit_gateway_name](#input_transit_gateway_name) | Name for the new Transit Gateway. Defaults to '<resource_prefix>-tgw' if not provided. | `string` |

#### Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_new_vpc_connection_id"></a> [new_vpc_connection_id](#output_new_vpc_connection_id) | ID of the Transit Gateway connection for the new VPC. |
| <a name="output_peer_vpc_connection_id"></a> [peer_vpc_connection_id](#output_peer_vpc_connection_id) | ID of the Transit Gateway connection for the peer VPC (either existing or newly created). |
| <a name="output_peer_vpc_already_attached"></a> [peer_vpc_already_attached](#output_peer_vpc_already_attached) | Boolean flag indicating if the peer VPC was already attached to the Transit Gateway. |
| <a name="output_peer_vpc_connection_status"></a> [peer_vpc_connection_status](#output_peer_vpc_connection_status) | Status of peer VPC connection: 'existing' (already attached), 'created' (newly attached), or 'not_configured' (no peer VPC specified). |
| <a name="output_transit_gateway_crn"></a> [transit_gateway_crn](#output_transit_gateway_crn) | CRN of the Transit Gateway (either existing or newly created). |
| <a name="output_transit_gateway_id"></a> [transit_gateway_id](#output_transit_gateway_id) | ID of the Transit Gateway (either existing or newly created). |
| <a name="output_transit_gateway_name"></a> [transit_gateway_name](#output_transit_gateway_name) | Name of the Transit Gateway. |
| <a name="output_transit_gateway_status"></a> [transit_gateway_status](#output_transit_gateway_status) | Status of the Transit Gateway. |
<!-- END_TF_DOCS -->
