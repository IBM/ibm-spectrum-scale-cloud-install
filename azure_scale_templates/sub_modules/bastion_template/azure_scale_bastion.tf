/*
    Creates Bastion Access via ARM depolyment
*/

module "bastion_access" {
    source              = "../../../resources/azure/arm_deployment"
    bastion_host_name   = var.bastion_hostname
    bastion_subnet_id   = var.bastion_public_subnet_id
    location            = var.location
    resource_group_name = var.resource_group_name
    subnet_ipprefix     = var.public_subnet_address_prefix
    template_body       = file(var.template_body)
    vnet_address_space  = var.vnet_address_space
    vnet_name           = var.vnet_name
}
