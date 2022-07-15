variable "project_id" {
  type        = string
  description = "Project to be used to create the VM/image in your Google Cloud"
}

variable "service_account_json" {
  type    = string
  default = "Service account credential json file path to be used"
}

variable "vpc_zone" {
  type        = string
  default     = "us-central1-a"
  description = "The VPC zone you want to use for building image."
}

variable "vpc_region" {
  type        = string
  default     = "us-central1"
  description = "The region where GCP operations will take place. Examples are us-central1, us-east1 etc."
}

variable "image_name" {
  type        = string
  description = "The name of the resulting image. To make this unique, timestamp will be appended."
}

variable "image_description" {
  type        = string
  default     = "IBM Spectrum Scale Image"
  description = "The description to set for the resulting AMI."
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-2"
  description = "The GCP VM machine type to use while building the image."
}

variable "source_image_family" {
  type    = string
  default = "rhel-8"
  description = "The source image family whose root volume will be copied and provisioned on the currently running instance."
}

variable "gcs_spectrumscale_bucket" {
  type        = string
  description = "GCS bucket which contains IBM Spectrum Scale rpm(s)."
}

variable "disk_size" {
  type        = string
  default     = "200"
  description = "The size of the volume, in GiB."
}

variable "disk_type" {
  type        = string
  default     = "pd-ssd"
  description = "The volume type. gp2 & gp3 for General Purpose (SSD) volumes."
}

variable "user_account" {
  type        = string
  default     = "gcpuser"
  description = "The username to login/connect to SSH with."
}
