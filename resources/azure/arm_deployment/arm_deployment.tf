/*
    Deploys provided Azure ARM.
*/

variable "location" {
    type = string
}
variable "template_body" {
    type = string
}
variable "resource_group_name" {
    type = string
}
variable "bastion_host_name" {
    type = string
}
variable "vnet_name" {
    type = string
}
variable "vnet_address_space" {
    type = string
}
variable "subnet_ipprefix" {
    type = string
}
variable "bastion_subnet_id" {
    type = string
}


resource "azurerm_template_deployment" "arm_deploy" {
    name                = "dep-${var.bastion_host_name}"
    resource_group_name = var.resource_group_name
    template_body       = var.template_body
    deployment_mode     = "Incremental"

    parameters = {
        vnet-name                = var.vnet_name
        vnet-ip-prefix           = var.vnet_address_space
        vnet-new-or-existing     = "existing"
        bastion-subnet-ip-prefix = var.subnet_ipprefix
        bastion-host-name        = var.bastion_host_name
        location                 = var.location
    }

    depends_on = [var.bastion_subnet_id]
}

output "arm_deploy_id" {
    value = azurerm_template_deployment.arm_deploy.id
}
