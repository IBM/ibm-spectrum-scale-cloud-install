variable "vpc_region" {
  type        = string
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vpc_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "VPC id were to deploy the bastion."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of IDs of storage cluster private subnets."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  nullable    = true
  default     = null
  description = "List of IDs of compute cluster private subnets."
}

variable "total_compute_cluster_instances" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of EC2 instances to be launched for compute cluster."
}

variable "compute_cluster_key_pair" {
  type        = string
  nullable    = true
  default     = null
  description = "The key pair to use to launch the compute cluster host."
}

variable "compute_cluster_image_id" {
  type        = string
  nullable    = true
  default     = null
  description = "ID of AMI to use for provisioning the compute cluster instances."
}

variable "compute_cluster_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_root_volume_type" {
  type        = string
  nullable    = true
  default     = null
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "compute_cluster_volume_tags" {
  type        = map(string)
  nullable    = true
  default     = null
  description = "Additional tags for the compute cluster volume(s)."
}

variable "compute_cluster_gui_username" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "Password for Compute cluster GUI."
}

variable "compute_cluster_tags" {
  type        = map(string)
  nullable    = true
  default     = null
  description = "Additional tags for the compute cluster."
}

variable "total_storage_cluster_instances" {
  type        = number
  nullable    = true
  default     = null
  description = "Number of EC2 instances to be launched for storage cluster."
}

variable "storage_cluster_key_pair" {
  type        = string
  nullable    = true
  default     = null
  description = "The key pair to use to launch the storage cluster host."
}

variable "storage_cluster_image_ref" {
  type        = string
  nullable    = true
  default     = null
  description = "ID of AMI to use for provisioning the storage cluster instances."
}

variable "storage_cluster_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for provisioning the storage cluster instances."
}

variable "storage_cluster_tags" {
  type        = map(string)
  nullable    = true
  default     = null
  description = "Additional tags for the storage cluster."
}

variable "storage_cluster_tiebreaker_instance_type" {
  type        = string
  nullable    = true
  default     = null
  description = "Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration)."
}

variable "storage_cluster_root_volume_type" {
  type        = string
  nullable    = true
  default     = null
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "storage_cluster_volume_tags" {
  type        = map(string)
  nullable    = true
  default     = null
  description = "Additional tags for the storage cluster volume(s)."
}

variable "storage_cluster_gui_username" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "using_rest_api_remote_mount" {
  type        = string
  nullable    = true
  default     = null
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}

variable "using_packer_image" {
  type        = bool
  nullable    = true
  default     = null
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_direct_connection" {
  type        = bool
  nullable    = true
  default     = null
  description = "If true, will skip the jump/bastion host configuration."
}

variable "enable_placement_group" {
  type        = bool
  nullable    = true
  default     = null
  description = "If true, a placement group will be created and all instances will be created with strategy - cluster."
}

variable "ebs_block_devices_per_storage_instance" {
  type        = number
  nullable    = true
  default     = null
  description = "Additional EBS block devices to attach per storage cluster instance."
}

# Below parameters are only applicable if ebs_block_devices_per_storage_instance is set > 0
variable "block_device_delete_on_termination" {
  type        = bool
  nullable    = true
  default     = null
  description = "If true, all ebs volumes will be destroyed on instance termination."
}

variable "block_device_encrypted" {
  type        = bool
  nullable    = true
  default     = null
  description = "Whether to enable volume encryption."
}

variable "block_device_iops" {
  type        = number
  nullable    = true
  default     = null
  description = "Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3."
}

variable "block_device_throughput" {
  type        = number
  nullable    = true
  default     = null
  description = "Throughput that the volume supports, in MiB/s. Only valid for volume_type of gp3."
}

variable "block_device_kms_key_id" {
  type        = string
  nullable    = true
  default     = null
  description = "Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume."
}

variable "block_device_volume_size" {
  type        = number
  nullable    = true
  default     = null
  description = "Size of the volume in gibibytes (GiB)."
}

variable "block_device_volume_type" {
  type        = string
  nullable    = true
  default     = null
  description = "EBS volume types: io1, io2, gp2, gp3."
}

variable "enable_instance_store_block_device" {
  type        = bool
  nullable    = true
  default     = null
  description = "Enable instance storage block devices."
}

variable "enable_nvme_block_device" {
  type        = bool
  nullable    = true
  default     = null
  description = "Enable NVMe block devices (built on Nitro instances)."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  nullable    = true
  default     = null
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "spectrumscale_rpms_path" {
  type        = string
  nullable    = true
  default     = null
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "operator_email" {
  type        = string
  nullable    = true
  default     = null
  description = "SNS notifications will be sent to provided email id."
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  nullable    = true
  default     = null
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  nullable    = true
  default     = null
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  nullable    = true
  default     = null
  description = "Filesystem block size."
}

variable "create_remote_mount_cluster" {
  type        = bool
  nullable    = true
  default     = null
  description = "Flag to select if separate compute and storage cluster needs to be created and proceed for remote mount filesystem setup."
}

variable "bastion_user" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion login username."
}

variable "bastion_instance_public_ip" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion instance public ip address."
}

variable "bastion_security_group_id" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion security group id."
}

variable "bastion_instance_id" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion instance id."
}

variable "bastion_ssh_private_key" {
  type        = string
  nullable    = true
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "create_scale_cluster" {
  type        = bool
  nullable    = true
  default     = null
  description = "Flag to represent whether to create scale cluster or not."
}

variable "inventory_format" {
  type        = string
  default     = "ini"
  description = "Specify inventory format suited for ansible playbooks."
}
