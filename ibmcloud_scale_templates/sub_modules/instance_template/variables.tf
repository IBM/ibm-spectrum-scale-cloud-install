variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
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

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "vpc_id" {
  type        = string
  description = "VPC id were to deploy the bastion."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of compute cluster private subnets."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of storage cluster private subnets."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Number of instances to be launched for compute cluster."
}

variable "management_vsi_profile" {
  type        = string
  default     = "bx2-8x32"
  description = "Profile to be used for management instance."
}

variable "compute_cluster_key_pair" {
  type        = list(string)
  default     = null
  description = "The key pair to use to launch the compute cluster host."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the compute cluster instances."
}

variable "compute_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for compute cluster virtual server instance."
}

variable "using_rest_api_remote_mount" {
  type        = string
  default     = true
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  default     = ""
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Password for compute cluster GUI"
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Number of instances to be launched for storage cluster."
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the storage cluster instances."
}

variable "storage_vsi_profile" {
  type        = string
  default     = "bx2d-8x32"
  description = "Profile to be used for storage cluster virtual server instance."
}

variable "storage_cluster_key_pair" {
  type        = list(string)
  description = "The key pair to use to launch the storage cluster host."
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for storage cluster GUI"
}

variable "using_packer_image" {
  type        = bool
  default     = false
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_jumphost_connection" {
  type        = bool
  default     = false
  description = "If true, will skip the jump/bastion host configuration."
}

variable "vpc_compute_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS service resource id."
}

variable "vpc_storage_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud storage cluster DNS service resource id."
}

variable "vpc_compute_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS zone id."
}

variable "vpc_storage_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud storage cluster DNS zone id."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "IBM Cloud DNS domain name to be used for storage cluster."
}

variable "vpc_custom_resolver_id" {
  type        = string
  description = "IBM Cloud DNS custom resolver id."
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

variable "create_separate_namespaces" {
  type        = bool
  default     = true
  description = "Flag to select if separate namespace needs to be created for compute instances."
}

variable "bastion_instance_public_ip" {
  type        = string
  default     = null
  description = "Bastion instance public ip address."
}

variable "bastion_security_group_id" {
  type        = string
  default     = null
  description = "Bastion security group id."
}

variable "bastion_instance_id" {
  type        = string
  default     = null
  description = "Bastion instance id."
}

variable "bastion_ssh_private_key" {
  type        = string
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "deploy_controller_sec_group_id" {
  type        = string
  default     = null
  description = "Deployment controller security group id. Default: null"
}

variable "vpc_create_activity_tracker" {
  type        = bool
  default     = true
  description = "Flag to select if IBM Cloud activity tracker to be created or not. Note: You can only provision 1 instance of this service per IBM Cloud region."
}

variable "activity_tracker_plan_type" {
  type        = string
  default     = "lite"
  description = "IBM Cloud activity tracker plan type (Valid: lite, 7-day, 14-day, 30-day, hipaa-30-day)."
}

variable "create_scale_cluster" {
  type        = bool
  default     = false
  description = "Flag to represent whether to create scale cluster or not."
}

variable "scale_cluster_resource_tags" {
  type        = list(string)
  default     = null
  description = "A list of tags for resources created for scale cluster."
}

variable "compute_vsi_osimage_id" {
  type        = string
  default     = ""
  description = "Image id to use for provisioning the compute cluster instances."
}

variable "storage_vsi_osimage_id" {
  type        = string
  default     = ""
  description = "Image id to use for provisioning the storage cluster instances."
}

variable "storage_bare_metal_server_profile" {
  type        = string
  default     = "cx2d-metal-96x192"
  description = "Specify the virtual server instance profile type name to be used to create the Baremetal Storage nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui)."
}

variable "storage_bare_metal_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the storage Baremetal cluster."
}

variable "storage_bare_metal_osimage_id" {
  type        = string
  default     = ""
  description = "Image Id to use for provisioning the storage Baremetal cluster instances."
}

variable "bms_boot_drive_encryption" {
  type        = bool
  default     = false
  description = "To enable the encryption for the boot drive of bare metal server. Select true or false"
}

variable "storage_type" {
  type        = string
  default     = "scratch"
  description = "Select the required scale filesystem deployment method. Note: Choosing the scale scratch or evaluation type will deploy scale filesystem on VSI and scale persistent type will deploy scale filesystem on Baremetal server."
}

variable "inventory_format" {
  type        = string
  default     = "ini"
  description = "Specify inventory format suited for ansible playbooks."
}

variable "bastion_user" {
  type        = string
  default     = "ubuntu"
  description = "Provide the username for Bastion login."
}

#GKLM Variables

variable "scale_encryption_enabled" {
  type        = bool
  default     = false
  description = "To enable the encryption for the filesystem. Select true or false"
}

variable "gklm_vsi_osimage_id" {
  type        = string
  default     = null
  description = "Image id to use for provisioning the GKLM instances."
}

variable "total_gklm_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for GKLM."
}

variable "gklm_instance_key_pair" {
  type        = list(string)
  default     = null
  description = "The key pair to use to launch the GKLM host."
}

variable "gklm_vsi_osimage_name" {
  type        = string
  default     = null
  description = "Image name to use for provisioning the GKLM instances."
}

variable "gklm_vsi_profile" {
  type        = string
  default     = "bx2-2x8"
  description = "Profile to be used for GKLM virtual server instance."
}

variable "gklm_instance_dns_domain" {
  type        = string
  default     = "gklmscale.com"
  description = "IBM Cloud DNS domain name to be used for GKLM instances."
}

variable "gklm_instance_dns_service_id" {
  type        = string
  default     = null
  description = "IBM Cloud GKLM Instance DNS service resource id."
}

variable "gklm_instance_dns_zone_id" {
  type        = string
  default     = null
  description = "IBM GKLM Instance DNS zone id."
}

variable "scale_encryption_admin_default_password" {
  type        = string
  default     = "SKLM@dmin123"
  description = "The default administrator password used for resetting the admin password based on the user input. The password has to be updated which was configured during the GKLM installation."
}

variable "scale_encryption_admin_username" {
  type        = string
  default     = "SKLMAdmin"
  description = "The default Admin username for Security Key Lifecycle Manager(GKLM)."
}

variable "scale_encryption_admin_password" {
  type        = string
  default     = null
  description = "Password that is used for performing administrative operations for the GKLM.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character from this(~@_+:). Make sure that the password doesn't include the username. Visit this [page](https://www.ibm.com/docs/en/gklm/3.0.1?topic=roles-password-policy) to know more about password policy of GKLM. "
}

# CES Variables

variable "vpc_protocol_cluster_private_subnets" {
  type        = list(string)
  default     = ["10.241.2.0/24"]
  description = "List of IDs of protocol nodes private subnets."
}

variable "vpc_protocol_cluster_dns_domain" {
  type        = string
  default     = "cesscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_protocol_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS service resource id."
}

variable "vpc_protocol_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS zone id."
}

variable "protocol_vsi_profile" {
  type        = string
  default     = "cx2-32x64"
  description = "Profile to be used for compute cluster virtual server instance."
}

variable "colocate_protocol_cluster_instances" {
  type        = bool
  default     = true
  description = "Enable it to use storage instances as protocol instances"
}

variable "total_protocol_cluster_instances" {
  type        = number
  default     = 2
  description = "Total number of protocol nodes that you need to provision. A minimum of 2 nodes and a maximum of 16 nodes are supported"
}

variable "filesets" {
  type = list(object({
    mount_path = string,
    size       = number
  }))
  default     = [{ mount_path = "/mnt/binaries", size = 0 }, { mount_path = "/mnt/data", size = 0 }]
  description = "Mount point(s) and size(s) in GB of file share(s) that can be used to customize shared file storage layout. Provide the details for up to 5 file shares."
}

# Client Cluster Variables

variable "total_client_cluster_instances" {
  type        = number
  default     = 2
  description = "Total number of client cluster instances that you need to provision. A minimum of 2 nodes and a maximum of 64 nodes are supported"
}

variable "client_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-8-minimal-amd64-2"
  description = "Name of the image that you would like to use to create the client cluster nodes for the IBM Storage Scale cluster. The solution supports only stock images that use RHEL8.8 version."
}

variable "client_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Client nodes vis profile"
}

variable "vpc_client_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud client cluster DNS service resource id."
}

variable "vpc_client_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud client cluster DNS zone id."
}

variable "vpc_client_cluster_dns_domain" {
  type        = string
  default     = "clntscale.com"
  description = "IBM Cloud DNS domain name to be used for client cluster."
}

variable "client_cluster_key_pair" {
  type        = list(string)
  default     = null
  description = "The key pair to use to launch the client cluster host."
}

## LDAP variables

variable "enable_ldap" {
  type        = bool
  default     = false
  description = "Set this option to true to enable LDAP for IBM Cloud HPC, with the default value set to false."
}

variable "ldap_basedns" {
  type        = string
  default     = "ldapscale.com"
  description = "The dns domain name is used for configuring the LDAP server. If an LDAP server is already in existence, ensure to provide the associated DNS domain name."
}

variable "ldap_server" {
  type        = string
  default     = "null"
  description = "Provide the IP address for the existing LDAP server. If no address is given, a new LDAP server will be created."
}

variable "ldap_admin_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The LDAP administrative password should be 8 to 20 characters long, with a mix of at least three alphabetic characters, including one uppercase and one lowercase letter. It must also include two numerical digits and at least one special character from (~@_+:) are required. It is important to avoid including the username in the password for enhanced security."
}

variable "ldap_user_name" {
  type        = string
  default     = ""
  description = "Custom LDAP User for performing cluster operations. Note: Username should be between 4 to 32 characters, (any combination of lowercase and uppercase letters).[This value is ignored for an existing LDAP server]"
}

variable "ldap_user_password" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The LDAP user password should be 8 to 20 characters long, with a mix of at least three alphabetic characters, including one uppercase and one lowercase letter. It must also include two numerical digits and at least one special character from (~@_+:) are required.It is important to avoid including the username in the password for enhanced security.[This value is ignored for an existing LDAP server]."
}

variable "ldap_instance_key_pair" {
  type        = list(string)
  default     = null
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the LDAP Server. Make sure that the SSH key is present in the same resource group and region where the LDAP Servers are provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
}

variable "ldap_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for LDAP virtual server instance."
}

variable "ldap_vsi_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-22-04-3-minimal-amd64-1"
  description = "Image name to be used for provisioning the LDAP instances. Note: Debian based OS are only supported for the LDAP feature."
}

variable "total_afm_cluster_instances" {
  type        = number
  default     = 0
  description = "Total number of instance count that you need to provision for afm nodes and enable AFM."
}

variable "afm_vsi_profile" {
  type        = string
  default     = "bx2-32x128"
  description = "The virtual instance or bare metal server instance profile type name to be used to create the AFM gateway nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui) and [bare metal server profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui)."
}

variable "afm_cos_config" {
  type = list(object({
    cos_instance         = string,
    bucket_name          = string,
    bucket_region        = string,
    cos_service_cred_key = string,
    afm_fileset          = string,
    mode                 = string,
    bucket_storage_class = string,
    bucket_type          = string
  }))
  description = "Please provide details for the Cloud Object Storage (COS) instance, including information about the COS bucket, service credentials (HMAC key), AFM fileset, mode (such as Read-only (RO), Single writer (SW), Local updates (LU), and Independent writer (IW)), storage class (standard, vault, cold, or smart), and bucket type (single_site_location, region_location, cross_region_location). Note : The 'afm_cos_config' can contain up to 5 entries. For further details on COS bucket locations, refer to the relevant documentation https://cloud.ibm.com/docs/cloud-object-storage/basics?topic=cloud-object-storage-endpoints."
}
