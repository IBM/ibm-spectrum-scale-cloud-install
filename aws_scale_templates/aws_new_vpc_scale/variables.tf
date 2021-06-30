variable "vpc_region" {
  type        = string
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "List of cidr_blocks of public subnets."
}

variable "vpc_storage_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "List of cidr_blocks of storage cluster private subnets."
}

variable "vpc_create_separate_subnets" {
  type        = bool
  default     = true
  description = "Flag to select if separate private subnet to be created for compute cluster."
}

variable "vpc_compute_cluster_private_subnets_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.7.0/24"]
  description = "List of cidr_blocks of compute private subnets."
}

variable "vpc_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the VPC"
}

variable "bastion_public_ssh_port" {
  type        = string
  default     = 22
  description = "Set the SSH port to use from desktop to the bastion."
}

variable "remote_cidr_blocks" {
  type = list(string)
  default = [
    "0.0.0.0/0",
  ]
  description = "List of CIDRs that can access to the bastion. Default : 0.0.0.0/0"
}

variable "bastion_ami_name" {
  type        = string
  default     = "Amazon-Linux2-HVM"
  description = "Bastion AMI Image name."
}

variable "bastion_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type to use for the bastion instance."
}

variable "bastion_key_pair" {
  type        = string
  description = "The key pair to use to launch the bastion host."
}

variable "bastion_ssh_private_key" {
  type        = string
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Number of EC2 instances to be launched for compute cluster."
}

variable "compute_cluster_key_pair" {
  type        = string
  description = "The key pair to use to launch the compute cluster host."
}

variable "compute_cluster_ami_id" {
  type        = string
  description = "ID of AMI to use for provisioning the compute cluster instances."
}

variable "compute_cluster_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "compute_cluster_volume_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the compute cluster volume(s)."
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

variable "compute_cluster_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the compute cluster."
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Number of EC2 instances to be launched for storage cluster."
}

variable "storage_cluster_key_pair" {
  type        = string
  description = "The key pair to use to launch the storage cluster host."
}

variable "storage_cluster_ami_id" {
  type        = string
  description = "ID of AMI to use for provisioning the storage cluster instances."
}

variable "storage_cluster_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for provisioning the storage cluster instances."
}

variable "storage_cluster_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the storage cluster."
}

variable "storage_cluster_tiebreaker_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration)."
}

variable "storage_cluster_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "storage_cluster_volume_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the storage cluster volume(s)."
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

variable "using_packer_image" {
  type        = bool
  default     = false
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "ebs_block_devices_per_storage_instance" {
  type        = number
  default     = 1
  description = "Additional EBS block devices to attach per storage cluster instance."
}

# Below parameters are only applicable if ebs_block_devices_per_storage_instance is set > 0
variable "ebs_block_device_delete_on_termination" {
  type        = bool
  default     = true
  description = "If true, all ebs volumes will be destroyed on instance termination."
}

variable "ebs_block_device_encrypted" {
  type        = bool
  default     = false
  description = "Whether to enable volume encryption."
}

variable "ebs_block_device_iops" {
  type        = number
  default     = 0
  description = "Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3."
}

variable "ebs_block_device_throughput" {
  type        = number
  default     = 0
  description = "Throughput that the volume supports, in MiB/s. Only valid for volume_type of gp3."
}

variable "ebs_block_device_kms_key_id" {
  type        = string
  default     = null
  description = "Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume."
}

variable "ebs_block_device_volume_size" {
  type        = number
  default     = 500
  description = "Size of the volume in gibibytes (GiB)."
}

variable "ebs_block_device_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, io2, gp2, gp3, st1 and sc1."
}

variable "enable_nvme_block_device" {
  type        = bool
  default     = false
  description = "Enable NVMe block devices (built on Nitro instances)."
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

variable "operator_email" {
  type        = string
  description = "SNS notifications will be sent to provided email id."
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "scale_version" {
  type        = string
  description = "IBM Spectrum Scale version."
}

variable "create_separate_namespaces" {
  type        = bool
  default     = true
  description = "Flag to select if separate namespace needs to be created for compute instances."
}
