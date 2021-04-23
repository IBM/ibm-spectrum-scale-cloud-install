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
variable "private_dns_domain_name" {
  type    = string
  default = "spectrumscale.com"
}
variable "zone_vnet_link_name" {
  type    = string
  default = "spectrumscalevnetlink"
}
variable "private_subnet_name" {
  type    = string
  default = "private-snet"
}
variable "private_subnet_address_prefix" {
  type    = string
  default = "10.0.0.0/24"
}
variable "bastion_subnet_name" {
  type    = string
  default = "AzureBastionSubnet"
}
variable "public_subnet_address_prefix" {
  type    = string
  default = "10.0.1.0/27"
}
