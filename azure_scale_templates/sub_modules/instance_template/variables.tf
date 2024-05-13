variable "airgap" {
  type        = bool
  nullable    = true
  description = "If true, instance iam profile, git utils which need internet access will be skipped."
}

variable "bastion_instance_public_ip" {
  type        = string
  nullable    = true
  description = "Bastion instance public ip address."
}

variable "bastion_instance_ref" {
  type        = string
  nullable    = true
  description = "Bastion instance reference."
}

variable "bastion_security_group_ref" {
  type        = string
  nullable    = true
  description = "Bastion security group reference (id/self-link)."
}

variable "bastion_ssh_private_key" {
  type        = string
  nullable    = true
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "bastion_user" {
  type        = string
  nullable    = true
  description = "Bastion login username."
}

variable "client_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Active Directory service principal associated with your account."
}

variable "client_secret" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password or secret for your service principal."
}

variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "compute_boot_disk_type" {
  type        = string
  nullable    = true
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  nullable    = true
  description = "Password for Compute cluster GUI."
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  nullable    = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_image_ref" {
  type        = string
  nullable    = true
  description = "Image from which to initialize Spectrum Scale compute instances."
}

variable "compute_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_key_pair" {
  type        = string
  nullable    = true
  description = "The SSH public key pair to use to launch the compute cluster host."
}

variable "compute_cluster_login_username" {
  type        = string
  nullable    = true
  description = "The username of the local administrator used for the Virtual Machine."
}

variable "compute_cluster_os_disk_caching" {
  type        = string
  nullable    = true
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "create_remote_mount_cluster" {
  type        = bool
  nullable    = true
  description = "Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup."
}

variable "create_scale_cluster" {
  type        = bool
  nullable    = true
  description = "Flag to represent whether to create scale cluster or not."
}

variable "enable_placement_group" {
  type        = bool
  nullable    = true
  description = "If true, a placement group will be created and all instances will be created with strategy - cluster."
}

variable "filesystem_parameters" {
  type = list(object({
    name                         = string
    filesystem_config_file       = string
    filesystem_encrypted         = bool
    filesystem_kms_key_ref       = string
    filesystem_kms_key_ring_ref  = string
    device_delete_on_termination = bool
    disk_config = list(object({
      filesystem_pool                    = string
      block_devices_per_storage_instance = number
      block_device_volume_type           = string
      block_device_volume_size           = string
      block_device_iops                  = string
      block_device_throughput            = string
    }))
  }))
  nullable    = true
  description = "Filesystem parameters in relationship with disk parameters."
}

variable "gateway_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the gateway instances."
}

variable "instances_ssh_user_name" {
  type        = string
  nullable    = false
  description = "Compute/Storage VM login username."
}

variable "inventory_format" {
  type        = string
  nullable    = true
  description = "Specify inventory format suited for ansible playbooks."
}

variable "nsg_rule_start_index" {
  type        = number
  description = "Specifies the network security group rule priority start index."
}

variable "resource_group_name" {
  type        = string
  nullable    = false
  description = "The name of a new resource group in which the resources will be created."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "scratch_devices_per_storage_instance" {
  type        = number
  nullable    = true
  description = "Number of scratch disks to be attached to each storage instance."
}

variable "spectrumscale_rpms_path" {
  type        = string
  nullable    = true
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "storage_cluster_boot_disk_type" {
  type        = string
  nullable    = true
  description = "Type of storage account which should back this the internal OS disk (Ex: Standard_LRS, StandardSSD_LRS and Premium_LRS)."
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_image_ref" {
  type        = string
  nullable    = true
  description = "Image from which to initialize Spectrum Scale storage instances."
}

variable "storage_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the storage cluster instances."
}

variable "storage_cluster_key_pair" {
  type        = string
  nullable    = true
  description = "The SSH public key pair to use to launch the storage cluster host."
}

variable "storage_cluster_login_username" {
  type        = string
  nullable    = true
  description = "The username of the local administrator used for the Virtual Machine."
}

variable "storage_cluster_os_disk_caching" {
  type        = string
  nullable    = false
  description = "Specifies the caching requirements for the OS Disk (Ex: None, ReadOnly and ReadWrite)."
}

variable "subscription_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The subscription ID to use."
}

variable "tenant_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Active Directory tenant identifier, must provide when using service principals."
}

variable "total_compute_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of Azure instances (vms) to be launched for compute cluster."
}

variable "total_gateway_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for gateway nodes."
}

variable "total_storage_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of Azure instances (vms) to be launched for storage cluster."
}

/*
variable "using_direct_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud virtual private cloud (VPC) via a VPN or direct connection. This mode requires variable `client_ip_ranges`, as the on-premise client ip will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}
*/

variable "using_jumphost_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_packer_image" {
  type        = bool
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_rest_api_remote_mount" {
  type        = string
  nullable    = true
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = false
  description = "A list of availability zones ids in the region/location."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  nullable    = true
  description = "DNS domain name to be used for compute cluster."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of compute cluster private subnets."
}

variable "vpc_forward_dns_zone" {
  type        = string
  nullable    = true
  description = "DNS zone name to be used for scale cluster (Ex: example-zone)."
}

variable "vpc_network_security_group_ref" {
  type        = string
  nullable    = false
  description = "VNet network security group id/reference."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The location/region of the vnet to create. Examples are East US, West US, etc."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = true
  description = "DNS reverse zone lookup to be used for scale cluster (Ex: 10.in-addr.arpa)."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  nullable    = true
  description = "DNS domain name to be used for storage cluster."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  description = "List of IDs of storage cluster private subnets."
}
