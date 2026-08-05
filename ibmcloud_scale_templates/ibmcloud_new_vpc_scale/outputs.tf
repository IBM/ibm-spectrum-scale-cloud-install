output "vpc_id" {
  value       = module.vpc.vpc_ref
  description = "The ID of the VPC."
}

output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "The name of the VPC."
}

output "vpc_crn" {
  value       = module.vpc.vpc_crn
  description = "The CRN of the VPC."
}

output "resource_group_id" {
  value       = module.vpc.resource_group_id
  description = "The ID of the resource group used for VPC resources."
}

output "vpc_storage_cluster_private_subnets" {
  value       = module.vpc.vpc_storage_cluster_private_subnets
  description = "List of IDs of storage cluster private subnets."
}

output "vpc_storage_cluster_private_subnets_name" {
  value       = module.vpc.vpc_storage_cluster_private_subnets_name
  description = "List of names of storage cluster private subnets."
}

output "vpc_storage_cluster_private_subnets_crn" {
  value       = module.vpc.vpc_storage_cluster_private_subnets_crn
  description = "List of CRNs of storage cluster private subnets."
}

output "vpc_compute_cluster_private_subnets" {
  value       = module.vpc.vpc_compute_cluster_private_subnets
  description = "List of IDs of compute cluster private subnets."
}

output "vpc_compute_cluster_private_subnets_name" {
  value       = module.vpc.vpc_compute_cluster_private_subnets_name
  description = "List of names of compute cluster private subnets."
}

output "vpc_compute_cluster_private_subnets_crn" {
  value       = module.vpc.vpc_compute_cluster_private_subnets_crn
  description = "List of CRNs of compute cluster private subnets."
}

output "vpc_protocol_private_subnets" {
  value       = module.vpc.vpc_protocol_private_subnets
  description = "List of IDs of protocol cluster private subnets."
}

output "vpc_protocol_private_subnets_name" {
  value       = module.vpc.vpc_protocol_private_subnets_name
  description = "List of names of protocol cluster private subnets."
}

output "vpc_protocol_private_subnets_crn" {
  value       = module.vpc.vpc_protocol_private_subnets_crn
  description = "List of CRNs of protocol cluster private subnets."
}

output "vpc_public_subnets" {
  value       = module.vpc.vpc_public_subnets
  description = "List of IDs of public subnets."
}

output "vpc_public_subnets_name" {
  value       = module.vpc.vpc_public_subnets_name
  description = "List of names of public subnets."
}

output "vpc_public_subnets_crn" {
  value       = module.vpc.vpc_public_subnets_crn
  description = "List of CRNs of public subnets."
}

output "vpc_public_gateway_ids" {
  value       = module.vpc.vpc_public_gateway_ids
  description = "List of IDs of public gateways."
}

output "dns_service_instance_id" {
  value       = module.dns.dns_service_instance_id
  description = "IBM Cloud DNS Service Instance ID."
}

output "dns_service_instance_crn" {
  value       = module.dns.dns_service_instance_crn
  description = "IBM Cloud DNS Service Instance CRN (only available if newly created)."
}

output "vpc_storage_dns_zone_id" {
  value       = module.dns.vpc_storage_dns_zone_id
  description = "IBM Cloud DNS storage cluster zone ID."
}

output "vpc_compute_dns_zone_id" {
  value       = module.dns.vpc_compute_dns_zone_id
  description = "IBM Cloud DNS compute cluster zone ID."
}


output "vpc_protocol_dns_zone_id" {
  value       = module.dns.vpc_protocol_dns_zone_id
  description = "IBM Cloud DNS protocol cluster zone ID."
}

output "transit_gateway_id" {
  value       = module.vpc_peering.transit_gateway_id
  description = "ID of the Transit Gateway used for VPC connectivity."
}

output "transit_gateway_crn" {
  value       = module.vpc_peering.transit_gateway_crn
  description = "CRN of the Transit Gateway used for VPC connectivity."
}

output "transit_gateway_name" {
  value       = module.vpc_peering.transit_gateway_name
  description = "Name of the Transit Gateway."
}

output "new_vpc_connection_id" {
  value       = module.vpc_peering.new_vpc_connection_id
  description = "ID of the Transit Gateway connection for the newly created VPC."
}

output "peer_vpc_connection_id" {
  value       = module.vpc_peering.peer_vpc_connection_id
  description = "ID of the Transit Gateway connection for the peer VPC."
}

output "transit_gateway_status" {
  value       = module.vpc_peering.transit_gateway_status
  description = "Status of the Transit Gateway."
}

output "bastion_security_group_id" {
  value       = module.bastion.bastion_security_group_id
  description = "Bastion security group ID."
}

output "bastion_instance_id" {
  value       = module.bastion.bastion_instance_autoscaling_group_id
  description = "Bastion instance autoscaling group ID."
}

output "bastion_instance_crn" {
  value       = module.bastion.bastion_instance_autoscaling_group_crn
  description = "Bastion instance autoscaling group CRN."
}

output "bastion_public_ip_addresses" {
  value       = module.bastion.bastion_public_ip_addresses
  description = "List of public IP addresses for bastion instances. Use these IPs to SSH into the bastion."
}

output "compute_cluster_instance_ids" {
  value       = module.scale_instances.compute_cluster_instance_ids
  description = "Compute cluster instance ids."
}

output "compute_cluster_instance_private_ips" {
  value       = module.scale_instances.compute_cluster_instance_private_ips
  description = "Private IP address of compute cluster instances."
}

output "storage_cluster_instance_ids" {
  value       = module.scale_instances.storage_cluster_instance_ids
  description = "Storage cluster instance ids."
}

output "storage_cluster_instance_private_ips" {
  value       = module.scale_instances.storage_cluster_instance_private_ips
  description = "Private IP address of storage cluster instances."
}

output "storage_cluster_with_data_volume_mapping" {
  value       = module.scale_instances.storage_cluster_with_data_volume_mapping
  description = "Mapping of storage cluster instance ip vs. device path."
}

output "storage_cluster_desc_instance_ids" {
  value       = module.scale_instances.storage_cluster_desc_instance_ids
  description = "Storage cluster desc instance id."
}

output "storage_cluster_desc_instance_private_ips" {
  value       = module.scale_instances.storage_cluster_desc_instance_private_ips
  description = "Private IP address of storage cluster desc instance."
}

output "storage_cluster_desc_data_volume_mapping" {
  value       = module.scale_instances.storage_cluster_desc_data_volume_mapping
  description = "Mapping of storage cluster desc instance ip vs. device path."
}

output "protocol_cluster_instance_ids" {
  value       = [for inst in try(module.scale_instances.protocol_instance_details, []) : inst.id]
  description = "Protocol cluster instance ids."
}

output "protocol_cluster_instance_private_ips" {
  value       = [for inst in try(module.scale_instances.protocol_instance_details, []) : inst.private_ip]
  description = "Private IP address of protocol cluster instances."
}

output "placement_group_id" {
  value       = try(module.scale_instances.placement_group_id, null)
  description = "IBM Cloud placement group id for single-AZ deployments."
}

# Node list consumed by the scale-operator cluster controller via
# spec.cloud.outputsRef. The controller reads the "nodes" key from the
# tofu-controller output Secret and expects each entry to have:
#   hostname (string), ip (string), role (string).
output "nodes" {
  description = "Node inventory for the scale-operator cluster controller."
  value = concat(
    [for i, inst in try(module.scale_instances.storage_cluster_instance_details, []) : {
      hostname = inst.dns
      ip       = inst.private_ip
      role     = i == 0 ? "storage,bootstrap" : "storage"
    }],
    [for inst in try(module.scale_instances.storage_cluster_dec_instance_details, []) : {
      hostname = inst.dns
      ip       = inst.private_ip
      role     = "storage-tiebreaker"
    }],
    [for inst in try(module.scale_instances.compute_cluster_instance_details, []) : {
      hostname = inst.dns
      ip       = inst.private_ip
      role     = "compute"
    }],
    [for inst in try(module.scale_instances.gateway_instance_details, []) : {
      hostname = inst.dns
      ip       = inst.private_ip
      role     = "afm"
    }],
    [for inst in try(module.scale_instances.protocol_instance_details, []) : {
      hostname = inst.dns
      ip       = inst.private_ip
      role     = "protocol"
    }]
  )
}

output "storage_cluster_volume_ids" {
  value       = try(module.scale_instances.storage_cluster_volume_ids, {})
  description = "Map of disk-key to volume ID for all storage cluster data volumes."
}

output "storage_cluster_desc_volume_ids" {
  value       = try(module.scale_instances.storage_cluster_desc_volume_ids, {})
  description = "Map of disk-key to volume ID for storage cluster tiebreaker data volumes."
}
