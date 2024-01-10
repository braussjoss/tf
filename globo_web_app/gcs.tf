#GCS BUCKET

#GCS BUCKET IAM PERMISSIONS
resource "google_storage_bucket" "gcs_bucket" {
  name                        = local.bucket_name
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "website_content" {
  for_each = local.website_content
  name     = each.value
  source   = "${path.root}/${each.value}"
  bucket   = google_storage_bucket.gcs_bucket.name
}