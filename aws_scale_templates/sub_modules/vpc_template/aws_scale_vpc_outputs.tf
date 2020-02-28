output "stack_name" {
    value = var.stack_name
}

output "vpc_id" {
    value = module.vpc.vpc_id
}

output "private_subnets" {
    value = module.private_subnet.subnet_id
}

output "public_subnets" {
    value = module.public_subnet.subnet_id
}
