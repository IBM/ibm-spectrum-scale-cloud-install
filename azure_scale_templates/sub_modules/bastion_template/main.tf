/*
    Deployes Bastion Host

    Azure Bastion service cannot be used as jump host for provision scale cluster as it doesn't provide SSH connectivity.
    Hence additional Non-Azure bastion host will be deployed to access VMs via SSH and for further scale deployment

    Note : To enable Azure provided Bastion host deployment then 'azure_bastion_service : true' need to set as input parameter
*/

# Create NSG for bastion
module "bastion_network_security_group" {
  source              = "../../../resources/azure/security/bastion_network_security_group"
  security_group_name = format("%s-bastion", var.resource_prefix)
  location            = var.vpc_region
  remote_cidr_blocks  = var.remote_cidr_blocks[0]
  resource_group_name = var.resource_group_name
}

# Associates NSG with public bastion designated subnet
module "associate_bastion_nsg_wth_subnet" {
  count                     = length(var.bastion_public_subnet_ids)
  source                    = "../../../resources/azure/security/network_security_group_association"
  subnet_id                 = var.bastion_public_subnet_ids[count.index]
  network_security_group_id = module.bastion_network_security_group.sec_group_id
}

# Public subnet for bastion service
module "public_subnet_bastion_service" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/network/subnet_bastion"
  resource_group_name = var.resource_group_name
  address_prefixes    = var.vpc_bastion_service_subnets_cidr_blocks
  vnet_name           = var.vpc_ref
}

# Generate public ip for bastion
module "bastion_public_ip" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/network/public_ip"
  public_ip_name      = format("%s-public-ip", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
}

# Azure Bastion service
# Note : To enable Azure provided Bastion host deployment then 'azure_bastion_service : true' need to set as input parameter
module "azure_bastion_service" {
  count               = var.azure_bastion_service != null ? var.azure_bastion_service == true ? 1 : 0 : 0
  source              = "../../../resources/azure/compute/bastion_host"
  bastion_host_name   = format("%s-bastion", var.resource_prefix)
  resource_group_name = var.resource_group_name
  location            = var.vpc_region
  subnet_id           = module.public_subnet_bastion_service[0].subnet_id
  public_ip           = module.bastion_public_ip[0].id
}

# Non-Azure Bastion host deployment and uses for all successive scale deployment
module "scale_bastion" {
  source                       = "../../../resources/azure/compute/jump_host_vm"
  vm_name_prefix               = "${var.resource_prefix}-bastion"
  image_publisher              = var.image_publisher
  image_offer                  = var.image_offer
  image_sku                    = var.image_sku
  image_version                = var.image_version
  resource_group_name          = var.resource_group_name
  location                     = var.vpc_region
  vm_size                      = var.bastion_instance_type
  vm_count                     = 1
  proximity_placement_group_id = null
  login_username               = var.bastion_login_username
  os_storage_account_type      = var.os_storage_account_type
  user_public_key              = var.user_public_key
  os_disk_caching              = var.os_disk_caching
  subnet_ids                   = var.bastion_public_subnet_ids
}
