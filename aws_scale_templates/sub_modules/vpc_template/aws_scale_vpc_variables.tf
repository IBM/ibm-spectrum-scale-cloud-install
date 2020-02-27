variable "region" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = string
    description = "AWS region where the resources will be created."
}

variable "stack_name" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = string
    default = "Spectrum-Scale"
    description = "AWS stack name, will be used for tagging resources."
}

variable "availability_zones" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = list(string)
    description = "List of availability zones."
}

variable "cidr_block" {
    type    = string
    default = "10.0.0.0/16"
    description = "AWS VPC CIDR block."
}

variable "public_subnets_cidr" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = list(string)
    default = ["10.0.128.0/20", "10.0.144.0/20"]
    description = "AWS Public subnet CIDR blocks."
}

variable "private_subnets_cidr" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = list(string)
    default = ["10.0.0.0/19", "10.0.32.0/19"]
    description = "AWS Private subnet CIDR blocks."
}
