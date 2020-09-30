variable "location" {
  /*
    Keep it empty, it will be propagated via command line or via ".tfvars"
    or ".tfvars.json"
  */
  type        = string
  description = "GCS location."
}

variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "GCP region where the resources will be created."
}

variable "gcp_project_id" {
  type        = string
  default     = "spectrum-scale"
  description = "GCP project ID to manage resources."
}

variable "credentials_file_path" {
  type        = string
  description = "The path of a GCP service account key file in JSON format."
}

variable "bucket_name" {
  type        = string
  description = "Name to be used for bucket (make sure it is unique)"
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Whether to allow a forceful destruction of this bucket"
}
