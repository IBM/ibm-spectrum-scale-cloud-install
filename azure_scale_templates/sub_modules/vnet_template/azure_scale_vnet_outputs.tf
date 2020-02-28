output "resource_group_name" {
    value = module.create_resource_group.resource_group_name
}

output "vnet_name" {
    value = module.create_new_vnet.vnet_name
}

output "private_subnet_id" {
    value = module.create_private_subnet.subnet_id
}

output "private_subnet_name" {
    value = module.create_private_subnet.subnet_name
}

output "bastion_public_subnet_id" {
    value = module.create_bastion_public_subnet.subnet_id
}

output "bastion_public_subnet_name" {
    value = module.create_bastion_public_subnet.subnet_name
}

output "private_zone_vnet_link_name" {
    value = module.create_zone_vnet_link.private_dns_zone_vnet_link_name
}
