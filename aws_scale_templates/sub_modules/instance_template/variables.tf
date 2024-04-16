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
  description = "Bastion instance ref."
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

variable "ces_private_ips" {
  type        = list(string)
  nullable    = true
  description = "List of CES ipaddress to use (must be equal to total_protocol_instances)."
}

variable "client_ip_ranges" {
  type        = list(string)
  nullable    = true
  description = "List of gateway/client ip/cidr ranges."
}

variable "client_security_group_ref" {
  type        = string
  nullable    = true
  description = "Client security group reference (id/self-link)."
}

variable "cluster_type" {
  type        = string
  nullable    = false
  description = "Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage."
}

variable "compute_cluster_boot_disk_type" {
  type        = string
  nullable    = true
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  nullable    = true
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "compute_cluster_gui_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "Password for Compute cluster GUI."
}

variable "compute_cluster_gui_username" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_image_ref" {
  type        = string
  nullable    = true
  description = "ID of AMI to use for provisioning the compute cluster instances."
}

variable "compute_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the compute cluster instances."
}

variable "compute_cluster_key_pair" {
  type        = string
  nullable    = true
  description = "The key pair to use to launch the compute cluster host."
}

variable "compute_cluster_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the compute cluster."
}

variable "compute_cluster_volume_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the compute cluster volume(s)."
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

variable "gateway_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the gateway instances."
}

variable "gateway_volume_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the gateway volume(s)."
}

variable "instances_ssh_user_name" {
  type        = string
  nullable    = true
  description = "Compute/Storage EC2 instances login username."
}

variable "inventory_format" {
  type        = string
  nullable    = true
  description = "Specify inventory format suited for ansible playbooks. Examples: ini, json"
}

variable "operator_email" {
  type        = string
  nullable    = true
  description = "SNS notifications will be sent to provided email id."
}

variable "protocol_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the protocol instances."
}

variable "protocol_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the protocol instances."
}

variable "protocol_volume_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the protocol volume(s)."
}

variable "resource_prefix" {
  type        = string
  nullable    = false
  description = "Prefix is added to all resources that are created."
}

variable "root_device_encrypted" {
  type        = bool
  nullable    = true
  description = "Whether to enable volume encryption for root device."
}

variable "root_device_kms_key_ref" {
  type        = string
  nullable    = true
  description = "Amazon Resource Name (ARN) of the KMS Key to use when encrypting the root volume."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  nullable    = true
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "spectrumscale_rpms_path" {
  type        = string
  nullable    = true
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "storage_cluster_boot_disk_type" {
  type        = string
  nullable    = true
  description = "EBS volume types: standard, gp2, gp3, io1, io2 and sc1 or st1."
}

variable "storage_cluster_gui_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "Password for Storage cluster GUI"
}

variable "storage_cluster_gui_username" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_image_ref" {
  type        = string
  nullable    = true
  description = "ID of AMI to use for provisioning the storage cluster instances."
}

variable "storage_cluster_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for provisioning the storage cluster instances."
}

variable "storage_cluster_key_pair" {
  type        = string
  nullable    = true
  description = "The key pair to use to launch the storage cluster host."
}

variable "storage_cluster_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the storage cluster."
}

variable "storage_cluster_tiebreaker_instance_type" {
  type        = string
  nullable    = true
  description = "Instance type to use for the tie breaker instance (will be provisioned only in Multi-AZ configuration)."
}

variable "storage_cluster_volume_tags" {
  type        = map(string)
  nullable    = true
  description = "Additional tags for the storage cluster volume(s)."
}

variable "total_compute_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for compute cluster."
}

variable "total_gateway_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for gateway nodes."
}

variable "total_protocol_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for protocol nodes."
}

variable "total_storage_cluster_instances" {
  type        = number
  nullable    = true
  description = "Number of EC2 instances to be launched for storage cluster."
}

variable "using_cloud_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between a cloud virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `client_security_group_ref` (make sure it is in the same vpc), as the cloud VM security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_direct_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud virtual private cloud (VPC) via a VPN or direct connection. This mode requires variable `client_ip_ranges`, as the on-premise client ip will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_jumphost_connection" {
  type        = bool
  nullable    = true
  description = "This flag is intended to enable ansible related communication between an on-premise virtual machine (VM) to cloud existing virtual private cloud (VPC). This mode requires variable `bastion_user`, `bastion_instance_public_ip`, `bastion_security_group_ref`, `bastion_ssh_private_key`, as the jump host related security group reference (id/self-link) will be added to the allowed ingress list of scale (storage/compute) cluster security groups."
}

variable "using_packer_image" {
  type        = bool
  nullable    = true
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
  description = "A list of availability zones names or ids in the region."
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

variable "vpc_ref" {
  type        = string
  nullable    = false
  description = "VPC id were to deploy the bastion."
}

variable "vpc_region" {
  type        = string
  nullable    = false
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_reverse_dns_domain" {
  type        = string
  nullable    = true
  description = "DNS reverse domain (Ex: 10.in-addr.arpa)."
}

variable "vpc_reverse_dns_zone" {
  type        = string
  nullable    = true
  description = "DNS reverse zone lookup to be used for scale cluster (Ex: example-zone-reverse)."
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
