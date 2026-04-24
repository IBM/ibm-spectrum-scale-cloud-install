# VPC Peering Template Module

This module creates IBM Cloud Transit Gateway resources to enable VPC-to-VPC connectivity for IBM Spectrum Scale deployments.

## Overview

IBM Cloud uses Transit Gateway as the mechanism for connecting VPCs. This module supports:
- Creating a new Transit Gateway or using an existing one
- Connecting the newly created VPC to Transit Gateway
- Connecting a peer VPC to Transit Gateway
- Regional or global routing capabilities

## Features

- **Flexible Transit Gateway Management**: Create new or use existing Transit Gateway
- **VPC Connectivity**: Automatically attach new and peer VPCs to Transit Gateway
- **Global Routing**: Optional support for cross-region VPC connectivity
- **Resource Tagging**: Consistent naming with resource prefix

## Usage

```hcl
module "vpc_peering" {
  source                         = "../sub_modules/vpc_peering_template"
  enable_transit_gateway         = true
  vpc_region                     = "us-south"
  vpc_crn                        = module.vpc.vpc_crn
  peer_vpc_crn                   = "crn:v1:bluemix:public:is:us-south:a/..."
  resource_prefix                = "ibm-storage-scale"
  resource_group_id              = "abc123..."
  transit_gateway_global_routing = false
  ibmcloud_api_key               = var.ibmcloud_api_key
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| ibm | >= 1.49.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_transit_gateway | Flag to enable Transit Gateway for VPC connectivity | `bool` | n/a | yes |
| vpc_region | IBM Cloud region where Transit Gateway will be created | `string` | n/a | yes |
| vpc_crn | CRN of the newly created VPC to attach to Transit Gateway | `string` | n/a | yes |
| resource_prefix | Prefix added to all resource names | `string` | n/a | yes |
| resource_group_id | ID of the IBM Cloud resource group | `string` | n/a | yes |
| ibmcloud_api_key | IBM Cloud API key for authentication | `string` | n/a | yes |
| peer_vpc_crn | CRN of the peer VPC to connect via Transit Gateway | `string` | `null` | no |
| transit_gateway_id | ID of an existing Transit Gateway to use | `string` | `null` | no |
| transit_gateway_name | Name for the new Transit Gateway | `string` | `null` | no |
| transit_gateway_global_routing | Enable global routing for cross-region connectivity | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| transit_gateway_id | ID of the Transit Gateway |
| transit_gateway_crn | CRN of the Transit Gateway |
| transit_gateway_name | Name of the Transit Gateway |
| new_vpc_connection_id | ID of the Transit Gateway connection for the new VPC |
| peer_vpc_connection_id | ID of the Transit Gateway connection for the peer VPC |
| transit_gateway_status | Status of the Transit Gateway |

## Notes

- Transit Gateway operates at the regional level
- Global routing must be enabled for cross-region VPC connectivity
- Both VPCs must be attached to the same Transit Gateway for connectivity
- Transit Gateway charges apply based on data transfer
