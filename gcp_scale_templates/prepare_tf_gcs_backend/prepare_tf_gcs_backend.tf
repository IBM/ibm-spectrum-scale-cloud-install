/*
    Creates new GCP storage bucket which will be used for storing
    terraform state file.
*/

resource "google_storage_bucket" "create_bucket" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = var.force_destroy

  versioning {
    enabled = true
  }
}


output "bucket_uri" {
  value = google_storage_bucket.create_bucket.self_link
}

output "bucket_url" {
  value = google_storage_bucket.create_bucket.url
}
