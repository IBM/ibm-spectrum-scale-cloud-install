variable "location" {
    type = string
}
variable "resource_group_name" {
    type    = string
    default = "Spectrum-Scale-rg"
}
variable "vnet_name" {
    type    = string
    default = "Spectrum-Scale-vnet"
}
variable "vnet_address_space" {
    type    = string
    default = "10.0.0.0/16"
}
variable "bastion_hostname" {
    type    = string
    default = "bastion-access"
}
variable "bastion_public_subnet_id" {
    type    = string
}
variable "public_subnet_address_prefix" {
    type    = string
    default = "10.0.1.0/27"
}
variable "template_body" {
    type = string
}
