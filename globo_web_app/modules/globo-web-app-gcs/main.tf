#GCS BUCKET

#GCS BUCKET IAM PERMISSIONS
resource "google_storage_bucket" "gcs_bucket" {
  name                        = var.bucket_name
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}
