output "image_id" {
  value = azurerm_image.scale_image[*].id
}

output "image_name" {
  value = azurerm_image.scale_image[*].name
}

output "image_instance" {
  value = module.create_image_vm.instance_name
}
