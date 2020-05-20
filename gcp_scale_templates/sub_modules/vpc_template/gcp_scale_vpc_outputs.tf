output "vpc_name" {
  value = module.vpc.vpc_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_name" {
  value = module.private_subnet.subnet_name
}

output "public_subnet_name" {
  value = module.public_subnet.subnet_name
}

output "public_subnet_id" {
  value = module.public_subnet.subnet_id
}

output "private_subnet_id" {
  value = module.private_subnet.subnet_id
}
