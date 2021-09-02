variable "client_id" {
  type        = string
  description = "The Active Directory service principal associated with your account."
}

variable "client_secret" {
  type        = string
  description = "The password or secret for your service principal."
}

variable "tenant_id" {
  type        = string
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
}

variable "vnet_location" {
  type        = string
  description = "The location/region of the vnet to create. Examples are East US, West US, etc."
}

variable "vnet_availability_zones" {
  type        = list(string)
  description = "A list of availability zones ids in the region/location."
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "create_separate_namespaces" {
  type        = bool
  default     = true
  description = "Flag to select if separate namespace needs to be created for compute instances."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Number of Azure instances (vms) to be launched for compute cluster."
}

variable "compute_cluster_ssh_public_key" {
  type        = string
  description = "The SSH public key to use to launch the compute cluster host."
}

variable "compute_cluster_dns_zone" {
  type        = string
  description = "Compute cluster DNS zone."
}

variable "storage_cluster_dns_zone" {
  type        = string
  description = "Storage cluster DNS zone."
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Number of Azure instances (vms) to be launched for storage cluster."
}

variable "storage_cluster_ssh_public_key" {
  type        = string
  description = "The SSH public key to use to launch the storage cluster host."
}

variable "vnet_compute_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of compute cluster private subnets."
}

variable "vnet_storage_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of storage cluster private subnets."
}

variable "compute_cluster_vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "storage_cluster_vm_size" {
  type        = string
  default     = "Standard_A2_v2"
  description = "Instance type to use for provisioning the storage cluster instances."
}

variable "compute_cluster_image_publisher" {
  type        = string
  default     = "RedHat"
  description = "Specifies the publisher of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_image_offer" {
  type        = string
  default     = "RHEL"
  description = "Specifies the offer of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_image_sku" {
  type        = string
  default     = "8.2"
  description = "Specifies the SKU of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the image used to create the compute cluster virtual machines."
}

variable "compute_cluster_os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "compute_cluster_os_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "compute_cluster_login_username" {
  type        = string
  default     = "azureuser"
  description = "The username of the local administrator used for the Virtual Machine."
}

variable "storage_cluster_image_publisher" {
  type        = string
  default     = "RedHat"
  description = "Specifies the publisher of the image used to create the storage cluster virtual machines."
}

variable "storage_cluster_image_offer" {
  type        = string
  default     = "RHEL"
  description = "Specifies the offer of the image used to create the storage cluster virtual machines."
}

variable "storage_cluster_image_sku" {
  type        = string
  default     = "8.2"
  description = "Specifies the SKU of the image used to create the storage cluster virtual machines."
}

variable "storage_cluster_image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the image used to create the storage cluster virtual machines."
}

variable "storage_cluster_os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "storage_cluster_os_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "storage_cluster_login_username" {
  type        = string
  default     = "azureuser"
  description = "The username of the local administrator used for the Virtual Machine."
}

variable "data_disks_per_storage_instance" {
  type        = number
  default     = 1
  description = "Additional Data disks to attach per storage cluster instance."
}

variable "data_disk_size" {
  type        = number
  default     = 500
  description = "Size of the volume in gibibytes (GB)."
}

variable "data_disk_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "Type of storage to use for the managed disk (Ex: Standard_LRS, Premium_LRS, StandardSSD_LRS or UltraSSD_LRS)."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  default     = "/opt/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "spectrumscale_rpms_path" {
  type        = string
  default     = "/opt/IBM/gpfs_cloud_rpms"
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for Compute cluster GUI."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "using_direct_connection" {
  type        = bool
  default     = false
  description = "If true, will skip the jump/bastion host configuration."
}

variable "using_packer_image" {
  type        = bool
  default     = false
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "ansible_jump_host_public_ip" {
  type        = string
  default     = null
  description = "Ansible jump host instance public ip address."
}

variable "ansible_jump_host_id" {
  type        = string
  default     = null
  description = "Ansible jump host instance id."
}

variable "ansible_jump_host_ssh_private_key" {
  type        = string
  default     = null
  description = "Ansible jump host SSH private key path, which will be used to login to ansible jump host."
}
