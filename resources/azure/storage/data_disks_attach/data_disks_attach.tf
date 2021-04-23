/*
    Attach specified number of Azure data disk(s) to Azure Virtual Machine(s) as per AZ mix.
*/

variable "lun_units" {
  type = list(string)
}
variable "vm_ids" {
  type = list(string)
}
variable "data_disk_ids" {
  type = list(string)
}
variable "data_disk_caching" {
  type = string
}


resource "azurerm_virtual_machine_data_disk_attachment" "vm_datadisk_attach" {
  count              = length(var.data_disk_ids)
  managed_disk_id    = element(var.data_disk_ids, count.index)
  virtual_machine_id = element(var.vm_ids, count.index)
  lun                = element(var.lun_units, count.index)
  caching            = var.data_disk_caching
}

output "vm_datadisk_attach_ids" {
  value = azurerm_virtual_machine_data_disk_attachment.vm_datadisk_attach.*.id
}
